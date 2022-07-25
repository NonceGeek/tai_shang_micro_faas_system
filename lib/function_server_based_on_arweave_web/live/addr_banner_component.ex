defmodule FunctionServerBasedOnArweaveWeb.AddrBannerComponent do
  use FunctionServerBasedOnArweaveWeb, :live_component
  require Logger
  @impl true
  def handle_event("web3-changed", %{"addr" => addr}, socket) do
    Logger.info("Login as: #{addr}")
    send self(), {:addr, addr}
    {:noreply, assign(socket, :web3_account_addr, addr)}
  end

  @impl true
  def handle_event("web3-changed", %{"chainId" => chain_id}, socket) do
    Logger.info("Login to chain: #{chain_id}")
    send self(), {:chain_id, chain_id}
    {:noreply, assign(socket, :web3_chain_id, chain_id)}
  end

end
