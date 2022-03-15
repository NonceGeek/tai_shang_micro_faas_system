defmodule FunctionServerBasedOnArweave.CodeRunnerSpec do
  alias ArweaveSdkEx.CodeRunner

  alias FunctionServerBasedOnArweave.OnChainCode
  def run_ex_on_chain(tx_id, func_name, input_list) do
    # Fetch tx on chain.
    # Save to database
    with {:ok, %{content: code}} <- CodeRunner.get_content_in_tx(ArweaveNode.get_node(), tx_id),
      {:ok, _ele} <- OnChainCode.create_or_query_by_tx_id(tx_id) do
      # Load Module
      # Run func
      moduel_name = OnChainCode.get_module_name_from_code(code)
      OnChainCode.load_code(code)
      CodeRunner.run_func(
        moduel_name,
        func_name,
        input_list
      )
    else
      error ->
        {:error, inspect(error)}
    end
  end
end
