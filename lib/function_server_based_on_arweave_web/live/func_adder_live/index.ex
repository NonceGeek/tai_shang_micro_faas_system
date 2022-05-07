defmodule FunctionServerBasedOnArweaveWeb.FuncAdderLive.Index do
  use FunctionServerBasedOnArweaveWeb, :live_view

  alias FunctionServerBasedOnArweave.OnChainCode

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end


  @impl true
  def handle_event("submit", %{
    "form" =>
    %{
      "tx_id" => tx_id,
      "gist_id" => gist_id,
      "nft_code_id" => nft_code_id
    }
  }, socket) do
    {type, id} = build_type(tx_id, gist_id, nft_code_id)
    with {:ok, _ele} <- OnChainCode.create_or_query_by_tx_id(id, type) do
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

  def build_type("", gist_id, ""), do: {"gist", gist_id}
  def build_type(tx_id, "", ""), do: {"ar", tx_id}
  def build_type("", "", nft_code_id), do: {"nft", nft_code_id}

end
