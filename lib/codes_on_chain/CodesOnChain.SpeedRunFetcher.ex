defmodule CodesOnChain.SpeedRunFetcher do

  alias Components.ExHttp

  @status_accepted "ACCEPTED"

  def fetch_data(addr, speedrun_api_endpoint, speedrun_url) do
    {:ok, data} = ExHttp.http_get(speedrun_api_endpoint)

    runner =
      data
      |> Enum.find(fn %{"id" => id} ->
        id == addr
      end)

    accepted_challenges =
      runner
      |> Map.get("challenges", %{})
      |> Map.to_list()
      |> Enum.filter(fn {_name, challenge} ->
        Map.get(challenge, "status") == @status_accepted
      end)

    len = length(accepted_challenges)

    %{
      chanllege_passed_num: len,
      link: "#{speedrun_url}/builders/#{addr}",
      level: get_level(len)
    }
  end

  def get_level(len) when len <=3, do: 1
  def get_level(len) when len <=6, do: 2
  def get_level(len), do: 3
end
