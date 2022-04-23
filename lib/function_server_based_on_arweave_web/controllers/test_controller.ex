defmodule FunctionServerBasedOnArweaveWeb.TestController do
  use FunctionServerBasedOnArweaveWeb, :controller

  def get(conn, %{
      "key" => key
    }) do
    value = CodesOnChain.Syncer.get_from_db(key)

    json(conn, value)
  end

  def all(conn, _) do
    value = CodesOnChain.Syncer.all_from_db()

    json(conn, value)
  end
end
