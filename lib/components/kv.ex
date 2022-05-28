defmodule Components.KV do
  alias Components.KV

  use Ecto.Schema
  import Ecto.Changeset

  schema "kv" do
    field :key, :string
    field :value, :string
    field :created_by, :string

    timestamps()
  end

  @doc false
  def changeset(kv, attrs) do
    kv
    |> cast(attrs, [:key, :value, :created_by])
    |> validate_required([:key, :value, :created_by])
    |> unique_constraint(:key_and_created_by, name: :key_and_created_by)
  end
end

defmodule Components.KVHandler do
  alias Components.KV
  alias FunctionServerBasedOnArweave.Repo

  import Ecto.Query

  def get(k, created_by) do
    result = Repo.one(from kv in KV, where: kv.key == ^k and kv.created_by == ^created_by)
    do_get(result)
  end

  defp do_get(nil), do: nil
  defp do_get(%{value: value}) do
    result_decoded = Poison.decode(value)
    case result_decoded do
      {:error, _reason} ->
        value
      {:ok, payload} ->
        ExStructTranslator.to_atom_struct(payload)
    end
  end

  def get_by_module_name(created_by) do
    KV
    |> where([kv], kv.created_by== ^created_by)
    |> Repo.all()
  end

  def put(k, v, module_name) when not is_bitstring(k), do: put(to_string(k), v, module_name)

  def put(k, v, module_name) do
    v_str = Poison.encode!(v)

    case Repo.one(from p in KV, where: p.key == ^k) do
      nil ->
        %KV{key: k, value: v_str, created_by: module_name}
      val ->
        val
    end
    |> KV.changeset(%{ value: v_str})
    |> Repo.insert_or_update()
  end

  def get_all() do
    Repo.all(KV)
  end

  # def all([]) do
  #   all([limit: @default_paging_limit, sort: @default_sort])
  # end

  # def all(opts) do
  #   query = from p in KV

  #   {sort, remained_opts} = Keyword.pop(opts, :sort, @default_sort)
  #   valid_opts =
  #     Keyword.filter(remained_opts, fn {key, _val} ->
  #       key in [:before, :after, :limit]
  #     end)
  #     |> Keyword.put(:cursor_fields, [{:updated_at, sort}])

  #   Repo.paginate(query, valid_opts)
  # end
end

defmodule Components.KVHandler.KVRouter do

  @external_resource "priv/extra_routes.json"

  def get_routes() do
    @external_resource
    |> File.read!()
    |> Poison.decode!()
  end

  @doc """
    for example:
      [["/uri1", "TestLive", "index"]]
  """
  def put_routes(routes) do

    payload =
      get_routes()
      |> Kernel.++(routes)
      |> Poison.encode!()

    File.write!(
      "priv/extra_routes.json",
      payload
    )

    Code.eval_file("lib/function_server_based_on_arweave_web/router.ex")
    # IEx.Helpers.r(FunctionServerBasedOnArweaveWeb.Router)
  end

end
