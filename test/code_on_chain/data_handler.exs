defmodule CodeOnChain.SoulCard.DataHandlerTest do
  use ExUnit.Case

  alias CodesOnChain.SoulCard.DataHandler
  alias Components.KVHandler

  Ecto.Adapters.SQL.Sandbox.mode(FunctionServerBasedOnArweave.Repo, :manual)

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FunctionServerBasedOnArweave.Repo)
  end

  test "analyze github" do
    DataHandler.init_github_repos_white_map()

    payload = %{
      WeLightProject: %{
        if_in_owner: true,
        repo_list: [
          %{if_in: true, name: "tai_shang_micro_faas_system"},
          %{if_in: true, name: "Tai-Shang-Soul-Card"}
        ]
      }
    }

    assert payload == DataHandler.analyze_github("0x00000001", "leeduckgo")
    # assert payload == KVHandler.get("0x00000001", "SoulCard.DataHandler")
  end

  def data_user() do
    %{
      "awesome_things" => [
        %{"link" => "www.baidu.com", "title" => "Design for the transport"}
      ],
      "basic_info" => %{
        "avatar" => "test",
        "location" => "California",
        "name" => "Robert Fox",
        "skills" => [
          "Javascript",
          "C++",
          "Python",
          "HTML",
          "Node",
          "C#",
          "Java",
          "Javascript",
          "C++",
          "Python",
          "HTML",
          "Node",
          "C#",
          "Java"
        ],
        "slogan" => "Have more than 6 years of Digital Product Design experience.",
        "social_links" => %{
          "discord " => "hitchhacker@3691",
          "github_link " => "https://github.com/WeLightProject",
          "mirror_link " => "https://mirror.xyz/apecoder.eth",
          "twitter" => "https://twitter.com/Web3dAppCamp",
          "wechat " => "197626581"
        }
      },
      "daos_joined" => ["0x73c7448760517E3E6e416b2c130E3c6dB2026A1d"]
    }
  end

  def data_dao() do
    %{
      "awesome_things" => [%{"link" => "www.google.com", "title" => "Ho"}],
      "basic_info" => %{
        "avatar" => "https://leeduckgo.com/assets/images/ava.jpeg",
        "contract_addresses" => [%{"addr" => "0x0", "alias" => "BYAC NFT"}],
        "homepage" => "https://noncegeek.com",
        "location" => "California",
        "name" => "NonceGeekDAO",
        "slogan" => "sth_sth",
        "social_links" => %{
          "discord" => "hitchhacker@3691",
          "github_link" => "https://github.com/WeLightProject",
          "mirror_link" => "https://mirror.xyz/apecoder.eth",
          "twitter" => "https://twitter.com/Web3dAppCamp",
          "wechat" => "197626581"
        }
      },
      "core_members" => [],
      "members" => [],
      "partners" => [
        "0x01234567",
        %{"avatar" => "xxx", "link" => "https://google.com", "name" => "谷歌"}
      ],
      "sub_daos" => []
    }
  end

  test "data format" do
    test_user_return =
      {:ok, "all check is passed!"} == DataHandler.check_format(data_user(), "user")

    test_dao_return = {:ok, "all check is passed!"} == DataHandler.check_format(data_dao(), "dao")

    assert test_user_return
    assert test_dao_return
  end
end
