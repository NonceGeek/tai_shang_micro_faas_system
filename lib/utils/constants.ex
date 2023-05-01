defmodule Constants do
  def get_arweave_node() do
    Application.fetch_env!(:tai_shang_micro_faas_system, :arweave_endpoint)
  end

  def get_arweave_explorer() do
    Application.fetch_env!(:tai_shang_micro_faas_system, :arweave_explorer)
  end

  def get_contract_addr() do
    Application.fetch_env!(:tai_shang_micro_faas_system, :contract_addr)
  end

  def get_contract_endpoint() do
    Application.fetch_env!(:tai_shang_micro_faas_system, :contract_endpoint)
  end

  def get_eth_explorer() do
    Application.fetch_env!(:tai_shang_micro_faas_system, :eth_explorer)
  end

  def get_gallery() do
    Application.fetch_env!(:tai_shang_micro_faas_system, :gallery)
  end

  def get_ipfs_node() do
    %{
      write_ipfs_node: Application.fetch_env!(:tai_shang_micro_faas_system, :write_ipfs_node),
      read_ipfs_node: Application.fetch_env!(:tai_shang_micro_faas_system, :read_ipfs_node)
    }
  end

  def get_github_token() do
    Application.fetch_env!(:tai_shang_micro_faas_system, :github_token)
  end

  def get_ipfs_api_keys() do
    [
      Application.fetch_env!(:tai_shang_micro_faas_system, :ipfs_project_id),
      Application.fetch_env!(:tai_shang_micro_faas_system, :ipfs_api_key_secret),
    ]
  end

  def get_did_contract(:mainnet) do
    Application.fetch_env!(:tai_shang_micro_faas_system, :did_mainnet)
  end

  def get_did_contract(:testnet) do
    Application.fetch_env!(:tai_shang_micro_faas_system, :did_testnet)
  end

end
