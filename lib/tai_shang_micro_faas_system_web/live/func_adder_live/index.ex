defmodule TaiShangMicroFaasSystemWeb.FuncAdderLive.Index do
  use TaiShangMicroFaasSystemWeb, :live_view

  alias TaiShangMicroFaasSystem.OnChainCode

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
      "cid" => cid
    }
  }, socket) do
    if tx_id == "" and gist_id == "" and cid == "" do
      {:noreply,
        put_flash(socket, :info, "recompile success!")
      }
    else
      {type, id} = build_type(tx_id, gist_id, cid)
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


  end

  @impl true
  def handle_event("re_compile", _params, socket) do
    IO.puts inspect IEx.Helpers.recompile()
    {:noreply, socket}
  end
  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end

  def build_type("", gist_id, ""), do: {"gist", gist_id}
  def build_type(tx_id, "", ""), do: {"ar", tx_id}
  def build_type("", "", cid), do: {"ipfs", cid}

end
