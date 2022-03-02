defmodule CodesOnChain.BestBlockHeightGetter do
  @moduledoc """
    This is an code-on-chain example:
      Shows how to get the current block height on dif chain.
  """

  def get_module_doc, do: @moduledoc

  @spec get_best_block_height(String.t(), String.t()) :: integer()
  def get_best_block_height("ethereum", endpoint) do
    {:ok, height} = Ethereumex.HttpClient.eth_block_number(url: endpoint)
    height |> String.slice(2..-1) |> String.to_integer(16)
  end

  def get_best_block_height("arweave", endpoint) do
    ArweaveSdkEx.block_height(endpoint)
  end

end
