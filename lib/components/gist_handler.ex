defmodule Components.GistHandler do
  alias Components.ExHttp
  require Logger
  @prefix "https://api.github.com/gists"

  def get_gist(gist_id) do
    {:ok, payload} =
      do_get_from_gist(gist_id)
    %{
      files: files,
      owner: %{
        login: user_name,
        id: github_id
      }
    } =
      ExStructTranslator.to_atom_struct(payload)

    %{
      files: files,
      owner: %{
        login: user_name,
        id: github_id
      }
    }
  end

  def do_get_from_gist(gist_id) do
    Logger.info("get from gist: #{@prefix}/#{gist_id}")
    ExHttp.http_get("#{@prefix}/#{gist_id}")
  end
end
