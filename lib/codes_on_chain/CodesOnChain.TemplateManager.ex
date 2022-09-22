defmodule CodesOnChain.SoulCard.TemplateManager do
  @moduledoc """
    TemplateManager
  """
  require Logger
  alias Components.{KVHandler, Verifier, ModuleHandler, MsgHandler}

  @template_gist_id "1af51ef73d6173d3c755d1fc0dae3e4f"

  def get_module_doc(), do: @moduledoc


  # TODO: only allow admin to do this later.
  def put(template_base64_encoded, addr, msg, signature) do
    with true <- Verifier.verify_message?(addr, msg, signature),
    true <- MsgHandler.time_valid?(msg)do
      templates =
        get()
        |> handle_kv_value()
      id_now = Enum.count(templates)
      templates = templates ++ [template_base64_encoded]
      {:ok, _} = KVHandler.put("templates", templates, ModuleHandler.get_module_name(__MODULE__))
      {:ok, %{id: id_now}}
    else
      error ->
        {:error, inspect(error)}
    end
  end

  def handle_kv_value(nil), do: []
  def handle_kv_value(others), do: others

  def init()  do
    if is_nil(get()) do
      KVHandler.put("templates", [], ModuleHandler.get_module_name(__MODULE__))
    end
  end

  @doc """
  Get all templates
  """
  def get(), do: KVHandler.get("templates", ModuleHandler.get_module_name(__MODULE__))

  def get_by_id(id) do
    templates =
        get()
        |> handle_kv_value()
    id_handled = handle_id(id)
    Enum.at(templates, id_handled)
  end

  def handle_id(id) when is_binary(id) do
    String.to_integer(id)
  end

  def handle_id(id), do: id

  def init_templates() do
    %{
      files:
      %{
        "card_user.html": %{content: card_user_template},
        "card_dao.html": %{content: card_dao_templte}
    }
    } = Components.GistHandler.get_gist(@template_gist_id)
    templates = [card_user_template |> Base.encode64(), card_dao_templte |> Base.encode64()]
    KVHandler.put("templates", templates, ModuleHandler.get_module_name(__MODULE__))
  end
end
