defmodule CodeOnChain.SoulCard.UserManagerTest do
  use ExUnit.Case

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

  test "create user" do
    {%{addr: addr}, msg, %{sig: signature}} = gen_rand_acct_msg_and_sig()
    UserManager.create_user(data_user(), "user", addr, msg, signature)
  end

  test "create user dao" do
    {%{addr: addr}, msg, %{sig: signature}} = gen_rand_acct_msg_and_sig()
    UserManager.create_user(data_dao(), "dao", addr, msg, signature)
  end

  def gen_rand_acct_msg_and_sig() do
    %{priv: priv} = acct = EthWallet.generate_keys()
    msg = DataHandler.rand_msg()
    sig_full = sign(msg, priv)
    {acct, msg, sig_full}
  end

  def sign(msg, priv) do
    EthWallet.sign_compact(msg, priv)
  end
end
