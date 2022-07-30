defmodule FunctionServerBasedOnArweaveWeb.UserLiveAuth do
  import Phoenix.LiveView

  alias FunctionServerBasedOnArweaveWeb.AuthHelpers

  # Put below statement to the Liveview or `def live_view` in function_server_based_on_arweave_web.ex
  # to enforce one or all Liveview authentication

  # on_mount MyApFunctionServerBasedOnArweaveWebpWeb.UserLiveAuth

  def on_mount(:pass_through, _params, session, socket) do
    {:cont, assign_user(socket, session)}
  end

  def on_mount(:default, _params, session, socket) do
    socket = assign_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/buidler_login")}
    end
  end

  defp assign_user(socket, session) do
    assign_new(socket, :current_user, fn ->
      AuthHelpers.get_user(socket, session)
    end)
  end
end
