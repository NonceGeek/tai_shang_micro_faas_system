defmodule Components.VerifierTest do
  use ExUnit.Case

  alias Components.Verifier

  test "valid verify message" do
    assert true ==
             Verifier.verify_message?(
               "0x132b9dbb51f336d6f43e4b8078b5c5ae737e2ef9",
               "test",
               "0x57d23d24c09c627f17b9696df8ce442ee719aa0a8e7d888dea25b39cd740c4b661cc2c2901af114f44e1c43d09660db728d1ee334878217a96894bca5eada4b21b"
             )
  end

  test "invalid verify message" do
    assert false ==
             Verifier.verify_message?(
               "0x132b9dbb51f336d6f43e4b8078b5c5ae737e2ef9",
               "test",
               "0x66d23d24c09c627f17b9696df8ce442ee719aa0a8e7d888dea25b39cd740c4b661cc2c2901af114f44e1c43d09660db728d1ee334878217a96894bca5eada4b21b"
             )
  end

  test "chinese valid message" do
    # [
    #   "0x304ff6da456b9f5a2c19de06ff4a74e22889379135dce6af87ae683297993a2e",
    #   "0x2913825F11434A5070797D32df3a892E28d891a0",
    #   "{\"title\":\"测试\",\"host\":\"test\",\"description\":\"test\",\"url\":\"test\",\"period\":[\"2022-05-09 05:05\",\"2022-05-09 09:04\"]}",
    #   "0xe19a78ca62a03f2006abb1c006f6839bc6d213361a7c42d24a48b0c924dca39a0eb4fc21242ab82b9b0bed862eff098bd8d2e926fdf98504347e3cea439b1ebb1c"
    # ]
    # |> IO.inspect()

    message =
      "{\"title\":\"测试\",\"host\":\"test\",\"description\":\"test\",\"url\":\"test\",\"period\":[\"2022-05-09 05:05\",\"2022-05-09 09:04\"]}"

    public_address = "0x2913825F11434A5070797D32df3a892E28d891a0"

    sig =
      "0xe19a78ca62a03f2006abb1c006f6839bc6d213361a7c42d24a48b0c924dca39a0eb4fc21242ab82b9b0bed862eff098bd8d2e926fdf98504347e3cea439b1ebb1c"

    assert true ==
             Verifier.verify_message?(
               public_address,
               message,
               sig
             )
  end
end
