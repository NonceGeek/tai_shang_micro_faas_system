defmodule TaiShangMicroFaasSystem.CodeFetchers.NFTTest do
  use ExUnit.Case

  alias TaiShangMicroFaasSystem.CodeFetchers.NFT
  test "get from nft" do
    {r, _} = NFT.get_from_nft("1")
    assert r == :ok
  end
end
