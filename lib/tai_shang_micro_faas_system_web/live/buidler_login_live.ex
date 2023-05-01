defmodule TaiShangMicroFaasSystemWeb.BuidlerLoginLive do
  use TaiShangMicroFaasSystemWeb, :live_view
  require Logger

  alias Components.NFT
  alias TaiShangMicroFaasSystemWeb.AuthHelpers

  @impl true
  def render(assigns) do
    ~H"""
      <div id="auth_as_buidler" phx-hook="AuthAsBuidler" style={@loading_style}>
        <button class="btn btn-light btn-lg" type="button" disabled>
          <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
          Authenticating as Buidler ...
        </button>
      </div>
      <.live_component module={Components.Liveview.AddrBannerComponent} id="addr_banner"/>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:loading_style, "display: block")}
  end

  @impl true
  def handle_event("auth-as-builder", %{"addr" => addr, "chainId" => _chainId}, socket) do
    Logger.info("Authenticating Buidler: #{addr}")

    auth_as_buidler(socket, addr, NFT.has_nft?(addr))
  end

  defp auth_as_buidler(socket, _addr, false) do
    {:noreply, show_not_buidler(socket)}
  end

  defp auth_as_buidler(socket, addr, true) do
    all_nfts = NFT.fetch_all_nft(addr)

    auth_as_buidler(socket, addr, all_nfts)
  end

  defp auth_as_buidler(socket, _addr, []) do
    {:noreply, show_not_buidler(socket)}
  end

  defp auth_as_buidler(socket, addr, [nft | _]) do
    # Token Info format: ["noncegeeker", "buidler" * 3, "writer" * 2]
    case String.length(nft.token_info) do
      0 ->
        {:noreply, show_not_buidler(socket)}
      _ ->
        socket = AuthHelpers.auth_as_buidler(socket, addr)

        id = AuthHelpers.random(16)

        :ets.insert(:buidler_login, {id, addr})

        {:noreply, redirect(socket, to: Routes.buidler_path(TaiShangMicroFaasSystemWeb.Endpoint, :sign_in_from_live_view, lid: id, returns_to: "/"))}
    end
  end

  defp show_not_buidler(socket) do
    socket
    |> assign(:loading_style, "display: none")
    |> put_flash(:info, "Not a Buidler.")
    |> push_event("not-a-buidler", %{})
  end
end
