defmodule CodesOnChain.SoulCardRenderLive do
  @moduledoc """
    Test to impl a dynamic webpage by snippet!
  """
  use FunctionServerBasedOnArweaveWeb, :live_view
  alias CodesOnChain.SoulCardRender
  alias Components.GistHandler
  alias Components.KVHandler.KVRouter
  alias Components.{KVHandler, MirrorHandler}
  alias Components.ModuleHandler

  @template_gist_id_example "1a301c084577fde54df73ced3139a3cb"
  @default_avatar "https://noncegeek.com/avatars/leeduckgo.jpeg"
  @article_num 1

  def get_module_doc, do: @moduledoc

  @impl true
  def render(assigns) do
    template = init_html(assigns.template_gist_id)
    # template = File.read!("template.html")
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
      "addr" => addr,
      "dao_addr" => dao_addr,
      "dao_addr_2" => dao_addr_2
    }, _session, socket) do


    %{user: %{ipfs: ipfs_cid}} = KVHandler.get(addr, "UserManager")
    %{dao: %{ipfs: dao_ipfs_cid}} = KVHandler.get(dao_addr, "UserManager")
    %{dao: %{ipfs: dao_ipfs_cid_2}} = KVHandler.get(dao_addr_2, "UserManager")

    {:ok, data} = SoulCardRender.get_data(ipfs_cid)
    {:ok, data_dao} = SoulCardRender.get_data(dao_ipfs_cid)
    %{gist_id: template_gist_id} = data_dao

    {:ok, data_dao_2} = SoulCardRender.get_data(dao_ipfs_cid_2)

    # todo: fetch mirror dynamic


    socket =
      if Map.fetch(data, :mirrorLink) != :error do
        if Map.fetch!(data, :mirrorLink) != false do
          handle_mirror_status(socket, Map.fetch!(data, :mirrorLink), addr)
        end
      else
        socket
      end

    {
      :ok,
      socket
      |> assign(:data, handle_data(data, :user))
      |> assign(:addr, addr)
      |> assign(:data_dao, data_dao)
      |> assign(:data_dao_2, data_dao_2)
      |> assign(:template_gist_id, @template_gist_id_example)
      # |> assign(:template_gist_id, template_gist_id)
    }
  end

  @impl true
  def mount(%{
      "addr" => addr,
      "dao_addr" => dao_addr}, _session, socket) do
    # TODO: check if the addr is created

    %{user: %{ipfs: ipfs_cid}} = KVHandler.get(addr, "UserManager")
    %{dao: %{ipfs: dao_ipfs_cid}} = KVHandler.get(dao_addr, "UserManager")

    {:ok, data} = SoulCardRender.get_data(ipfs_cid)
    {:ok, data_dao} = SoulCardRender.get_data(dao_ipfs_cid)
    %{gist_id: template_gist_id} = data_dao

    # todo: fetch mirror dynamic

    socket =
      if Map.fetch(data, :mirrorLink) != :error do
        if Map.fetch!(data, :mirrorLink) != false do
          handle_mirror_status(socket, Map.fetch!(data, :mirrorLink), addr)
        end
      else
        socket
      end

    {
      :ok,
      socket
      |> assign(:data, handle_data(data, :user))
      |> assign(:addr, addr)
      |> assign(:data_dao, data_dao)
      |> assign(:template_gist_id, @template_gist_id_example)
      # |> assign(:template_gist_id, template_gist_id)
    }
  end

  def handle_mirror_status(socket, true, addr) do
    assign(socket, :mirrors, MirrorHandler.get_articles(addr, @article_num))
  end

  def handle_mirror_status(socket, false, _addr), do: socket

  @impl true
  def mount(%{
      "addr" => addr}, _session, socket) do
    # TODO: check if the addr is created


    %{user: %{ipfs: ipfs_cid}} = KVHandler.get(addr, "UserManager")

    {:ok, data} = SoulCardRender.get_data(ipfs_cid)
    # {:ok, data_dao} = SoulCardRender.get_data(dao_ipfs_cid)

    socket =
      if Map.fetch(data, :mirrorLink) != :error do
        if Map.fetch!(data, :mirrorLink) != false do
          handle_mirror_status(socket, Map.fetch!(data, :mirrorLink), addr)
        end
      else
        socket
      end
    {
      :ok,
      socket
      |> assign(:data, handle_data(data, :user))
      |> assign(:addr, addr)
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
