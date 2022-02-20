defmodule ArweaveNode do
  def get_node() do
    Application.fetch_env!(:function_server_based_on_arweave, :arweave_endpoint)
  end

  def get_explorer() do
    Application.fetch_env!(:function_server_based_on_arweave, :arweave_explorer)
  end
end
