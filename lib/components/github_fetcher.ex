defmodule Components.GithubFetcher do
  @client Tentacat.Client.new()

  def get_contributors(owner, repo) do
    {200, data, _} = @client |> Tentacat.Repositories.Contributors.list(owner, repo)

    data
    |> Enum.map(fn x ->
      %{login: x["login"], contributions: x["contributions"]}
    end)
  end

  def get_commits(owner, repo) do
    {200, data, _} = @client |> Tentacat.Commits.list(owner, repo)

    data
    |> Enum.map(fn x ->
      %{
        login: get_in(x, ["author", "login"]),
        date: get_in(x, ["commit", "author", "date"]),
        message: get_in(x, ["commit", "message"])
      }
    end)
  end

  def get_user_commits(owner, repo, login) do
    get_commits(owner, repo) |> Enum.filter(fn x -> x.login == login end)
  end
end
