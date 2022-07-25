defmodule Components.Liveview.SigVerifierComponent do
  use FunctionServerBasedOnArweaveWeb, :live_component
  require Logger

  @impl true
  def handle_event("send-signed-message", %{"msg" => msg, "signature" => signature}, socket) do
    addr = socket.assigns.web3_account_addr

    result = EthWallet.verify_compact(msg, signature, addr)

    send self(), {:sig_verified_result, result}

    {:noreply, push_event(socket, "message-verified", %{result: result})}
  end

  def handle_event(_key, _params, socket), do: {:noreply, socket}
end
