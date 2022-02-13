defmodule FunctionServerBasedOnArweave.CodeLoaderLive do
  use FunctionServerBasedOnArweaveWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
    }
  end

  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
