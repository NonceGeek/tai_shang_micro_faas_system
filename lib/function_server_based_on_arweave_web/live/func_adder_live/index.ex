defmodule FunctionServerBasedOnArweaveWeb.FuncAdderLive.Index do
  use FunctionServerBasedOnArweaveWeb, :live_view

  alias FunctionServerBasedOnArweave.OnChainCode
  alias ArweaveSdkEx.CodeRunner

  @passwd System.get_env("ADMIN_PASSWD")
  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end


  @impl true
  def handle_event("submit", %{
    "form" =>
    %{
      "passwd" => input_passwd,
      "tx_id" => tx_id
    }
  }, socket) do
    with true <- input_passwd == @passwd,
    {:ok, ele} <- OnChainCode.create_or_query_by_tx_id(tx_id) do
      {
        :noreply,
        socket
        |> put_flash(:info, "Add Code in #{tx_id} success!")
      }
    else
      error ->
        {
          :noreply,
          socket
          |> put_flash(:error, "Opps: #{inspect(error)}")
        }
    end

  end

  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end

end
