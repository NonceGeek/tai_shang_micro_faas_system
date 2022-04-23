defmodule CodesOnChain.Syncer do
  @moduledoc """
    Genserver as Syncer
  """
  use GenServer
  require Logger

  alias FunctionServerBasedOnArweave.CodeRunnerSpec

  # 1 minutes
  @sync_interval 60_000
  @retries 5
  @default_user_agent "faas syncer"

  # +-----------+
  # | GenServer |
  # +-----------+
  # Startup this Syncer using similar parameters.  Currently only support Moonbeam
  # [
      # chain_name: "moonbeam",
      # api_explorer: "https://api-moonbeam.moonscan.io/",
      # api_key: "Y6AIFQQVAJ3H38CC11QFDUDJWAWNCWE3U8",
      # contract_addr: "0xb6fc950c4bc9d1e4652cbedab748e8cdcfe5655f"
  # ]
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(
        [
          chain_name: chain_name,
          api_explorer: api_explorer,
          api_key: api_key,
          contract_addr: contract_addr
        ] = _args
      ) do
    Process.flag(:trap_exit, true)

    case init_db() do
      {:ok, db_ref} ->
        sync_after_interval()

        {:ok,
         %{
           db_ref: db_ref,
           chain_name: chain_name,
           api_explorer: api_explorer,
           api_key: api_key,
           contract_addr: contract_addr
         }}

      {:error, reason} ->
        Logger.error(reason)
        :ignore
    end
  end

  def init_db() do
    db_path = :code.priv_dir(:function_server_based_on_arweave)
    opts = [create_if_missing: true]

    :rocksdb.open(String.to_charlist("#{db_path}/db/"), opts)
  end

  def get_from_db(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def all_from_db() do
    GenServer.call(__MODULE__, :all)
  end

  def terminate(reason, %{db_ref: db_ref}) do
    Logger.error("${__MODULE__} terminates due to #{reason}")
    case :rocksdb.close(db_ref) do
      {:error, err} ->
        IO.puts("Closing rocksdb error: #{inspect(err)}")
        :ok

      _ ->
        :ok
    end
  end

  def handle_info(:sync, state) do
    %{
      db_ref: db_ref,
      chain_name: chain_name,
      api_explorer: api_explorer,
      api_key: api_key,
      contract_addr: contract_addr
    } = state

    contract =
      db_get(db_ref, get_contract_id(state), %{contract_addr: contract_addr, last_block: 1})

    sync(db_ref, chain_name, api_explorer, api_key, contract)

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

  defp get_contract_id(contract) do
    "contract_#{contract.contract_addr}"
  end

  defp sync_after_interval() do
    Process.send_after(self(), :sync, @sync_interval)
  end

  defp sync(db_ref, chain_name, api_explorer, api_key, contract) do
    endpoint = get_endpoint(chain_name)
    best_block = get_blockheight(endpoint)
    contract_id = get_contract_id(contract)

    do_sync(db_ref, api_explorer, api_key, contract, best_block)

    updated_contract = Map.put(contract, :last_block, best_block + 1)

    db_put(db_ref, contract_id, updated_contract)
  end

  defp do_sync(db_ref, api_explorer, api_key, contract, best_block) do
    {:ok, %{"result" => txs}} =
      get_txs_by_contract_addr(
        api_explorer,
        api_key,
        contract.contract_addr,
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

    Logger.info("call url: #{url}")
    http_get(url)
  end

  defp handle_txs(db_ref, _contract, txs) do
    # contract_id = get_contract_id(contract)

    Enum.each(txs, fn tx ->
      tx_atom_map = ExStructTranslator.to_atom_struct(tx)
      db_put(db_ref, tx_atom_map.hash, tx_atom_map)
    end)
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
      http_post(endpoint, %{
        "jsonrpc" => "2.0",
        "method" => "eth_blockNumber",
        "params" => [],
        "id" => 83
      })

    Map.get(res, "result")
    |> hex_to_int()
  end

  defp db_get(db_ref, k, default_value \\ nil) do
    case :rocksdb.get(db_ref, k, []) do
      :not_found ->
        default_value

      {:ok, val} ->
        IO.puts("Got value for #{k} from DB")

        Jason.decode!(val)
        |> ExStructTranslator.to_atom_struct()
    end
  end

  defp db_put(db_ref, k, v) do
    # encode = Keyword.get(opts, :encode, &encode_data/1)
    IO.puts("Putting #{k} into DB")
    :rocksdb.put(db_ref, k, Jason.encode!(v), [])
  end

  defp db_all(db_ref) do
    case :rocksdb.iterator(db_ref, []) do
      {:ok, itr_handle} ->
        data = db_loop_through_iterator(itr_handle, %{}, :first)
        :rocksdb.iterator_close(itr_handle)
        data

      {:error, err} ->
        IO.puts("Creating iterator error: #{inspect(err)}")
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
        IO.puts("Looping iterator error: #{inspect(err)}")
        result
    end
  end

  defp http_get(url) do
    http_get(url, @retries)
  end

  defp http_get(_url, retries) when retries == 0 do
    {:error, "GET retires #{@retries} times and not success"}
  end

  defp http_get(url, retries) do
    url
    |> HTTPoison.get([{"User-Agent", @default_user_agent}],
      hackney: [headers: [{"User-Agent", @default_user_agent}]]
    )
    |> handle_response()
    |> case do
      {:ok, body} ->
        {:ok, body}

      {:error, _} ->
        Process.sleep(500)
        http_get(url, retries - 1)
    end
  end

  defp http_post(url, data) do
    http_post(url, data, @retries)
  end

  defp http_post(_url, _data, retries) when retries == 0 do
    {:error, "POST retires #{@retries} times and not success"}
  end

  defp http_post(url, data, retries) do
    body = Jason.encode!(data)

    url
    |> HTTPoison.post(
      body,
      [{"User-Agent", @default_user_agent}, {"Content-Type", "application/json"}],
      hackney: [headers: [{"User-Agent", @default_user_agent}]]
    )
    |> handle_response()
    |> case do
      {:ok, body} ->
        {:ok, body}

      {:error, _} ->
        Process.sleep(500)
        http_post(url, data, retries - 1)
    end
  end

  # normal
  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}})
       when status_code in 200..299 do
    case Poison.decode(body) do
      {:ok, json_body} ->
        {:ok, json_body}

      {:error, payload} ->
        Logger.error("Reason: #{inspect(payload)}")
        {:error, :network_error}
    end
  end

  # 404 or sth else
  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: _}}) do
    Logger.error("Reason: #{status_code} ")
    {:error, :network_error}
  end

  defp handle_response(error) do
    Logger.error("Reason: other_error")
    error
  end

  defp hex_to_int(hex) do
    hex
    |> String.slice(2..-1)
    |> String.to_integer(16)
  end
end
