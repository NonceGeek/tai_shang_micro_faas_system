defmodule CodesOnChain.Syncer do
  @moduledoc """
    Genserver as Syncer
  """
  use GenServer
  require Logger

  alias FunctionServerBasedOnArweave.CodeRunnerSpec
  alias Components.ExHttp
  alias Components.KvDbHandler

  # 1 minutes
  @sync_interval 10_000

  # modify here to put yourself nft info
  @params [
    syncer_name: "moonbeam_dao_nft",
    chain_name: "moonbeam",
    api_explorer: "https://api-moonbeam.moonscan.io/",
    api_key: "Y6AIFQQVAJ3H38CC11QFDUDJWAWNCWE3U8",
    contract_addr: "0xb6fc950c4bc9d1e4652cbedab748e8cdcfe5655f"
    ]
  def get_module_doc(), do: @moduledoc

  def start_link() do
    start_link(@params)
  end

  # +-----------+
  # | GenServer |
  # +-----------+
  # Startup this Syncer using similar parameters.  Currently only support Moonbeam
  # [
  # syncer_name: "moonbeam_xxx_nft",
  # chain_name: "moonbeam",
  # api_explorer: "https://api-moonbeam.moonscan.io/",
  # api_key: "Y6AIFQQVAJ3H38CC11QFDUDJWAWNCWE3U8",
  # contract_addr: "0xb6fc950c4bc9d1e4652cbedab748e8cdcfe5655f"
  # ]
  defp start_link(args) do
    chain_name = Keyword.fetch!(args, :chain_name)
    contract_addr = Keyword.fetch!(args, :contract_addr)

    args = Keyword.put_new(args, :syncer_name, String.to_atom("#{chain_name}_#{contract_addr}"))

    syncer_name =
      Keyword.fetch!(args, :syncer_name)
      |> ensure_atom()

    GenServer.start_link(__MODULE__, Keyword.put(args, :syncer_name, syncer_name),
      name: syncer_name
    )
  end

  def init(_args) do
    Process.flag(:trap_exit, true)

    [
      syncer_name: syncer_name,
      chain_name: chain_name,
      api_explorer: api_explorer,
      api_key: api_key,
      contract_addr: contract_addr
    ] = @params

    contract_id =
      init_chain_and_contract(chain_name, api_explorer, api_key, contract_addr)

    sync_after_interval()

    {:ok,
     %{
       syncer_name: syncer_name,
       api_key: api_key,
       contract_id: contract_id
     }}
  end

  def terminate(reason, %{syncer_name: syncer_name}) do
    Logger.error("#{syncer_name} terminates due to #{inspect(reason)}")

    :ok
  end

  def handle_info(:sync, state) do
    %{
      api_key: api_key,
      contract_id: contract_id
    } = state

    contract = KvDbHandler.get(contract_id)

    sync(api_key, contract)

    sync_after_interval()
    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    val = KvDbHandler.get(key)

    {:reply, val, state}
  end

  def handle_call({:all, opts}, _from, state) do
    {:reply, KvDbHandler.all(opts), state}
  end

  # +-----------+
  # Public API that can be invoked by CodeRunner
  # +-----------+
  def get_from_db(syncer_name, key) do
    GenServer.call(ensure_atom(syncer_name), {:get, key})
  end

  def all_from_db(syncer_name, opts \\ []) do
    GenServer.call(ensure_atom(syncer_name), {:all, opts})
  end

  # +-------------+
  # Internal Methods
  # +-------------+
  defp init_chain_and_contract(chain_name, api_explorer, api_key, contract_addr) do
    contract_id = get_contract_id(contract_addr)

    case KvDbHandler.get(contract_id) do
      nil ->
        contract_abi_string = get_contract_abi(api_explorer, api_key, contract_addr)
        endpoint = get_endpoint(chain_name)

        contract = %{
          id: contract_id,
          endpoint: endpoint,
          api_explorer: api_explorer,
          addr: contract_addr,
          last_block: 1,
          abi: contract_abi_string
        }

        KvDbHandler.put(contract_id, contract)

      _ ->
        :ok
    end

    contract_id
  end

  defp get_contract_abi(
         api_explorer,
         api_key,
         contract_addr
       ) do
    url =
      "#{api_explorer}api?module=contract&action=getabi&address=#{contract_addr}&apikey=#{api_key}"

    Logger.info("call url to get contract abi: #{url}")
    {:ok, %{"result" => contract_abi_string}} = ExHttp.http_get(url)
    contract_abi_string
  end

  defp get_contract_id(contract_addr) do
    "contract_#{contract_addr}"
  end

  defp sync_after_interval() do
    Process.send_after(self(), :sync, @sync_interval)
  end

  defp sync(api_key, contract) do
    best_block = get_blockheight(contract.endpoint)

    do_sync(api_key, contract, best_block)

    KvDbHandler.put(contract.id, %{contract | last_block: best_block + 1})
  end

  defp do_sync(api_key, contract, best_block) do
    {:ok, %{"result" => txs}} =
      get_txs_by_contract_addr(
        contract.api_explorer,
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

  defp get_endpoint(chain_name) do
    "ghBIjdbs2HpGM0Huy3IV0Ynm9OOWxDLkcW6q0X7atqs"
    |> CodeRunnerSpec.run_ex_on_chain("get_endpoints", [])
    |> Map.get(chain_name)
  end

  defp get_blockheight(endpoint) do
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

  # +-------------+
  # | Transaction Handling Funcs |
  # +-------------+
  defp handle_txs(contract, txs) do
    abi = Jason.decode!(contract.abi)

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

  def handle_tx_type(_contract, func, _from, _to, _value, [_from_bin, to_bin, token_id])
      when func in ["safeTransferFrom", "transferFrom"] do
    nft = KvDbHandler.get(token_id)

    if nft != nil do
      Logger.info("Updating nft #{token_id} owner: #{bin_to_addr(to_bin)}")
      KvDbHandler.put(token_id, %{nft | owner: bin_to_addr(to_bin)})
    end
  end

  def handle_tx_type(contract, "claim", from, _to, _value, [token_id]) do
    %{id: nft_c_id, addr: addr, endpoint: endpoint} = contract
    nft = KvDbHandler.get(token_id)

    if nft == nil do
      # INIT Token
      uri = get_token_uri(endpoint, addr, token_id)

      nft = %{
        uri: uri,
        owner: from,
        token_id: token_id,
        contract_id: nft_c_id
      }

      Logger.info("#{from} claims nft token: #{token_id}")

      KvDbHandler.put(token_id, nft)
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
        # wait 1 sec
        Process.sleep(1000)
        eth_call_repeat(data, contract_addr, func_name, endpoint)
    end
  end

  # +-------------+
  # | DB Utility Funcs |
  # +-------------+

  # +-------------+
  # | Basic Utility Funcs |
  # +-------------+
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
end
