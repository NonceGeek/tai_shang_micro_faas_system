defmodule CodesOnChain.Top5 do
  # Todo:
  # Impl a module using Components.GistHandler

  # 0x01  func:
  # Module match the files in: https://api.github.com/gists/c7b2deee1d33eada3bef20b47017b019
  # to make sure the format is correct
  # and output a map like:
  # %{filename_trimed_without_file format: %{type: xx, content: xx}}
  # eg. %{DAO: %{type: "application/json", content: "opps"}}

  alias Components.GistHandler
  def handle_gist(gist_id) do
    %{files: %{
      "DAO.json": %{type: "application/json", content: content},
    }
    } = GistHandler.get_gist(gist_id)
    Poison.decode!(content)
  end
end
