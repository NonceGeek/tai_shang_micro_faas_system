defmodule CodesOnChain.Syncer do
  @moduledoc """
    Genserver as Syncer
  """
  use GenServer
  require Logger

  alias Ethereumex.HttpClient
  alias FunctionServerBasedOnArweave.CodeRunnerSpec

  # 1 minutes
  @sync_interval 10_000
  @default_user_agent "faas syncer"
  @chain %{
    name: "moonbeam",
    addr: "0xb6fc950c4bc9d1e4652cbedab748e8cdcfe5655f",
    api_explorer: "https://api-moonbeam.moonscan.io/",
    endpoint: "https://rpc.api.moonbeam.network/",
    api_key: "Y6AIFQQVAJ3H38CC11QFDUDJWAWNCWE3U8"
  }

  # +-----------+
  # | GenServer |
  # +-----------+
  def start_link([contract_addr: contract_addr] = args) do
    GenServer.start_link(__MODULE__, args, name: :"syncer_#{contract_addr}")
  end

  @doc """
    init -> hand_info(init) -> sync_routine
  """
  def init([contract_addr: contract_addr] = args) do
    case init_db() do
      {:ok, db_ref} ->
        sync_after_interval()
        {:ok, %{db_ref: db_ref, contract_addr: contract_addr}}

      {:error, reason} ->
        Logger.error(reason)
        :ignore
    end
  end

  defp init_db() do
    db_path = :code.priv_dir(:function_server_based_on_arweave)
    opts = [create_if_missing: true]

    :rocksdb.open(String.to_charlist("#{db_path}/db/"), opts)
  end

  def handle_info(:sync, state) do
    %{db_ref: db_ref, contract_addr: contract_addr} = state

    contract =
      db_get(db_ref, get_contract_id(state), %{contract_addr: contract_addr, last_block: 1})

    sync(db_ref, contract)

    sync_after_interval()
    {:noreply, state}
  end

  defp get_contract_id(contract) do
    "contract_#{contract.contract_addr}"
  end

  defp sync_after_interval() do
    Process.send_after(self(), :sync, @sync_interval)
  end

  defp sync(db_ref, %{last_block: last_block} = contract) do
    endpoint = get_endpoint(@chain.name)
    best_block = get_blockheight(@chain.name, endpoint)
    contract_id = get_contract_id(contract)

    do_sync(db_ref, contract, best_block)

    updated_contract = Map.put(contract, :last_block, best_block + 1)

    db_put(db_ref, contract_id, updated_contract)
  end

  defp do_sync(db_ref, contract, best_block) do
    {:ok, %{"result" => txs}} =
      get_txs_by_contract_addr(
        contract.addr,
        contract.last_block,
        best_block
      )

    handle_txs(db_ref, contract, txs)
  end

  defp get_txs_by_contract_addr(
         contract_addr,
         start_block,
         end_block,
         asc_or_desc \\ :asc
       ) do
    url =
      "#{@chain.api_explorer}api?module=account&action=txlist&address="
      |> Kernel.<>("#{contract_addr}&startblock=")
      |> Kernel.<>("#{start_block}&endblock=#{end_block}&sort=")
      |> Kernel.<>("#{asc_or_desc}&apikey=")
      |> Kernel.<>("#{@chain.api_key}")

    Logger.info("call url: #{url}")
    http_get(url)
  end

  defp handle_txs(db_ref, contract, txs) do
    contract_id = get_contract_id(contract)

    Enum.each(txs, fn tx ->
      Logger.info("Handling tx: #{inspect(tx)}")
      tx_atom_map = ExStructTranslator.to_atom_struct(tx)
      # db_put(db_ref, contract_id, tx)
    end)
  end

  defp get_endpoint(chain_name) do
    "ghBIjdbs2HpGM0Huy3IV0Ynm9OOWxDLkcW6q0X7atqs"
    |> CodeRunnerSpec.run_ex_on_chain("get_endpoints", [])
    |> Map.get(chain_name)
  end

  defp get_blockheight(chain_name, endpoint) do
    # CodeRunnerSpec.run_ex_on_chain(
    #   "-6TxJsLSeoXfEhKfGzG5-n65QpAbuiwp4fO_7-2A-vA",
    #   "get_best_block_height",
    #   [chain_name, endpoint]
    # )
    # CodesOnChain.BestBlockHeightGetter.get_best_block_height(chain_name, endpoint)
    {:ok, hex} = HttpClient.eth_block_number(url: endpoint)
    hex_to_int(hex)
  end

  defp db_get(db_ref, k, default_value \\ nil) do
    case :rocksdb.get(db_ref, k, []) do
      :not_found ->
        default_value

      {:ok, val} ->
        Jason.decode!(val)
    end
  end

  defp db_put(db_ref, k, v) do
    # encode = Keyword.get(opts, :encode, &encode_data/1)
    :rocksdb.put(db_ref, k, Jason.encode!(v), [])
  end

  defp http_get(url) do
    http_get(url, 5)
  end

  defp http_get(_url, retries) when retries == 0 do
    {:error, "retires #{@retries} times and not success"}
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
