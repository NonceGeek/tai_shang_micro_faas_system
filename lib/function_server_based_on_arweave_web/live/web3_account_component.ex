defmodule FunctionServerBasedOnArweaveWeb.Web3AccountComponent do
  use FunctionServerBasedOnArweaveWeb, :live_component

  @impl true
  def handle_event("web3-changed", %{"addr" => addr}, socket) do
    IO.puts("Login as: #{addr}")
    {:noreply, assign(socket, :web3_account_addr, addr)}
  end

  @impl true
  def handle_event("web3-changed", %{"chainId" => chain_id}, socket) do
    IO.puts("Login to chain: #{chain_id}")
    {:noreply, assign(socket, :web3_chain_id, chain_id)}
  end

  @impl true
  def handle_event("send-signed-message", %{"msg" => msg, "signature" => signature}, socket) do
    addr = socket.assigns.web3_account_addr

    result = EthWallet.verify_compact(msg, signature, addr)

    {:noreply, push_event(socket, "message-verified", %{result: result})}
  end
end
