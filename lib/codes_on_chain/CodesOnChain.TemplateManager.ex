defmodule CodesOnChain.TemplateManager do
  @moduledoc """
    TemplateManager
  """
  require Logger
  alias Components.{KVHandler, Verifier}
  @valid_time 3600 # 1 hour
  @init_templates ["1a301c084577fde54df73ced3139a3cb"]
  def get_module_doc(), do: @moduledoc


  def put(template_gist_id, addr, msg, signature) do
    with true <- Verifier.verify_message?(addr, msg, signature),
    true <- time_valid?(msg) do
      templates =
        get()
        |> handle_kv_value()

      templates = templates ++ [template_gist_id]
      KVHandler.put("templates", templates, "TemplateManager")
    else
      error ->
        {:error, inspect(error)}
    end
  end

  def handle_kv_value(nil), do: []
  def handle_kv_value(others), do: others

  def init()  do
    if is_nil(get()) do
      KVHandler.put("templates", @init_templates, "TemplateManager")
    end
  end

  @doc """
  Get all gist_id
  """
  def get(), do: KVHandler.get("templates", "TemplateManager")

  def time_valid?(msg) do
    [_, timestamp] = String.split(msg, "_")
    timestamp
    |> String.to_integer()
    |> do_time_valid?(timestamp_now())
  end

  defp do_time_valid?(time_before, time_now) when time_now - time_before < @valid_time do
    true
  end
  defp do_time_valid?(_time_before, _time_now), do: false

  def rand_msg(), do: "0x#{RandGen.gen_hex(16)}_#{timestamp_now()}"

  def timestamp_now(), do: :os.system_time(:second)

end
