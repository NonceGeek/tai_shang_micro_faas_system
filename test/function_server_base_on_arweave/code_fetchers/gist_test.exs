defmodule TaiShangMicroFaasSystem.CodeFetchers.GistTest do
  use ExUnit.Case, async: true

  alias TaiShangMicroFaasSystem.CodeFetchers.Gist

  test "get from gist" do
    tx_id = "1c67667fdceb4246e17b492511082ccb"
    {res, %{content: code}} = tx_id |> Gist.get_from_gist()
    assert res == :ok
    assert code |> IEx.Info.info() |> Enum.at(0) == {"Data type", "List"}
  end
end
