defmodule FunctionServerBasedOnArweave.CodeFetchers.NFTTest do
  use ExUnit.Case

  alias FunctionServerBasedOnArweave.CodeFetchers.NFT
  test "get from nft" do
    result = NFT.get_from_nft(1)
    assert result == "rr5p8_FJ4l0KvjhCtIzmxfBNN3UiN2Cv2Ml08ys9odE"
  end
end
