defmodule Components.NetworkHandler do
  @my_infura_id Application.fetch_env!(:function_server_based_on_arweave, :my_infura_id)
  @external_resource "priv/networks.json"

  def get_networks() do
    @external_resource
    |> File.read!()
    |> String.replace("MY_INFURA_ID", @my_infura_id)
    |> Poison.decode!()
  end
end
