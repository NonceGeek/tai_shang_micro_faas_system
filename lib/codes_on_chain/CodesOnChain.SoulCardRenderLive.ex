defmodule CodesOnChain.SoulCardRenderLive do
  @moduledoc """
    Test to impl a dynamic webpage by snippet!
  """
  use FunctionServerBasedOnArweaveWeb, :live_view
  alias CodesOnChain.SoulCardRender

  def get_module_doc, do: @moduledoc

  @impl true
  def render(assigns) do
    ~H"""
      <%= Jason.encode!(@data) %>
    """
  end

  @impl true
  def mount(%{"ipfs_cid" => ipfs_cid}, _session, socket) do
    {:ok, data} = SoulCardRender.get_data(ipfs_cid)

    {
      :ok,
      socket
      |> assign(:data, data)
    }
  end

  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end
end
