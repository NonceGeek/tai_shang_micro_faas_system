defmodule Components.NFTTest do
  use ExUnit.Case

  alias Components.NFT

  @addr "0x359b4a82699be545c4fd930df93deeea0827ead7"

  test "a contract has nfts" do
    assert NFT.has_nft?(@addr) == true
  end

  test "a contract do not has nfts" do
    assert NFT.has_nft?("") == false
  end

  test "a contract fetch all nfts" do
    assert NFT.fetch_all_nft(@addr) |> length() == 6
  end

  test "a contract does't have any nft, but it want to fetch all nfts" do
    assert NFT.fetch_all_nft("0x000000") |> length() == 0
  end

  test "contracts have nfts? " do
    %{"0x000000" => no, @addr => yes} = NFT.multi_contracts_have_nft?([@addr, "0x000000"])
    assert no == false
    assert yes == true
  end
end
