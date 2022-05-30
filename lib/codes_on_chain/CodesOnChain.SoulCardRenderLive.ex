defmodule CodesOnChain.SoulCardRenderLive do
  @moduledoc """
    Test to impl a dynamic webpage by snippet!
  """
  use FunctionServerBasedOnArweaveWeb, :live_view
  alias CodesOnChain.SoulCardRender
  alias Components.GistHandler
  alias Components.KVHandler.KVRouter
  alias Components.KVHandler
  alias Components.ModuleHandler

  @template_gist_id_example "1a301c084577fde54df73ced3139a3cb"
  @default_avatar "https://noncegeek.com/avatars/leeduckgo.jpeg"

  def get_module_doc, do: @moduledoc

  @impl true
  def render(assigns) do
    # template = init_html(assigns.template_gist_id)
    template = File.read!("template.html")
    quoted = EEx.compile_string(template, [engine: Phoenix.LiveView.HTMLEngine])

    {result, _bindings} = Code.eval_quoted(quoted, assigns: assigns)
    result

  end

  def register() do
    KVRouter.put_routes(
      [
        ["/soulcard", "SoulCardRenderLive", "index"]
      ]
    )
  end

  @impl true
  def mount(%{
      "addr" => addr}, _session, socket) do
    # TODO: check if the addr is created


    %{user: %{ipfs: ipfs_cid}} = KVHandler.get(addr, "UserManager")

    {:ok, data} = SoulCardRender.get_data(ipfs_cid)
    # {:ok, data_dao} = SoulCardRender.get_data(dao_ipfs_cid)

    {
      :ok,
      socket
      |> assign(:data, handle_data(data, :user))
      |> assign(:addr, addr)
      |> assign(:template_gist_id, @template_gist_id_example)
    }
  end

  @impl true
  def mount(%{
      "addr" => addr,
      "dao_addr" => dao_addr}, _session, socket) do
    # TODO: check if the addr is created


    %{user: %{ipfs: ipfs_cid}} = KVHandler.get(addr, "UserManager")
    %{dao: %{ipfs: dao_ipfs_cid}} = KVHandler.get(dao_addr, "UserManager")

    {:ok, data} = SoulCardRender.get_data("QmTMH123zN2ggGguZkdFDjiDGy3gz89uD9D53ALMLSkis1")
    IO.puts inspect data
    # {:ok, data_dao} = SoulCardRender.get_data(dao_ipfs_cid)

    {
      :ok,
      socket
      |> assign(:data, handle_data(data, :user))
      |> assign(:addr, addr)
      # |> assign(:data_dao, data_dao)
      |> assign(:template_gist_id, @template_gist_id_example)
    }
  end

  def handle_data(data, :user) do
    avatar = Map.get(data, :avatar)
    if is_nil(avatar) or avatar == "" do
      Map.put(data, :avatar, @default_avatar)
    else
      data
    end
  end

  def init_html(template_gist_id) do
    %{
      files: files
    } = GistHandler.get_gist(template_gist_id)
    {_file_name, %{content: content}} = Enum.fetch!(files, 0)
    content
  end

  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end
end
