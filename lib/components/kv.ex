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
    result = get_item(k, created_by)
    do_get(result)
  end

  def get_item(k, created_by) do
    Repo.one(from kv in KV, where: kv.key == ^k and kv.created_by == ^created_by)
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
    kv =
      case Repo.one(from p in KV, where: p.key == ^k) do
        nil ->
          %KV{key: k, value: v_str, created_by: module_name}
        val ->
          val
      end

    kv
    |> KV.changeset(%{value: v_str})
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
    get_routes()
    |> Kernel.++(routes)
    |> refresh_routes()

  end

  def del_routes(path) do
    get_routes()
    |> Enum.reject(fn [routes, _module, _fun] -> routes == path end)
    |> refresh_routes()
  end

  def refresh_routes(payload) do
    File.write!("priv/extra_routes.json", Poison.encode!(payload))

    Code.eval_file("lib/function_server_based_on_arweave_web/router.ex")
    # IEx.Helpers.r(FunctionServerBasedOnArweaveWeb.Router)
  end
end
