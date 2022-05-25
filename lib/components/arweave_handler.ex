defmodule Components.ArweaveHandler do
  def get_content(tx_id) do
    ArweaveSdkEx.get_content_in_tx(Constants.get_arweave_node(), tx_id)
  end
end
