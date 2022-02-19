defmodule CodesOnChain.GetBestBlockHeight do
  @moduledoc """
    This is an code-on-chain example:
      Shows how to get the current block height on dif chain.
  """

  @spec get_block_height(chain_type: String, endpoint: String) :: integer()
  def get_best_block_height("Ethereum", endpoint) do
    1
  end

  def get_best_block_height("Arweave", endpoint) do
    1
  end

end
