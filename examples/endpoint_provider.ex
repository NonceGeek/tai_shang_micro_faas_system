defmodule CodesOnChain.EndpointProvider do
  @moduledoc """
    Provide Endopoints of multi-chain by func
  """

  @endpoints %{
    "ethereum" => "https://mainnet.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
    "polygon" => "https://polygon-rpc.com",
    "moonbeam" => "https://rpc.api.moonbeam.network",
    "arweave" => "https://arweave.net"
  }

  def get_module_doc, do: @moduledoc

  @spec get_endpoints() :: map()
  def get_endpoints(), do: @endpoints

end
