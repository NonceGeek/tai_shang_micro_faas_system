defmodule FunctionServerBasedOnArweaveWeb.CodeLoaderLive.Index do
  use FunctionServerBasedOnArweaveWeb, :live_view

  alias FunctionServerBasedOnArweave.Arweave.CodeLoader

  @code_text %{
    "code1" => "code text 1",
    "code2" => "code text 2"
  }

  @code_methods %{
    "code1" => [
      [key: "Code 1 Method 1", value: "code1_method1"],
      [key: "Code 1 Method 2", value: "code1_method2"]
    ],
    "code2" => [
      [key: "Code 2 Method 1", value: "code2_method1"],
      [key: "Code 2 Method 2", value: "code2_method2"]
    ]
  }

  @method_params %{
    "code1_method1" => [
      %{type: "text", name: :"Code 1 Method 1 Text Param"}
    ],
    "code1_method2" => [
      %{type: "number", name: :"Code 1 Method 2 Number Param"}
    ],
    "code2_method1" => [
      %{type: "text", name: :"Code 2 Method 1 Text Param"},
      %{type: "number", name: :"Code 2 Method 1 Number Param"}
    ],
    "code2_method2" => [
      %{type: "number", name: :"Code 2 Method 2 Number Param"},
      %{type: "text", name: :"Code 2 Method 2 Text Param"}
    ]
  }

  @impl true
  def mount(_params, _session, socket) do
    codes = [
      [key: "", value: ""],
      [key: "Code 1", value: "code1"],
      [key: "Code 2", value: "code2"]
    ]

    socket =
      socket
      |> assign(:codes, codes)
      |> assign(:methods, [])
      |> assign(:params, [])
      |> assign(:selected_code, "")

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Code Loader")
    |> assign(:selected_code, "")
    |> assign(:code_loader, CodeLoader.changeset(%CodeLoader{}))
  end

  @impl true
  def handle_event(
        "validate",
        %{"_target" => ["code_loader", "name"], "code_loader" => code_loader_params} = _params,
        socket
      ) do
    name = Map.get(code_loader_params, "name")

    changeset =
      socket.assigns.code_loader
      |> CodeLoader.changeset(
        code_loader_params
        |> Map.put("text", Map.get(@code_text, name))
      )
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(:code_loader, changeset)
      |> assign(:selected_code, name)
      |> assign(:methods, Map.get(@code_methods, name))

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{"_target" => ["code_loader", "method_name"], "code_loader" => code_loader_params} =
          _params,
        socket
      ) do
    method_name = Map.get(code_loader_params, "method_name")

    changeset =
      socket.assigns.code_loader
      |> CodeLoader.changeset(code_loader_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(:code_loader, changeset)
      |> assign(:params, Map.get(@method_params, method_name))

    {:noreply, socket}
  end

  @impl true
  def handle_event("load_code", %{"name" => code_name} = _params, socket) do
    IO.inspect("---------- Loading Code #{code_name} --------- ")

    {:noreply, socket}
  end

  @impl true
  def handle_event(_action, %{"code_loader" => code_loader_params} = _params, socket) do
    IO.inspect("---------- Runing Code #{code_loader_params["name"]} --------- ")
    # code_loader_params sample:
    # %{
    #   "Code 2 Method 2 Number Param" => "3",
    #   "Code 2 Method 2 Text Param" => "ken",
    #   "method_name" => "code2_method2",
    #   "name" => "code2",
    #   "output" => "",
    #   "text" => "code text 2"
    # }

    {:noreply, socket}
  end
end
