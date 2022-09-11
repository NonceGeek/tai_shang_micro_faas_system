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

  def get_ipfs_node() do
    %{
      write_ipfs_node: Application.fetch_env!(:function_server_based_on_arweave, :write_ipfs_node),
      read_ipfs_node: Application.fetch_env!(:function_server_based_on_arweave, :read_ipfs_node)
    }
  end

  def get_github_token() do
    Application.fetch_env!(:function_server_based_on_arweave, :github_token)
  end

  def get_ipfs_api_keys() do
    [
      Application.fetch_env!(:function_server_based_on_arweave, :ipfs_project_id),
      Application.fetch_env!(:function_server_based_on_arweave, :ipfs_api_key_secret),
    ]
  end

end
