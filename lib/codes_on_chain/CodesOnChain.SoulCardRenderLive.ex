defmodule CodesOnChain.SoulCardRenderLive do
  @moduledoc """
    Test to impl a dynamic webpage by snippet!
  """

  use FunctionServerBasedOnArweaveWeb, :live_view
  alias Components.KVHandler.KVRouter
  alias CodesOnChain.SoulCardRender
  alias Components.GistHandler

  @template_gist_id "1a301c084577fde54df73ced3139a3cb"

  def get_module_doc, do: @moduledoc

  @impl true
  def render(assigns) do
    ~H"""
      <%= raw(@html) %>
    """
  end

  def register() do
    KVRouter.put_routes(
      [
        ["/noncegeek_dao", "SoulCardRenderLive", "index"]
      ]
    )
  end

  @impl true
  def mount(%{"data_gist_id" => data_gist_id, "ethereum_addr" => addr}, _session, socket) do
    payload =
      init_html()
      |> handle_html(data_gist_id, addr)
    {
      :ok,
      socket
      |> assign(:html, payload)
    }
  end

  def handle_html(raw_html, data_gist_id, addr) do
    {:ok, payloads} = SoulCardRender.get_data(data_gist_id, addr)
    do_handle_html(raw_html, payloads)
  end

  def do_handle_html(raw_html, payloads) do
    Enum.reduce(payloads, raw_html, fn {key, value}, acc ->
      replace_with_kv(acc, key, value)
    end)
  end

  def replace_with_kv(raw_html, key, value) do
    String.replace(raw_html, "{{#{key}}}", handle_v(value))
  end

  def handle_v(value) when is_binary(value), do: value
  def handle_v(value), do: inspect(value)

  def init_html() do
    %{
      files:
        %{"name_card_template.html":
          %{
            content: content
          }
        }
    } = GistHandler.get_gist(@template_gist_id)
    content
  end

  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end

end
