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

  @doc """
    if the addr owner not belong to any DAO.
  """
  @impl true
  def mount(%{"ethereum_addr" => addr}, _session, socket) do
    {:ok, data} = SoulCardRender.get_data("c7b2deee1d33eada3bef20b47017b019", addr)
    {
      :ok,
      socket
      |> assign(:data, data)
    }
  end
  @doc """
    if the addr owner belong to any DAO.
  """
  @impl true
  def mount(%{"dao_eth_addr" => dao_eth_addr, "ethereum_addr" => addr}, _session, socket) do
    {:ok, data} = SoulCardRender.get_data("c7b2deee1d33eada3bef20b47017b019", addr)
    dao_data = %{}
    {
      :ok,
      socket
      |> assign(:data, data)
      |> assign(:dao_data, dao_data)
    }
  end

  @doc """
    just for test.
  """
  @impl true
  def mount(%{"data_gist_id" => data_gist_id, "ethereum_addr" => addr}, _session, socket) do
    {:ok, data} = SoulCardRender.get_data(data_gist_id, addr)

    {
      :ok,
      socket
      |> assign(:data, data)
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
      files: files
    } = GistHandler.get_gist(@template_gist_id)
    {file_name, content} = Enum.fetch!(files, 0)
    content
  end

  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end

end
