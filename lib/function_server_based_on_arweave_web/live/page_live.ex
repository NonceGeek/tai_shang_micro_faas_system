defmodule FunctionServerBasedOnArweaveWeb.PageLive do
  use FunctionServerBasedOnArweaveWeb, :live_view

  alias CodesOnChain.Top5
  @impl true
  # suit top5
  def mount(%{"gist_id" => gist_id}, _session, socket) do
    {
      :ok,
      socket
      |> assign(:gist_data, Top5.handle_gist(gist_id))
    }
  end

  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end



end