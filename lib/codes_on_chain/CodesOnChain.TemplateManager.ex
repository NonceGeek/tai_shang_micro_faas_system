defmodule CodesOnChain.TemplateManager do
  @moduledoc """
  Create a TemplateMangaer, authority by Ethereum signature, and save a key-value pair in K-V Table.

  put(template_gist_id, msg, signature)
  k: v = %{templates: [gist_id_1, gist_id_2, gist_id_3]}

  get()
  returns the list of gist_id, e.g., [gist_id_1, gist_id_2, gist_id_3]
  """
  require Logger
  alias Components.{KVHandler, Verifier}
  @valid_time 3600 # 1 hour
  @init_templates ["1a301c084577fde54df73ced3139a3cb"]
  def get_module_doc(), do: @moduledoc

  # put("123", "msg", "signature")
  def put(template_gist_id, msg, signature) do
    with true <- Verifier.verify_message?(msg, signature),
    true <- time_valid?(msg) do
      templates = get()
      Enum.empty?() do
        templates = []
      end
      templates = templates ++ [template_gist_id]
      KVHandler.put("templates", templates, "TemplateManager")
    else
      error ->
        {:error, inspect(error)}
    end
  end

  def init()  do
    if is_nil(get()) do
      KVHandler.put("templates", init_templates, "TemplateManager")
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
