defmodule CodesOnChain.SoulCard.Test do
  @moduledoc """
    Tests for SoulCard Snippets.
  """
  alias CodesOnChain.SoulCard.{DataHandler, IpfsInteractor, UserManager}
  alias Components.{KVHandler}
  def get_module_doc(), do: @moduledoc

  # +-
  # | Funcs in CodesOnChain.SoulCard.DataHandler
  # +-
  def test_analyze_github() do
    DataHandler.init_github_repos_white_map() # init it if not init yet.
    payload = %{
      WeLightProject: %{
        if_in_owner: true,
        repo_list: [
          %{if_in: true, name: "tai_shang_micro_faas_system"},
          %{if_in: true, name: "Tai-Shang-Soul-Card"}
        ]
      }
    }
    test_func_return =
      (payload == DataHandler.analyze_github("0x00000001", "leeduckgo"))
    test_data_in_kv =
      (payload == KVHandler.get("0x00000001", "SoulCard.DataHandler"))
    %{
      test_func_return: test_func_return,
      test_data_in_kv: test_data_in_kv
    }
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
        "skills" => ["Javascript", "C++", "Python", "HTML", "Node", "C#", "Java",
         "Javascript", "C++", "Python", "HTML", "Node", "C#", "Java"],
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

  def test_data_format() do

    test_user_return =
      ({:ok, "all check is passed!"} == DataHandler.check_format(data_user(), "user"))

    test_dao_return =
      ({:ok, "all check is passed!"} == DataHandler.check_format(data_dao(), "dao"))
    %{
      test_user_return: test_user_return,
      test_dao_return: test_dao_return
    }
  end

  # +-
  # | Funcs in CodesOnChain.SoulCard.IpfsInteractor
  # +-
  def test_get_data() do
    # Base 64 of "hello, world"
    test_read_return =
      {:ok, "aGVsbG8sIHdvcmxk"} == IpfsInteractor.get_data("QmbJtyu82TQSHU52AzRMXBENZGQKYqPsmao9dPuTeorPui")
    %{
      test_read_return: test_read_return
    }
  end

  # +-
  # | Funcs in CodesOnChain.SoulCard.UserManager
  # +-

  def test_create_user() do
    {%{addr: addr}, msg, %{sig: signature}} = gen_rand_acct_msg_and_sig()
    UserManager.create_user(data_user(), "user", addr, msg, signature)
  end

  def test_create_user_dao() do
    {%{addr: addr}, msg, %{sig: signature}} = gen_rand_acct_msg_and_sig()
    UserManager.create_user(data_dao(), "dao", addr, msg, signature)
  end

  # +-
  # | Tools.
  # +-
  def gen_rand_acct_msg_and_sig() do
    %{priv: priv} = acct =  EthWallet.generate_keys()
    msg = DataHandler.rand_msg()
    sig_full = sign(msg, priv)
    {acct, msg, sig_full}
  end

  def sign(msg, priv) do
    EthWallet.sign_compact(msg, priv)
  end
end
