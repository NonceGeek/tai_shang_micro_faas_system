defmodule FunctionServerBasedOnArweaveWeb.TestController do
  use FunctionServerBasedOnArweaveWeb, :controller

  def get(conn, %{
      "key" => key
    }) do
    value = GenServer.call(CodesOnChain.Syncer, {:get, key})

    json(conn, value)
  end
end
