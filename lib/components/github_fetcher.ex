defmodule Components.GithubFetcher do
  alias Tentacat.Repositories.Contributors

  @client Tentacat.Client.new()

  def get_contributors(owner, repo) do
    try do
      {200, data, _} =
        Contributors.list(@client, owner, repo)

      res =
        data
        |> ExStructTranslator.to_atom_struct()
        |> Enum.map(fn %{login: login, contributions: contributions, id: id} ->
        %{login: login, contributions: contributions, id: id}
      end)
      {:ok, res}
    rescue
      error ->
        {:error, inspect(error)}
    end
  end

  def in_repo?(user_id, owner, repo) when is_number(user_id) do
    try do
      {:ok, res} = get_contributors(owner, repo)
      Enum.reduce(res, false, fn %{id: id}, acc ->
        (id == user_id) or acc
      end)
    rescue
      error
        ->
        {:error, inspect(error)}
    end
  end

  def in_repo?(username, owner, repo) when is_binary(username) do
    try do
      {:ok, res} = get_contributors(owner, repo)
      Enum.reduce(res, false, fn %{login: login}, acc ->
        (login == username) or acc
      end)
    rescue
      error
        ->
        {:error, inspect(error)}
    end
  end


  # def get_commits(owner, repo) do
  #   {200, data, _} =
  #     Commits.list(@client, owner, repo)

  #   data
  #   |> Enum.map(fn x ->
  #     %{
  #       login: get_in(x, ["author", "login"]),
  #       date: get_in(x, ["commit", "author", "date"]),
  #       message: get_in(x, ["commit", "message"])
  #     }
  #   end)
  # end

  # def get_user_commits(owner, repo, login) do
  #   owner
  #   |> get_commits(repo)
  #   |> Enum.filter(fn x -> x.login == login end)
  # end

end
