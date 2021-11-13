defmodule FunctionServerBasedOnArweave.ArExHandler do

  # +---------+
  # | Fetcher |
  # +---------+
  def get_ex_by_tx_id(node, tx_id) do
    {:ok, %{"Content-Type": type}} =ArweaveSdkEx.get_tx(node, tx_id)
    do_get_ex_by_tx_id(node, tx_id, type)
  end

  def do_get_ex_by_tx_id(node, tx_hash, "application/elixir") do
    {:ok, %{content: content}} = ArweaveSdkEx.get_content_in_tx(node, tx_hash)
    {:ok, content}
  end

  def do_get_ex_by_tx_id(_node, _tx_id, _other_type) do
    {:error, "it's not a elixir func"}
  end

  # +--------+
  # | runner |
  # +--------+

  def run_ex(code, params_map) do
    params_list = Map.to_list(params_map)
    {result, _} = Code.eval_string(code,params_list, __ENV__)
    %{result: result, input: params_map}
  end
end
