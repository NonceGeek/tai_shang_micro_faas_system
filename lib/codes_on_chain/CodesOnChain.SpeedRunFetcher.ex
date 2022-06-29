defmodule CodesOnChain.SpeedRunFetcher do

  @moduledoc """
    Fetch&Handle Speerun things.
  """

  def get_module_doc, do: @moduledoc

  alias Components.ExHttp

  @status_accepted "ACCEPTED"
  @speedrun_ng %{
    speedrun_api_endpoint: "https://bewater.leeduckgo.com",
    speedrun_url: "https://speedrun-noncegeek.surge.sh"
  }
  @speedrun_local %{
    speedrun_api_endpoint: "http://localhost:49832",
    speedrun_url: "http://localhost:3000"
  }

  # User Info fetch Type:
  # http://localhost:49832/user?address=0x73c7448760517E3E6e416b2c130E3c6dB2026A1d
  def fetch_speedrun(tag) when tag in ["ng", :ng], do: @speedrun_ng
  def fetch_speedrun(tag) when tag in ["official", :official], do: @speedrun_ng
  def fetch_speedrun(tag) when tag in ["local", :local], do: @speedrun_local

  def build_user_url(speedrun_url, addr, :front), do: "#{speedrun_url}/builders/#{addr}"
  def build_user_url(speedrun_api_endpoint, addr, :back), do: "#{speedrun_api_endpoint}/user?address=#{addr}"

  def fetch_data(addr, type) do
    %{
      speedrun_api_endpoint: speedrun_api_endpoint,
      speedrun_url: speedrun_url
    } = fetch_speedrun(type)
    fetch_data(addr, speedrun_api_endpoint, speedrun_url, type)
  end

  def fetch_data(addr, speedrun_api_endpoint, speedrun_url, type) do
      res =
        speedrun_api_endpoint
        |> build_user_url(addr, :back)
        |> ExHttp.http_get()

      do_fetch_data(res, addr, speedrun_url, type)
  end

  defp do_fetch_data({:error, 404}, _addr, speedrun_url, _type) do
    {:error, "user has not registered speedrun@#{speedrun_url} yet"}
  end

  defp do_fetch_data({:ok, data}, addr, speedrun_url, type) do
    accepted_challenges =
      data
      |> Map.get("challenges", %{})
      |> Map.to_list()
      |> Enum.filter(fn {_name, challenge} ->
        Map.get(challenge, "status") == @status_accepted
      end)

    len = length(accepted_challenges)

    {:ok, %{
      chanllege_passed_num: len,
      link: build_user_url(speedrun_url, addr, :front),
      level: get_level(len),
      type: type
    }}
  end

  def get_level(len) when len <=3, do: 1
  def get_level(len) when len <=6, do: 2
  def get_level(_len), do: 3
end