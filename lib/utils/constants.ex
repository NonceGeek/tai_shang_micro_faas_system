defmodule Constants do
  def get_arweave_node() do
    Application.fetch_env!(:function_server_based_on_arweave, :arweave_endpoint)
  end

  def get_arweave_explorer() do
    Application.fetch_env!(:function_server_based_on_arweave, :arweave_explorer)
  end

  def get_contract_addr() do
    Application.fetch_env!(:function_server_based_on_arweave, :contract_addr)
  end

  def get_contract_endpoint() do
    Application.fetch_env!(:function_server_based_on_arweave, :contract_endpoint)
  end

  def get_eth_explorer() do
    Application.fetch_env!(:function_server_based_on_arweave, :eth_explorer)
  end

  def get_gallery() do
    Application.fetch_env!(:function_server_based_on_arweave, :gallery)
  end

end
