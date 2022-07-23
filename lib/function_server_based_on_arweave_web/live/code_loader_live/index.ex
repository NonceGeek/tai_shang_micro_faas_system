defmodule FunctionServerBasedOnArweaveWeb.CodeLoaderLive.Index do
  use FunctionServerBasedOnArweaveWeb, :live_view
  alias FunctionServerBasedOnArweave.CodeFetchers.NFT
  alias FunctionServerBasedOnArweave.OnChainCode
  alias  ArweaveSdkEx.CodeRunner
  require Logger

  @gist_prefix "https://api.github.com/gists"

  @impl true
  def mount(_params, session, socket) do
    # codes = [
    #   [key: "Code 1", value: "code1"],
    #   [key: "Code 2", value: "code2"]
    # ]
    auth = has_auth(Map.get(session, "function_server_based_on_arweave_auth"))

    code_names =
      OnChainCode.get_all()
      |> Enum.map(& &1.name)

    selected_code_name = Enum.fetch!(code_names, 0)
    {tx_id, code_text, type} = build_code(selected_code_name)

    socket =
      socket
      |> assign(:code_names, code_names)
      |> assign(:methods, [])
      |> assign(:params, [])
      |> assign(:selected_code, selected_code_name)
      |> assign(:code_text, code_text)
      |> assign(:code_type, type)
      |> assign(:explorer_link, build_explorer_link(tx_id, type))
      |> assign(:auth, auth)
      |> assign(:fun_doc, nil)
      |> assign(:output, "")

    socket = handle_socket(socket, tx_id, type)
    {:ok, socket}

  end

  def handle_socket(socket, tx_id, "nft") do
    creators =
      tx_id
      |> String.to_integer()
      |> NFT.get_creators()
    assign(socket, :code_creators, creators)
  end

  def handle_socket(socket, _, _), do: socket

  defp has_auth(nil) do
      false
  end
  defp has_auth(_) do
      true
  end
  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "changed",
        %{
          "_target" => ["form", "code_name"],
          "form" => %{"code_name" => code_name}
        } = _params,
        socket
      ) do
    {tx_id, code_text, type} = build_code(code_name)

    socket =
      socket
      |> assign(:selected_code, code_name)
      |> assign(:code_text, code_text)
      |> assign(:code_type, type)
      |> assign(:explorer_link, build_explorer_link(tx_id, type))
      |> push_event("highlight", %{})
      |> handle_socket(tx_id, type)
    {
      :noreply,
      socket
    }
  end

  def handle_event(
        "changed",
        %{
          "_target" => ["form", "func_name"],
          "form" => %{
            "code_name" => _code_name,
            "func_name" => func_name,
            "input_list" => _input_list
          }
        },
        socket
      ) do

    {
      :noreply,
      socket |> assign(:selected_func, func_name)
    }
  end

  def handle_event("load_code", _params, %{assigns: assigns} = socket) do
    OnChainCode.load_code(assigns.code_text)

    func_names =
      assigns.selected_code
      |> OnChainCode.get_functions()

    {
      :noreply,
      socket
      |> assign(:func_names, func_names)
      |> assign(:selected_func, Enum.fetch!(func_names, 0))
    }
  end

  def handle_event("show_api_info", _params, %{assigns: assigns} = socket) do
    OnChainCode.load_code(assigns.code_text)

    module_name = String.replace(assigns.selected_code, "CodesOnChain.", "")
    [fun_name, fun_arity] = String.split(assigns.selected_func, "/")

    # fun_params = fetch_ast(assigns.code_text, String.to_atom(fun_name)) |> Enum.map(&format_fun_param/1)

    {:docs_v1, _, :elixir, _, _, _, fun_docs} = Code.fetch_docs("Elixir.#{assigns.selected_code}" |> String.to_atom())

    {_, _, [signature], %{"en" => fun_doc}, _} = Enum.find(fun_docs, "", fn doc ->
      {{_kind, function_name, arity}, _, _, %{"en" => _fun_doc}, _} = doc
      function_name == String.to_atom(fun_name) && arity == String.to_integer(fun_arity)
    end)
    fun_params = signature |> String.replace(fun_name, "") |> String.replace("(", "") |> String.replace(")", "")

    fun_spec = """
    ### 函数注释
    #{fun_doc}

    ### 调用该函数的 curl 命令格式：

    ```bash
    curl --location --request POST 'https://faas.noncegeek.com/api/v1/run \\
    --header 'Content-Type: application/json' \\
    --data-raw '{
        "name": "#{module_name}",
        "func_name": "#{fun_name}",
        "params": [#{fun_params}]
    }'
    ```

    其中，`params` 数组里需提供 #{fun_arity} 个参数。
    """

    {
      :noreply,
      socket
      |> assign(:fun_doc, fun_spec)
    }
  end

  def fetch_ast(module_code, fun) do
    module_code
    |> Code.string_to_quoted!()
    |> tap(&inspect/1)
    |> Macro.prewalk(fn
      {:def, _, [{^fun, _, params} | _]} -> throw(params)
      other -> other
    end)

    []
  catch
    result -> result
  end

  def handle_event("update_code", _params, %{assigns: assigns} = socket) do
    OnChainCode.update_code_by_name(assigns.selected_code)
    {
      :noreply,
      socket
      |> redirect(to: "/")
    }
  end

  def handle_event("remove_all_code", _params, %{assigns: assigns} = socket) do
     %{tx_id: tx_id, code: _code, type: type} = OnChainCode.get_by_name(assigns.selected_code)
     case type do
       "gist" -> OnChainCode.remove_code_by_gist(tx_id)
       _-> :ignore
     end
    {
      :noreply,
      socket
      |> redirect(to: "/")
    }
  end

  def handle_event("remove_code", _params, %{assigns: assigns} = socket) do
     OnChainCode.remove_code_by_name(assigns.selected_code)
    {
      :noreply,
      socket
      |> redirect(to: "/")
    }
  end

  @impl true
  def handle_event("run", params, socket) do
    params_atom = ExStructTranslator.to_atom_struct(params)
    do_handle_event(params_atom, socket)
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  def do_handle_event(
        %{
          form: %{
            code_name: code_name,
            func_name: func_name,
            input_list: input_list_str
          }
        },
        socket
      ) do
    socket =
      with {:ok, input_list} <- Poison.decode(input_list_str),
           true <- is_list(input_list) do
        output =
          try do
            Logger.info("#{code_name}, #{func_name}, #{inspect(input_list)}")
            func_name = String.split(func_name, "/") |> Enum.fetch!(0)

            CodeRunner.run_func(
              code_name,
              func_name,
              input_list
            )
          rescue
            reason ->
              "Invalid input arguments or function call!because: #{inspect(reason)}"
          end

        assign(socket, :output, output)
      else
        _ ->
          assign(socket, :output, "Input must be a list")
      end

    {:noreply, socket}
  end

  # +
  # | other funcs
  # +

  def build_code(selected_code) do
    # get_tx_id
    # get_content_by_tx_id
    # parse code as markdown
    %{tx_id: tx_id, code: code, type: type} = OnChainCode.get_by_name(selected_code)
    # {:ok, %{content: code}} = ArweaveSdkEx.get_content_in_tx(Constants.get_arweave_node(), tx_id)
    {tx_id, code, type}
  end

  def build_explorer_link(tx_id, "ar") do
    "#{Constants.get_arweave_explorer()}/#{tx_id}"
  end

  def build_explorer_link(tx_id, "gist") do
    "#{@gist_prefix}/#{tx_id}"
  end

  def build_explorer_link(token_id, "nft") do
    "#{token_id}"
  end


  # def run_func(mod_name, func_name, params) do
  #   func_name_atom = String.to_atom(func_name)

  #   result =
  #     "Elixir.#{mod_name}"
  #     |> String.to_atom()
  #     |> apply(func_name_atom, params)
  # end
end
