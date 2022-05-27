defmodule CodesOnChain.SoulCardRenderLive do
  @moduledoc """
    Test to impl a dynamic webpage by snippet!
  """
  use FunctionServerBasedOnArweaveWeb, :live_view
  alias CodesOnChain.SoulCardRender
  alias Components.GistHandler
  alias Components.KVHandler.KVRouter

  @template_gist_id "1a301c084577fde54df73ced3139a3cb"

  def get_module_doc, do: @moduledoc

  @impl true
  def render(assigns) do
    template = init_html()

    quoted = EEx.compile_string(template, [engine: Phoenix.LiveView.HTMLEngine])

    {result, _bindings} = Code.eval_quoted(quoted, assigns: assigns)
    result
  end

  def register() do
    KVRouter.put_routes(
      [
        ["#{@template_gist_id}", "SoulCardRenderLive", "index"]
      ]
    )
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

  def init_html() do
    %{
      files: files
    } = GistHandler.get_gist(@template_gist_id)
    {file_name, %{content: content}} = Enum.fetch!(files, 0)
    content
  end

  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end
end
