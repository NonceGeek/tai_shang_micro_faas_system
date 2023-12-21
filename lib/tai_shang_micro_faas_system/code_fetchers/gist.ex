defmodule TaiShangMicroFaasSystem.CodeFetchers.Gist do
  alias Components.ExHttp
  require Logger
  @prefix "https://api.github.com/gists"

  # to optimize
  def get_from_gist(payload, "ipfs") do
    try do
      %{"files" => files} = payload
      # {_file_name, %{"content" => content}} = Enum.fetch!(files, 0)

      content_list = handle_files(files)

      # same format as get from arweave.
      {:ok, %{content: content_list}}
    rescue
      _ ->
        {:error, "error in gist fetching"}
    end
  end

  def get_from_gist(gist_id) do
    try do
      {:ok, %{files: files}} = do_get_from_gist(gist_id)
      # {_file_name, %{"content" => content}} = Enum.fetch!(files, 0)
      IO.puts inspect files
      content_list = handle_files(files)

      # same format as get from arweave.
      {:ok, %{content: content_list}}
    rescue
      _ ->
        {:error, "error in gist fetching"}
    end
  end

  def handle_files(files) do
    Enum.map(files, fn x ->
      {_file_name, %{content: content}} = x
      content
    end)
  end

  def get_from_gist(gist_id, file_name) do
    {:ok, %{"files" => files}} = do_get_from_gist(gist_id)

    content =
      files
      |> Map.get(file_name)
      |> Map.get("content")

    # same format as get from arweave.
    {:ok, %{content: content}}
  end

  def do_get_from_gist(gist_id) do
    Logger.info("get from gist: #{@prefix}/#{gist_id}")
    ExHttp.http_get("#{@prefix}/#{gist_id}")
  end
end
