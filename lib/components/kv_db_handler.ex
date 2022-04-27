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

defmodule Components.KvDbHandler do
  alias Components.KV
  alias FunctionServerBasedOnArweave.Repo

  import Ecto.Query

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

  def all() do
    Repo.all(from p in KV)
  end
end
