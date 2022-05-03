defmodule CodesOnChain.Syncer do
  @moduledoc """
    Genserver as Syncer
  """
  use GenServer
  require Logger

  alias Components.ExHttp
  alias Components.NFT
  alias Components.Contract

  # 1 minutes
  @sync_interval 10_000

  # modify here to put yourself nft info
  @params [
    chain_name: "Moonbeam",
    api_explorer: "https://api-moonbeam.moonscan.io",
    endpoint: "https://rpc.api.moonbeam.network",
    contract_addr: "0xb6fc950c4bc9d1e4652cbedab748e8cdcfe5655f"
    ]

  # +--------------+
  # | Public Funcs |
  # +--------------+
  def get_module_doc(), do: @moduledoc

  @doc """
    Start Syncer by api_key(it can be apply from blockchain explorer homepage).
    To sync nfts to local, so it's convinient to fetch all the nfts.
  """
  def start_link(api_key) do
    start_link(api_key, @params)
  end

  @doc """
    return exp:
    %Paginator.Page{
      entries: [
        nfts_list
      ],
      metadata: %Paginator.Page.Metadata{
        after: "g3QAAAABZAAKdXBkYXRlZF9hdHQAAAAJZAAKX19zdHJ1Y3RfX2QAFEVsaXhpci5OYWl2ZURhdGVUaW1lZAAIY2FsZW5kYXJkABNFbGl4aXIuQ2FsZW5kYXIuSVNPZAADZGF5YQNkAARob3VyYQVkAAttaWNyb3NlY29uZGgCYQBhAGQABm1pbnV0ZWETZAAFbW9udGhhBWQABnNlY29uZGELZAAEeWVhcmIAAAfm",
        before: nil,
        limit: 50,
        total_count: nil,
        total_count_cap_exceeded: nil
      }
    }

    just put the after or before as cursor_after or cursor_before param!
  """
  @spec get_by_contract_addr(String.t()) :: Paginator.Page.t()
  def get_by_contract_addr(addr) do
    %{id: id} = Contract.get_by_addr(addr)
    NFT.get_by_contract_id(id)
  end

  @spec get_by_contract_addr(String.t(), Stirng.t()) :: Paginator.Page.t()
  def get_by_contract_addr(addr, cursor_after) do
    %{id: id} = Contract.get_by_addr(addr)
    NFT.get_by_contract_id(id, cursor_after)
  end

  # +-----------+
  # | GenServer |
  # +-----------+
  # Startup this Syncer using similar parameters.  Currently only support Moonbeam
  # [
  # syncer_name: "moonbeam_xxx_nft",
  # chain_name: "moonbeam",
  # api_explorer: "https://api-moonbeam.moonscan.io/",
  # contract_addr: "0xb6fc950c4bc9d1e4652cbedab748e8cdcfe5655f"
  # ]
  defp start_link(api_key, args) do
    chain_name = Keyword.fetch!(args, :chain_name)
    contract_addr = Keyword.fetch!(args, :contract_addr)

    args = Keyword.put_new(args, :syncer_name, String.to_atom("#{chain_name}_#{contract_addr}"))

    syncer_name =
      Keyword.fetch!(args, :syncer_name)
      |> ensure_atom()

    args_handled =
      args
      |> Keyword.put(:syncer_name, syncer_name)
      |> Keyword.put(:api_key, api_key)

    GenServer.start_link(__MODULE__,args_handled, name: syncer_name)
  end

  def init(args) do
    Process.flag(:trap_exit, true)
    %{
      chain_name: chain_name,
      api_explorer: api_explorer,
      syncer_name: _syncer_name,
      endpoint: endpoint,
      api_key: api_key,
      contract_addr: contract_addr
    } = Enum.into(args, %{})

    api_explorer =
      handle_url(api_explorer)
    {:ok, contract} =
      init_chain_and_contract(chain_name, endpoint, api_explorer, api_key, contract_addr)

    sync_after_interval()

    {:ok,
     %{
        api_key: api_key,
        contract: contract,
        syncer_name: Keyword.get(args, :syncer_name)
     }}
  end

  def terminate(reason, %{syncer_name: syncer_name}) do
    Logger.error("#{syncer_name} terminates due to #{inspect(reason)}")
    :ok
  end

  def handle_info(:sync, state) do
    %{contract: contract, api_key: api_key} = state

    {:ok, contract_updated} =
      sync(api_key, contract)

    sync_after_interval()
    {:noreply, Map.put(state, :contract, contract_updated)}
  end

  # +------------------+
  # | DB Utility Funcs |
  # +------------------+

  # +------------------+
  # Internal Methods   |
  # +------------------+
  defp init_chain_and_contract(chain_name, endpoint, api_explorer, api_key, contract_addr) do

    contract = Contract.get_by_addr(contract_addr)

    if is_nil(contract) do
      # init contract
      abi = get_contract_abi(api_explorer, api_key, contract_addr)
      Contract.create_without_repeat(%{
        addr: contract_addr,
        abi: abi,
        chain_info: %{
          chain_name: chain_name,
          api_explorer: api_explorer,
          endpoint: endpoint
        },
        last_block: 0
      })
    else
      # return existed contract
      {:ok, contract}
    end
  end

  @spec get_contract_abi(String.t(), String.t(), String.t()) :: map()
  def get_contract_abi(
         api_explorer,
         api_key,
         contract_addr
       ) do
    url =
      "#{api_explorer}api?module=contract&action=getabi&address=#{contract_addr}&apikey=#{api_key}"

    Logger.info("call url to get contract abi: #{url}")
    {:ok, %{"result" => contract_abi_string}} = ExHttp.http_get(url)
    Poison.decode!(contract_abi_string)
  end

  defp sync_after_interval() do
    Process.send_after(self(), :sync, @sync_interval)
  end

  def sync(api_key, contract) do
    # get_best |> sync between |> update last_block to best_block
    best_block = get_best_block(contract.chain_info["endpoint"])

    do_sync(api_key, contract, best_block)
    Contract.update(contract, %{last_block: best_block + 1})
  end

  defp do_sync(api_key, contract, best_block) do
    {:ok, %{"result" => txs}} =
      get_txs_by_contract_addr(
        contract.chain_info["api_explorer"],
        api_key,
        contract.addr,
        contract.last_block,
        best_block
      )
    handle_txs(contract, txs)
  end

  defp get_txs_by_contract_addr(
         api_explorer,
         api_key,
         contract_addr,
         start_block,
         end_block,
         asc_or_desc \\ :asc
       ) do
    url =
      "#{api_explorer}api?module=account&action=txlist&address="
      |> Kernel.<>("#{contract_addr}&startblock=")
      |> Kernel.<>("#{start_block}&endblock=#{end_block}&sort=")
      |> Kernel.<>("#{asc_or_desc}&apikey=")
      |> Kernel.<>("#{api_key}")

    Logger.info("Get contract txs through url: #{url}")
    ExHttp.http_get(url)
  end

  def get_best_block(endpoint) do
    # case HttpClient.eth_block_number(url: endpoint) do
    #   {:ok, hex} ->
    #     hex_to_int(hex)
    #   {:error, err} ->
    #     IO.inspect(err)
    #     1
    # end
    {:ok, res} =
      ExHttp.http_post(endpoint, %{
        "jsonrpc" => "2.0",
        "method" => "eth_blockNumber",
        "params" => [],
        "id" => 1
      })

    Map.get(res, "result")
    |> hex_to_int()
  end

  # +----------------------------+
  # | Transaction Handling Funcs |
  # +----------------------------+
  defp handle_txs(%{abi: abi} = contract, txs) do

    Enum.each(txs, fn tx ->
      handle_tx(contract, abi, ExStructTranslator.to_atom_struct(tx))
    end)
  end

  defp handle_tx(__contract, _abi, tx) when tx.txreceipt_status != "1" do
    :ignore
  end

  defp handle_tx(contract, abi, tx) do
    data = find_and_decode_func(abi, tx.input)
    do_handle_tx(contract, tx, data)
  end

  def do_handle_tx(
        contract,
        %{from: from, to: to, value: value},
        {%{function: func_name}, data}
      ) do
    # Logger.info("--- handling tx #{func_name} for #{inspect(data)}")
    handle_tx_type(contract, func_name, from, to, value, data)
  end

  def do_handle_tx(__contract, _tx, _others) do
    :pass
  end

  # +------------------------+
  # | Spec NFT func handlers |
  # +------------------------+
  def do_handle_tx(%{id: c_id} = contract, "setTokenInfo", _from, _to, _value, [token_id, _badges_raw]) do
    nft = NFT.get_by_contract_id_and_token_id(c_id, token_id)
    %{addr: addr, chain_info: %{"endpoint" => endpoint}} = contract
      # UPDATE Badges & URI
      uri = get_token_uri(endpoint, addr, token_id)
      Logger.info("Updating nft #{token_id} uri: #{uri}")
      NFT.update(nft, %{uri: uri})
  end

  # +-------------------------+
  # | Utils NFT func handlers |
  # +-------------------------+

  def handle_tx_type(%{id: c_id}, func, _from, _to, _value, [_from_bin, to_bin, token_id])
      when func in ["safeTransferFrom", "transferFrom"] and token_id <= 2147483646 do
        nft = NFT.get_by_contract_id_and_token_id(c_id, token_id)

    if nft != nil do
      addr = bin_to_addr(to_bin)
      Logger.info("Updating nft #{token_id} owner: #{addr}")
      NFT.update(nft, %{owner: addr})
    end
  end

  def handle_tx_type(%{id: c_id} = contract, "claim", from, _to, _value, [token_id])
    when token_id <= 2147483646 do
    %{id: nft_c_id, addr: addr, chain_info: %{"endpoint" => endpoint}} =
      contract
    nft = NFT.get_by_contract_id_and_token_id(c_id, token_id)

    if nft == nil do
      # INIT Token
      uri = get_token_uri(endpoint, addr, token_id)

      payload = %{
        uri: uri,
        owner: from,
        token_id: token_id,
        contract_id: nft_c_id
      }

      Logger.info("#{from} claims nft token: #{token_id}")

      NFT.create(payload)
    end
  end

  def handle_tx_type(_contract, _others, _, _, _, _) do
    {:ok, "pass"}
  end

  defp get_token_uri(endpoint, contract_addr, token_id) do
    data = get_data("tokenURI(uint256)", [token_id])

    data
    |> eth_call_repeat(contract_addr, "latest", endpoint)
    |> data_to_str()
  end

  defp eth_call_repeat(data, contract_addr, func_name, endpoint) do
    # result =
    #   Ethereumex.HttpClient.eth_call(%{data: data, to: contract_addr}, func_name, url: endpoint)

    result =
      ExHttp.http_post(endpoint, %{
        "jsonrpc" => "2.0",
        "method" => "eth_call",
        "params" => [%{from: nil, to: contract_addr, data: data}, "latest"],
        "id" => 1
      })

    case result do
      {:ok, value} ->
        Map.get(value, "result")

      {:error, _} ->
        # wait 60 sec
        Process.sleep(60000)
        eth_call_repeat(data, contract_addr, func_name, endpoint)
    end
  end

  # +---------------------+
  # | Basic Utility Funcs |
  # +---------------------+
  defp hex_to_int(hex) do
    hex
    |> String.slice(2..-1)
    |> String.to_integer(16)
  end

  defp hex_to_bin(hex) do
    hex
    |> String.slice(2..-1)
    |> Base.decode16!(case: :lower)
  end

  defp bin_to_addr(bin) do
    "0x" <> Base.encode16(bin, case: :lower)
  end

  defp data_to_str(raw) do
    raw
    |> hex_to_bin()
    |> ABI.TypeDecoder.decode_raw([:string])
    |> List.first()
  end

  def find_and_decode_func(abi, input_hex) do
    abi
    |> ABI.parse_specification()
    |> ABI.find_and_decode(hex_to_bin(input_hex))
  end

  defp get_data(func_str, params) do
    payload =
      func_str
      |> ABI.encode(params)
      |> Base.encode16(case: :lower)

    "0x" <> payload
  end

  defp ensure_atom(val) when is_atom(val), do: val
  defp ensure_atom(val), do: to_string(val) |> String.to_atom()

  defp handle_url(""), do: ""
  defp handle_url(url) do
    if String.at(url, -1) == "/" do
      url
    else
      url <> "/"
    end
  end
end
