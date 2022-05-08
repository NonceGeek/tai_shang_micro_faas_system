defmodule FunctionServerBasedOnArweaveWeb.CodeLoaderLive.Index do
  use FunctionServerBasedOnArweaveWeb, :live_view

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
      |> assign(:explorer_link, build_explorer_link(tx_id, type))
      |> assign(:auth, auth)

    {:ok, socket}
  end
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

    {
      :noreply,
      socket
      |> assign(:selected_code, code_name)
      |> assign(:code_text, code_text)
      |> assign(:explorer_link, build_explorer_link(tx_id, type))
      |> push_event("highlight", %{})
    }
  end

  def handle_event("load_code", _params, %{assigns: assigns} = socket) do
    OnChainCode.load_code(assigns.code_text)

    func_names =
      assigns.selected_code
      |> OnChainCode.get_functions()
      |> Enum.map(fn {key, _value} ->
        key
      end)

    {
      :noreply,
      socket
      |> assign(:func_names, func_names)
      |> assign(:selected_func, Enum.fetch!(func_names, 0))
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


  # def run_func(mod_name, func_name, params) do
  #   func_name_atom = String.to_atom(func_name)

  #   result =
  #     "Elixir.#{mod_name}"
  #     |> String.to_atom()
  #     |> apply(func_name_atom, params)
  # end

end
