defmodule Components.KV do
  alias Components.KV

  use Ecto.Schema
  import Ecto.Changeset

  schema "kv" do
    field :key, :string
    field :value, :string

    timestamps()
  end

  @doc false
  def changeset(kv, attrs) do
    kv
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
    |> unique_constraint(:key)
  end
end

defimpl Jason.Encoder, for: Paginator.Page do
  def encode(page, opts) do
    Jason.Encode.map(Map.take(page, [:metadata, :entries]), opts)
  end
end

defimpl Jason.Encoder, for: Paginator.Page.Metadata do
  def encode(meta, opts) do
    Jason.Encode.map(Map.take(meta, [:after, :before, :limit, :total_count, :total_count_cap_exceeded]), opts)
  end
end

defimpl Jason.Encoder, for: Components.KV do
  def encode(kv, opts) do
    Jason.Encode.map(%{
      key: kv.key,
      value: Jason.decode!(kv.value),
      inserted_at: kv.inserted_at,
      updated_at: kv.updated_at
    }, opts)
  end
end

defmodule Components.KvDbHandler do
  alias Components.KV
  alias FunctionServerBasedOnArweave.Repo

  import Ecto.Query

  @default_paging_limit 50
  @default_sort :desc

  def get(k) when not is_bitstring(k), do: get(to_string(k))

  def get(k, default_value \\ nil) do
    result = Repo.one(from p in KV, where: p.key == ^k)

    if result == nil, do: default_value, else: Jason.decode!(result.value) |> ExStructTranslator.to_atom_struct()
  end

  def put(k, v) when not is_bitstring(k), do: put(to_string(k), v)

  def put(k, v) do
    v_str = Jason.encode!(v)

    case Repo.one(from p in KV, where: p.key == ^k) do
      nil ->
        %KV{key: k, value: v_str}
      val ->
        val
    end
    |> KV.changeset(%{ value: v_str })
    |> Repo.insert_or_update!()
  end

  def all([]) do
    all([limit: @default_paging_limit, sort: @default_sort])
  end

  def all(opts) do
    query = from p in KV

    {sort, remained_opts} = Keyword.pop(opts, :sort, @default_sort)
    valid_opts =
      Keyword.filter(remained_opts, fn {key, _val} ->
        key in [:before, :after, :limit]
      end)
      |> Keyword.put(:cursor_fields, [{:updated_at, sort}])
      |> Keyword.put(:include_total_count, true)

    Repo.paginate(query, valid_opts)
  end
end
