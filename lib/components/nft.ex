defmodule Components.NFT do
  alias Components.Contract
  alias Components.NFT, as: Ele
  alias FunctionServerBasedOnArweave.Repo
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @default_paging_limit 50
  @default_sort :desc

  schema "nft" do
    field :token_id, :integer
    field :owner, :string
    field :uri, :string

    belongs_to :contract, Contract
    timestamps()
  end

  def create(attrs \\ %{}) do
    %Ele{}
    |> Ele.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Ele{} = ele, attrs) do
    ele
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc false
  def changeset(kv, attrs) do
    kv
    |> cast(attrs, [:token_id, :owner, :contract_id, :uri])
    |> validate_required([:token_id, :owner, :contract_id, :uri])
  end

  def get_by_contract_id(contract_id) do
    Ele
    |> where([n], n.contract_id == ^contract_id)
    |> order_by([n], [desc: n.updated_at])
    |> Repo.paginate(
      cursor_fields: [{:updated_at, @default_sort}],
        limit: @default_paging_limit)
  end

  def get_by_contract_id(contract_id, cursor_after) do
    Ele
    |> where([n], n.contract_id == ^contract_id)
    |> order_by([n], [desc: n.updated_at])
    |> Repo.paginate(
        cursor_fields: [{:updated_at, @default_sort}],
        after: cursor_after,
        limit: @default_paging_limit)
  end

  def get_by_contract_id_and_token_id(contract_id, token_id) do
    Ele
    |> where([n], n.contract_id == ^contract_id and n.token_id == ^token_id)
    |> Repo.one()
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

defimpl Jason.Encoder, for: Components.NFT do
  def encode(nft, opts) do
    Jason.Encode.map(nft, opts)
  end
end

# defmodule Components.NFTHandler do
#   alias Components.NFT
#   alias FunctionServerBasedOnArweave.Repo

#   import Ecto.Query

#   @default_paging_limit 50
#   @default_sort :desc

#   def get(k) when not is_bitstring(k), do: get(to_string(k))

#   def get(k, default_value \\ nil) do
#     result = Repo.one(from p in KV, where: p.key == ^k)

#     if result == nil, do: default_value, else: Jason.decode!(result.value) |> ExStructTranslator.to_atom_struct()
#   end

#   def put(k, v) when not is_bitstring(k), do: put(to_string(k), v)

#   def put(k, v) do
#     v_str = Jason.encode!(v)

#     case Repo.one(from p in KV, where: p.key == ^k) do
#       nil ->
#         %NFT{key: k, value: v_str}
#       val ->
#         val
#     end
#     |> KV.changeset(%{ value: v_str })
#     |> Repo.insert_or_update!()
#   end

#   def all([]) do
#     all([limit: @default_paging_limit, sort: @default_sort])
#   end

#   def all(opts) do
#     query = from p in KV

#     {sort, remained_opts} = Keyword.pop(opts, :sort, @default_sort)
#     valid_opts =
#       Keyword.filter(remained_opts, fn {key, _val} ->
#         key in [:before, :after, :limit]
#       end)
#       |> Keyword.put(:cursor_fields, [{:updated_at, sort}])
#       |> Keyword.put(:include_total_count, true)

#     Repo.paginate(query, valid_opts)
#   end
# end
