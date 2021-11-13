defmodule FunctionServerBasedOnArweaveWeb.FunctionRunnerController do
  use FunctionServerBasedOnArweaveWeb, :controller
  @node Application.fetch_env!(:function_server_based_on_arweave, :arweave_endpoint)

  alias FunctionServerBasedOnArweave.ArExHandler
  def run(conn, payload) do
    %{tx_id: tx_id, params: params} =
      ExStructTranslator.to_atom_struct(payload)
    {:ok, code} = ArExHandler.get_ex_by_tx_id(@node, tx_id)
    result =
      code
      |> ArExHandler.run_ex(params)
      |> Map.put(:code_online, @node <> "/" <> tx_id)
    json(conn, result)
  end
end
