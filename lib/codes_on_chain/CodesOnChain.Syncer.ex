defmodule CodesOnChain.Syncer do
  @moduledoc """
    Genserver as Syncer
  """
  use GenServer
  require Logger

  alias FunctionServerBasedOnArweave.CodeRunnerSpec
  alias Components.ExHttp

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
    case init_db(syncer_name) do
      {:ok, db_ref} ->
        contract_id =
          init_chain_and_contract(db_ref, chain_name, api_explorer, api_key, contract_addr)

        sync_after_interval()

        {:ok,
         %{
           syncer_name: syncer_name,
           db_ref: db_ref,
           api_key: api_key,
           contract_id: contract_id
         }}

      {:error, reason} ->
        Logger.error(reason)
        :ignore
    end
  end

  def terminate(reason, %{db_ref: db_ref, syncer_name: syncer_name}) do
    Logger.error("#{syncer_name} terminates due to #{inspect(reason)}")

    case :rocksdb.close(db_ref) do
      {:error, err} ->
        Logger.info("Closing rocksdb error: #{inspect(err)}")
        :ok

      _ ->
        :ok
    end
  end

  def handle_info(:sync, state) do
    %{
      db_ref: db_ref,
      api_key: api_key,
      contract_id: contract_id
    } = state

    contract = db_get(db_ref, contract_id)

    sync(db_ref, api_key, contract)

    sync_after_interval()
    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    %{db_ref: db_ref} = state
    val = db_get(db_ref, key)

    {:reply, val, state}
  end

  def handle_call(:all, _from, %{db_ref: db_ref} = state) do
    {:reply, db_all(db_ref), state}
  end

  # +-----------+
  # Public API that can be invoked by CodeRunner
  # +-----------+
  def init_db(syncer_name) do
    db_path = :code.priv_dir(:function_server_based_on_arweave)
    opts = [create_if_missing: true]

    :rocksdb.open(String.to_charlist("#{db_path}/db_#{syncer_name}/"), opts)
  end

  def get_from_db(syncer_name, key) do
    GenServer.call(ensure_atom(syncer_name), {:get, key})
  end

  def all_from_db(syncer_name) do
    GenServer.call(ensure_atom(syncer_name), :all)
  end

  # +-------------+
  # Internal Methods
  # +-------------+
  defp init_chain_and_contract(db_ref, chain_name, api_explorer, api_key, contract_addr) do
    contract_id = get_contract_id(contract_addr)

    case db_get(db_ref, contract_id) do
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

        db_put(db_ref, contract_id, contract)

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

  defp sync(db_ref, api_key, contract) do
    best_block = get_blockheight(contract.endpoint)

    do_sync(db_ref, api_key, contract, best_block)

    db_put(db_ref, contract.id, %{contract | last_block: best_block + 1})
  end

  defp do_sync(db_ref, api_key, contract, best_block) do
    {:ok, %{"result" => txs}} =
      get_txs_by_contract_addr(
        contract.api_explorer,
        api_key,
        contract.addr,
        contract.last_block,
        best_block
      )

    handle_txs(db_ref, contract, txs)
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
  defp handle_txs(db_ref, contract, txs) do
    abi = Jason.decode!(contract.abi)

    Enum.each(txs, fn tx ->
      handle_tx(db_ref, contract, abi, ExStructTranslator.to_atom_struct(tx))
    end)
  end

  defp handle_tx(_db_ref, _contract, _abi, tx) when tx.txreceipt_status != "1" do
    :ignore
  end

  defp handle_tx(db_ref, contract, abi, tx) do
    data = find_and_decode_func(abi, tx.input)

    do_handle_tx(db_ref, contract, tx, data)
  end

  def do_handle_tx(
        db_ref,
        contract,
        %{from: from, to: to, value: value},
        {%{function: func_name}, data}
      ) do
    # Logger.info("--- handling tx #{func_name} for #{inspect(data)}")
    handle_tx_type(db_ref, contract, func_name, from, to, value, data)
  end

  def do_handle_tx(_db_ref, _contract, _tx, _others) do
    :pass
  end

  def handle_tx_type(db_ref, _contract, func, _from, _to, _value, [_from_bin, to_bin, token_id])
      when func in ["safeTransferFrom", "transferFrom"] do
    nft = db_get(db_ref, token_id)

    if nft != nil do
      Logger.info("Updating nft #{token_id} owner: #{bin_to_addr(to_bin)}")
      db_put(db_ref, token_id, %{nft | owner: bin_to_addr(to_bin)})
    end
  end

  def handle_tx_type(db_ref, contract, "claim", from, _to, _value, [token_id]) do
    %{id: nft_c_id, addr: addr, endpoint: endpoint} = contract
    nft = db_get(db_ref, token_id)

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

      db_put(db_ref, token_id, nft)
    end
  end

  def handle_tx_type(_others, _, _, _, _, _, _) do
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
  defp db_get(db_ref, k) when not is_bitstring(k), do: db_get(db_ref, to_string(k))

  defp db_get(db_ref, k, default_value \\ nil) do
    case :rocksdb.get(db_ref, k, []) do
      :not_found ->
        default_value

      {:ok, val} ->
        Logger.info("Got value for #{k} from DB")

        Jason.decode!(val)
        |> ExStructTranslator.to_atom_struct()
    end
  end

  defp db_put(db_ref, k, v) when not is_bitstring(k), do: db_put(db_ref, to_string(k), v)

  defp db_put(db_ref, k, v) do
    Logger.info("Putting #{k} into DB")
    :rocksdb.put(db_ref, k, Jason.encode!(v), [])
  end

  defp db_all(db_ref) do
    case :rocksdb.iterator(db_ref, []) do
      {:ok, itr_handle} ->
        data = db_loop_through_iterator(itr_handle, %{}, :first)
        :rocksdb.iterator_close(itr_handle)
        data

      {:error, err} ->
        Logger.info("Creating iterator error: #{inspect(err)}")
        []
    end
  end

  defp db_loop_through_iterator(itr_handle, result, action \\ :next) do
    case :rocksdb.iterator_move(itr_handle, action) do
      {:ok, key, value} ->
        db_loop_through_iterator(itr_handle, Map.put(result, key, Jason.decode!(value)))

      {:ok, key} ->
        db_loop_through_iterator(itr_handle, Map.put(result, key, nil))

      {:error, err} ->
        Logger.info("Looping iterator error: #{inspect(err)}")
        result
    end
  end

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
