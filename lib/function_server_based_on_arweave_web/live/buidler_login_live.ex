defmodule FunctionServerBasedOnArweaveWeb.BuidlerLoginLive do
  use FunctionServerBasedOnArweaveWeb, :live_view
  require Logger

  alias Components.NFT
  alias FunctionServerBasedOnArweaveWeb.AuthHelpers

  @impl true
  def render(assigns) do
    ~H"""
      <h1>Login as Buidler</h1>

      <div class="d-flex justify-content-center">
        <div class="spinner-border text-primary" role="status">
          <span class="sr-only">Loading...</span>
        </div>
      </div>
      <div id="auth_as_buidler" phx-hook="AuthAsBuidler">
      </div>
      <.live_component module={Components.Liveview.AddrBannerComponent} id="addr_banner"/>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("auth-as-builder", %{"addr" => addr, "chainId" => _chainId}, socket) do
    Logger.info("Authenticating Buidler: #{addr}")

    auth_as_buidler(socket, addr, NFT.has_nft?(addr))
  end

  defp auth_as_buidler(socket, _addr, false) do
    {:noreply, socket}
  end

  defp auth_as_buidler(socket, addr, true) do
    all_nfts = NFT.fetch_all_nft(addr)

    auth_as_buidler(socket, addr, all_nfts)
  end

  defp auth_as_buidler(socket, _addr, []) do
    {:noreply, socket}
  end

  defp auth_as_buidler(socket, addr, [nft | _]) do
    # Token Info format: ["noncegeeker", "buidler" * 3, "writer" * 2]
    case String.length(nft.token_info) do
      0 ->
        {:noreply, socket}
      _ ->
        socket = AuthHelpers.auth_as_buidler(socket, addr)

        id = AuthHelpers.random(16)

        :ets.insert(:buidler_login, {id, addr})

        {:noreply, redirect(socket, to: Routes.buidler_path(FunctionServerBasedOnArweaveWeb.Endpoint, :sign_in_from_live_view, lid: id, returns_to: "/"))}
    end
  end
end
