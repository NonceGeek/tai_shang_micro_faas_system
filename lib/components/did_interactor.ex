defmodule Components.Aptos.DIDInteractor do
  @moduledoc """
    An Example that shows how to call DID smart contract by web3_move_ex library!
  """
  alias Web3AptosEx.Aptos
  require Logger

  def gen_acct_and_get_faucet(network_type) do
    {:ok, acct} = Aptos.generate_keys()
    {:ok, client} = Aptos.connect(network_type)
    {:ok, _res} = Aptos.get_faucet(client, acct)
    Process.sleep(2000)  # 用 2 秒等待交易成功
    %{res: Aptos.get_balance(client, acct), acct: acct}
  end

  # +------+
  # | init |
  # +------+

  def call_func_init(client, acct, contract_addr, did_type, description) do
    Aptos.call_func(client, acct, contract_addr, "init", "init", [did_type, description], [:u64, :string])
  end


  # +-----------------+
  # | addr_aggregator |
  # +-----------------+

  def call_func_delete_addr(
    client,
    acct,
    contract_addr,
    addr)  do
      Aptos.call_func(
        client,
        acct,
        contract_addr,
        "addr_aggregator",
        "delete_addr",
        [addr],
        ["string"]
      )
  end

  def call_func_update_addr_info(
    client,
    acct,
    contract_addr,
    addr,
    chains,
    description,
    spec_fields,
    expired_at) do
    Aptos.call_func(
      client,
      acct,
      contract_addr,
      "addr_aggregator",
      "update_addr_info",
      [addr, chains, description, spec_fields, expired_at],
      ["string", "vector<string>", "string", "string", "u64"]
    )
  end

  def call_func_update_addr_info_for_non_verification(
    client,
    acct,
    contract_addr,
    addr,
    chains,
    description,
    spec_fields,
    expired_at) do
    Aptos.call_func(
      client,
      acct,
      contract_addr,
      "addr_aggregator",
      "update_addr_info_for_non_verification",
      [addr, chains, description, spec_fields, expired_at],
      ["string", "vector<string>", "string", "string", "u64"]
    )
  end
  @doc """
    // Update addr aggregator description.
    public entry fun update_addr_aggregator_description(acct: &signer, description: String) acquires AddrAggregator {
        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        addr_aggr.description = description;
    }
  """
  def call_func_update_addr_aggregator_description(client, acct, contract_addr, description) do
    Aptos.call_func(
      client,
      acct,
      contract_addr,
      "addr_aggregator",
      "update_addr_aggregator_description",
      [description],
      ["string"]
    )
  end

  @doc """
    public entry fun add_addr(
        acct: &signer,
        addr_type: u64,
        addr: String,
        pubkey: String,
        chains: vector<String>,
        description: String,
        spec_fields: String,
        expired_at: u64
    ) acquires AddrAggregator {
      ……
    }
  """
  def call_func_add_addr(client, acct, contract_addr, addr_type, addr, pubkey, chains, description, sepc_fields, expired_at) do
    Aptos.call_func(
      client,
      acct,
      contract_addr,
      "addr_aggregator",
      "add_addr",
      [addr_type, addr, pubkey, chains, description, sepc_fields, expired_at],
      ["u64", "string", "string", "vector<string>", "string", "string", "u64"]
    )
  end

  def call_func_update_eth_addr(client, acct, contract_addr, addr, signature) do
    Aptos.call_func(
      client,
      acct,
      contract_addr,
      "addr_aggregator",
      "update_eth_addr",
      [addr, signature],
      ["string", "string"]
    )
  end

  # +--------------------+
  # | service aggregator |
  # +--------------------+

  @doc """
      public entry fun add_service(
        acct: &signer,
        name: String,
        description: String,
        url: String,
        verification_url: String,
        spec_fields: String,
        expired_at: u64
    ) acquires ServiceAggregator {
        ……
    }
  """
  def call_func_add_service(client, acct, contract_addr, name, description, url, verification_url, spec_fields, expired_at) do
    Aptos.call_func(
      client,
      acct,
      contract_addr,
      "service_aggregator",
      "add_service",
      [name, description, url, verification_url, spec_fields, expired_at],
      ["string", "string", "string", "string", "string", "u64"]
    )
  end

  def call_func_update_service(client, acct, contract_addr, name, new_description, new_url, new_verification_url, new_spec_fields, new_expired_at) do
    Aptos.call_func(
      client,
      acct,
      contract_addr,
      "service_aggregator",
      "update_service",
      [name, new_description, new_url, new_verification_url, new_spec_fields, new_expired_at],
      ["string", "string", "string", "string", "string", "u64"]
    )
  end

  @doc """
    public entry fun batch_update_services(
      acct: &signer,
        names: vector<String>,
        descriptions: vector<String>,
        urls: vector<String>,
        verification_urls: vector<String>,
        spec_fieldss: vector<String>,
        expired_ats: vector<u64>) acquires ServiceAggregator {
          ……
        }
  """
  def call_func_batch_update_services(client, acct, contract_addr, names, descriptions, urls, verification_urls, spec_fieldss, expired_ats) do
    Aptos.call_func(
      client,
      acct,
      contract_addr,
      "service_aggregator",
      "batch_update_services",
      [names, descriptions, urls, verification_urls, spec_fieldss, expired_ats],
      ["vector<string>", "vector<string>", "vector<string>", "vector<string>", "vector<string>", "vector<u64>"]
    )
  end

  @doc """
    public entry fun batch_add_services(
      acct: &signer,
        names: vector<String>,
        descriptions: vector<String>,
        urls: vector<String>,
        verification_urls: vector<String>,
        spec_fieldss: vector<String>,
        expired_ats: vector<u64>) acquires ServiceAggregator {
          ……
        }
  """
  def call_func_batch_add_services(client, acct, contract_addr, names, descriptions, urls, verification_urls, spec_fieldss, expired_ats) do
    Aptos.call_func(
      client,
      acct,
      contract_addr,
      "service_aggregator",
      "batch_add_services",
      [names, descriptions, urls, verification_urls, spec_fieldss, expired_ats],
      ["vector<string>", "vector<string>", "vector<string>", "vector<string>", "vector<string>", "vector<u64>"]
    )
  end


  @doc """
    // Public entry fun delete service.
    public entry fun delete_service(
        acct: &signer,
        name: String) acquires ServiceAggregator {
          ……
        }
  """
  def call_func_delete_service(client, acct, contract_addr, name) do
    Aptos.call_func(
      client,
      acct,
      contract_addr,
      "service_aggregator",
      "delete_service",
      [name],
      ["string"]
    )
  end
end
