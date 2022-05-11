defmodule FunctionServerBasedOnArweaveWeb.NameCardLive do
  use FunctionServerBasedOnArweaveWeb, :live_view

  alias CodesOnChain.Top5

  @impl true
  def mount(%{"gist_id" => gist_id}, _session, socket) do
    case Top5.handle_gist(gist_id) do
      {:ok, payload} ->
        {
          :ok,
          socket
          |> assign(:gist_data, payload)
        }
      {:error, error} ->
        {
          :ok,
          socket
          |> assign(:error, "Opps: #{inspect(error)}")
        }

    end

  end

  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end

end
