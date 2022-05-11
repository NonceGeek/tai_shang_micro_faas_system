defmodule CodesOnChain.Top5 do
  # Todo:
  # Impl a module using Components.GistHandler

  # 0x01  func:
  # Module match the files in: https://api.github.com/gists/c7b2deee1d33eada3bef20b47017b019
  # to make sure the format is correct
  # and output a map like:
  # %{filename_trimed_without_file format: %{type: xx, content: xx}}
  # eg. %{DAO: %{type: "application/json", content: "opps"}}
  # %{
  #   "DAO.json": %{type: "application/json", content: dao_content},
  #   "basic.json": %{type: "application/json", content: basic_content},
  #   "favorite.json": %{type: "application/json", content: fav_content},
  #   "mirror.json": %{type: "application/json", content: mir_content},
  #   "resume.md": %{type: "text/markdown", content: resume},
  # }
  @moduledoc """
    Generate Top5 Homepage!
  """
  alias Components.GistHandler

  @json_type "application/json"
  
  def get_module_doc(), do: @moduledoc

  def handle_gist(gist_id) do
    %{files: files} =
      payload =
        GistHandler.get_gist(gist_id)

    payload
    |> Map.put(:files, handle_files(files))
    |> ExStructTranslator.to_atom_struct()
  end

  def handle_files(files) do
    files
    |> json_decode_batch()
    |> trim_file_name()
  end

  def json_decode_batch(files) do
    files
    |> Enum.map(fn {k, payload} ->
      {k, handle_file_by_type(payload)}
    end)
    |> Enum.into(%{})
  end

  def handle_file_by_type(%{type: @json_type, content: content}) do
    content
    |> Poison.decode!()

  end

  def handle_file_by_type(%{type: _, content: content}), do: content

  def trim_file_name(files) do
    Enum.map(files, fn {k, v} ->
      name_trimmed = handle_file_name(k)
      {String.downcase(name_trimmed), v}
    end)
    |> Enum.into(%{})
  end

  def handle_file_name(name) do
    case name
         |> Atom.to_string()
         |> String.reverse
         |> String.split(".", parts: 2) do
      [_, name_trimmed] ->
        String.reverse(name_trimmed)
      [name_trimmed] ->
        String.reverse(name_trimmed)
    end
  end
end
