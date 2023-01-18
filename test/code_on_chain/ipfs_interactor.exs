defmodule CodeOnChain.SoulCard.IpfsInteractorTest do
  use ExUnit.Case

  alias CodesOnChain.SoulCard.IpfsInteractor

  test "test get data" do
    # Base 64 of "hello, world"
    test_read_return =
      {:ok, "aGVsbG8sIHdvcmxk"} ==
        IpfsInteractor.get_data("QmbJtyu82TQSHU52AzRMXBENZGQKYqPsmao9dPuTeorPui")

    %{
      test_read_return: test_read_return
    }
    |> IO.inspect()
  end
end
