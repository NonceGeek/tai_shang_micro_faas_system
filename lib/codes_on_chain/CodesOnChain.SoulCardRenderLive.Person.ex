defmodule CodesOnChain.SoulCardRenderLive.Person do
  @moduledoc """
    Impl a dynamic webpage for person user by Snippet!
  """
  use FunctionServerBasedOnArweaveWeb, :live_view
  alias CodesOnChain.{SoulCardRender, SpeedRunFetcher}
  alias Components.GistHandler
  alias Components.KVHandler.KVRouter
  alias Components.{KVHandler, MirrorHandler}


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
        ["/soulcard", "SoulCardRenderLive.Person", "index"]
      ]
    )
  end


  @doc """
    cond:
    * has dao_addrs
    * if only addr
  """
  @impl true
  def mount(%{
    "addr" => addr,
    "dao_addr_1" => _dao_addr,
  } = params, _session, socket) do
    params
    |> fetch_dao_addrs_and_roles()
    |> fetch_dao_infoes()
    |> do_mount(addr, socket)
  end

  @impl true
  def mount(%{
      "addr" => addr}, _session, socket) do
    # TODO: check if the addr is created
    do_mount([], addr, socket)
  end


  def fetch_dao_infoes(dao_addr_and_role_list) do
    Enum.map(dao_addr_and_role_list, fn {dao_addr, role} ->
      %{dao: %{ipfs: dao_ipfs_cid}} = KVHandler.get(dao_addr, "UserManager")
      {:ok, data_dao} = SoulCardRender.get_data(dao_ipfs_cid)
      {data_dao, role}
    end)
  end

  def do_mount(dao_infoes_roles_list, addr, socket) do
    %{user: %{ipfs: ipfs_cid}} = KVHandler.get(addr, "UserManager")
    {:ok, %{speedruns: speedrun_sources} = data} = SoulCardRender.get_data(ipfs_cid)
    socket =
      if Map.fetch(data, :mirror_link) != :error do
        if Map.fetch!(data, :mirror_link) != false do
          handle_mirror_status(socket, Map.fetch!(data, :mirror_link), addr)
        else
          socket
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
      |> assign(:dao_infoes_roles_list, dao_infoes_roles_list)
      |> assign(:speedruns, handle_speedruns(addr, speedrun_sources))
    }
  end

  def handle_speedruns(addr, speedrun_sources) do
    IO.puts inspect speedrun_sources
    speedrun_sources
    |> Enum.map(fn source ->
      SpeedRunFetcher.fetch_data(addr, source)
    end)
    |> Enum.map(&(handle_res(&1)))
    |> Enum.reject(&(is_nil(&1)))
  end

  def handle_res({:error, _msg}), do: nil
  def handle_res({:ok, msg}), do: msg

  def fetch_dao_addrs_and_roles(params) do
    params
    |> Enum.map(fn {key, addr} ->
      case String.split(key, "_") do
        ["dao", "addr", index] ->
          zip_dao_and_role(params, addr, index)
        _ ->
          :pass
      end
    end)
    |> Enum.reject(&(&1==:pass))
  end

  def zip_dao_and_role(params, addr, index) do
    role = Map.get(params, "role_#{index}")
    do_zip_dao_and_role(addr, role)
  end

  def do_zip_dao_and_role(addr, nil), do: {addr, nil}
  def do_zip_dao_and_role(addr, role), do: {addr, role}

  def handle_mirror_status(socket, true, addr) do
    try do
      assign(socket, :mirrors, MirrorHandler.get_articles(addr, @article_num))
    rescue
      _ ->
        socket
    end
  end

  def handle_mirror_status(socket, false, _addr), do: socket

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
