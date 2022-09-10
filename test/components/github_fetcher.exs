defmodule Components.GithubFetcherTest do
  use ExUnit.Case

  alias Components.GithubFetcher

  test "get_contributors" do
    {owner, repo} = {"zzfup", "go-fetch"}
    assert GithubFetcher.get_contributors(owner, repo) |> length() != 0
  end

  test "get_commits" do
    {owner, repo} = {"zzfup", "go-fetch"}
    assert GithubFetcher.get_commits(owner, repo) |> length() != 0
  end
end
