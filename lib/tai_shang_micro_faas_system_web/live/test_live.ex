defmodule TaiShangMicroFaasSystemWeb.TestLive do
  use TaiShangMicroFaasSystemWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
      <h1>An Liveview dApp Example</h1>

      <div>
        <.live_component module={Components.Liveview.AddrBannerComponent} id="addr_banner"/>
      </div>

      <div>
        <.live_component module={Components.Liveview.SigVerifierComponent} id="sig_verifier"/>
      </div>

      <button type="button" phx-click="output_socket">
      Oh
      </button>

      <div>
        <.live_component module={Components.Liveview.DebugContractComponent} id="debug_contract"/>
      </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:test, "oh")
    }
  end

  @impl true
  def handle_event(_key, _params, socket) do
    IO.puts inspect socket.assigns
    IO.puts inspect(self())
    {:noreply, socket}
  end

  @impl true
  def handle_info(payload, socket) do
    # update the list of cards in the socket
    IO.puts inspect payload
    {:noreply, socket}
  end
end
