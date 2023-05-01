defmodule Components.NFT do
  alias Components.Contract
  alias Components.NFT, as: Ele
  alias TaiShangMicroFaasSystem.Repo
  alias TypeTranslator
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
    |> order_by([n], desc: n.updated_at)
    |> Repo.paginate(
      cursor_fields: [{:updated_at, @default_sort}],
      limit: @default_paging_limit
    )
  end

  def get_by_contract_id(contract_id, cursor_after) do
    Ele
    |> where([n], n.contract_id == ^contract_id)
    |> order_by([n], desc: n.updated_at)
    |> Repo.paginate(
      cursor_fields: [{:updated_at, @default_sort}],
      after: cursor_after,
      limit: @default_paging_limit
    )
  end

  def get_by_contract_id_and_token_id(contract_id, token_id) do
    Ele
    |> where([n], n.contract_id == ^contract_id and n.token_id == ^token_id)
    |> Repo.one()
  end

  def has_nft?(
        addr,
        contract_addr \\ "0xb6fc950c4bc9d1e4652cbedab748e8cdcfe5655f",
        endpoint \\ "https://rpc.api.moonbeam.network"
      ) do
    balance = get_contract_balance(addr, contract_addr, endpoint)

    if balance > 0 do
      true
    else
      false
    end
  end

  def multi_contracts_have_nft?(
        addrs,
        contract_addr \\ "0xb6fc950c4bc9d1e4652cbedab748e8cdcfe5655f",
        endpoint \\ "https://rpc.api.moonbeam.network"
      ) do
    addrs |> Map.new(fn x -> {x, has_nft?(x, contract_addr, endpoint)} end)
  end

  def fetch_all_nft(
        addr,
        contract_addr \\ "0xb6fc950c4bc9d1e4652cbedab748e8cdcfe5655f",
        endpoint \\ "https://rpc.api.moonbeam.network"
      ) do
    balance = get_contract_balance(addr, contract_addr, endpoint)

    if balance < 1 do
      []
    else
      0..(balance - 1)
      |> Enum.map(fn x -> get_contract_token_id(addr, x, contract_addr, endpoint) end)
      |> Enum.map(fn x ->
        %{
          :token_id => x,
          :token_uri => get_contract_token_uri(x, contract_addr, endpoint),
          :token_info => get_contract_token_info(x, contract_addr, endpoint)
        }
      end)
    end
  end

  defp do_get_from_chain(data, contract_addr, endpoint, with_retry \\ 0) do
    result =
      Ethereumex.HttpClient.eth_call(
        %{
          data: data,
          to: contract_addr
        },
        "latest",
        url: endpoint
      )

    case result do
      {:ok, value} ->
        {:ok, value}

      {:error, _} ->
        if with_retry < 3 do
          do_get_from_chain(data, contract_addr, endpoint, with_retry + 1)
        else
          {:error, "failed to get from chain with retry"}
        end
    end
  end

  defp get_contract_balance(addr, contract_addr, endpoint) do
    address = addr |> TypeTranslator.addr_to_bin()
    data = TypeTranslator.get_data("balanceOf(address)", [address])

    case do_get_from_chain(data, contract_addr, endpoint) do
      {:ok, result} -> result |> TypeTranslator.data_to_int()
      {:error, _} -> 0
    end
  end

  defp get_contract_token_id(addr, index, contract_addr, endpoint) do
    address = addr |> TypeTranslator.addr_to_bin()
    data = TypeTranslator.get_data("tokenOfOwnerByIndex(address, uint256)", [address, index])

    case do_get_from_chain(data, contract_addr, endpoint) do
      {:ok, result} -> result |> TypeTranslator.data_to_int()
      {:error, _} -> -1
    end
  end

  defp get_contract_token_info(token_id, contract_addr, endpoint) do
    data = TypeTranslator.get_data("getTokenInfo(uint256)", [token_id])

    case do_get_from_chain(data, contract_addr, endpoint) do
      {:ok, result} -> result |> TypeTranslator.data_to_str()
      {:error, _} -> ""
    end
  end

  defp get_contract_token_uri(token_id, contract_addr, endpoint) do
    data = TypeTranslator.get_data("tokenURI(uint256)", [token_id])

    case do_get_from_chain(data, contract_addr, endpoint) do
      {:ok, result} ->
        result
        |> TypeTranslator.data_to_str()
        |> String.split(",")
        |> Enum.at(-1)
        |> Base.decode64!()

      {:error, _} ->
        ""
    end
  end
end

defimpl Jason.Encoder, for: Paginator.Page do
  def encode(page, opts) do
    Jason.Encode.map(Map.take(page, [:metadata, :entries]), opts)
  end
end

defimpl Jason.Encoder, for: Paginator.Page.Metadata do
  def encode(meta, opts) do
    Jason.Encode.map(
      Map.take(meta, [:after, :before, :limit, :total_count, :total_count_cap_exceeded]),
      opts
    )
  end
end

defimpl Jason.Encoder, for: Components.NFT do
  def encode(nft, opts) do
    Jason.Encode.map(nft, opts)
  end
end
