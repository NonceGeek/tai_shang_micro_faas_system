defmodule Components.Aptos do
   @moduledoc """
    An Example that shows how to use the web3_move_ex library!
  """
  alias Web3AptosEx.Aptos
  import Web3AptosEx.Aptos
  require Logger

  def gen_acct_and_get_faucet(network_type) do
    {:ok, acct} = Aptos.generate_keys()
    {:ok, client} = Aptos.connect(network_type)
    {:ok, _res} = Aptos.get_faucet(client, acct)
    Process.sleep(2000)  # 用 2 秒等待交易成功
    %{res: Aptos.get_balance(client, acct), acct: acct}
  end

end
