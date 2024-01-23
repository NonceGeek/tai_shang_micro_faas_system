defmodule Components.ArweaveHandler do
  def get_content(tx_id) do
    ArweaveSdkEx.get_content_in_tx(Constants.get_arweave_node(), tx_id)
  end

  def send_tx(data, tags) do
    node = Constants.get_arweave_node()
    # call the priv key local.
    jwt = ArweaveSdkEx.Wallet.read_jwk_json_from_file("../arweave_wallet.json")
    reward_coefficient = 1
    {tx_signed, id, _tx_unsigned} = 
      ArweaveSdkEx.Wallet.sign_tx(node, data, tags, jwt, reward_coefficient)
    {:ok, "success submit tx"} = 
      ArweaveSdkEx.send(node, tx_signed)
    id  
  end

end
