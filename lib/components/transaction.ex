defmodule Components.Transaction do
  alias Ethereumex.HttpClient
  defstruct from: <<>>, to: <<>>, gas_price: 0, gas_limit: 0, value: 0, init: <<>>, data: <<>>

  @base_recovery_id_eip_155 35
    
  def send(chain_id, priv_key, tx, nonce, others) do
    items = prepare_items(tx, nonce, others)

    # Refer to EIP-155, we SHOULD hash nine rlp encoded elements:
    # (nonce, gasprice, startgas, to, value, data, chainid, 0, 0)
    hashed_tx = hash(items ++ [encode_unsigned(chain_id), <<>>, <<>>])
    {v, r, s} = sign(hashed_tx, priv_key, chain_id)
    signature = [
           encode_unsigned(v),
           encode_unsigned(r),
           encode_unsigned(s)
         ]

    raw_tx =
      (items ++ signature)
      |> ExRLP.encode(encoding: :hex)
    HttpClient.eth_send_raw_transaction("0x" <> raw_tx, others)
  end

  def send(chain_id, priv_key, tx, others) do
    items = prepare_items(tx, others)

    # Refer to EIP-155, we SHOULD hash nine rlp encoded elements:
    # (nonce, gasprice, startgas, to, value, data, chainid, 0, 0)
    hashed_tx = hash(items ++ [encode_unsigned(chain_id), <<>>, <<>>])
    {v, r, s} = sign(hashed_tx, priv_key, chain_id)
    signature = [
           encode_unsigned(v),
           encode_unsigned(r),
           encode_unsigned(s)
         ]

    raw_tx =
      (items ++ signature)
      |> ExRLP.encode(encoding: :hex)
    HttpClient.eth_send_raw_transaction("0x" <> raw_tx, others)
  end

  def get_gas(contract_address, behaviour, payloads, others) do
    transaction = %{
      "to" => contract_address,
      "data" => TypeTranslator.get_data(behaviour, payloads)
    }

    {:ok, gas_limit} = HttpClient.eth_estimate_gas(transaction, others)
    {:ok, gas_price} = HttpClient.eth_gas_price(others)

    {
      TypeTranslator.hex_to_int(gas_limit),
      TypeTranslator.hex_to_int(gas_price)
    }
  end

  defp prepare_items(tx, nonce, _others) do

    [
      encode_unsigned(nonce),
      encode_unsigned(tx.gas_price),
      encode_unsigned(tx.gas_limit),
      tx.to |> String.replace("0x", "") |> Base.decode16!(case: :mixed),
      encode_unsigned(tx.value || 0),
      if(tx.to == <<>>, do: <<>>, else: tx.data)
    ]
  end

  defp prepare_items(tx, others) do
    nonce = get_nonce(tx.from, others)

    [
      encode_unsigned(nonce),
      encode_unsigned(tx.gas_price),
      encode_unsigned(tx.gas_limit),
      tx.to |> String.replace("0x", "") |> Base.decode16!(case: :mixed),
      encode_unsigned(tx.value || 0),
      if(tx.to == <<>>, do: <<>>, else: tx.data)
    ]
  end

  defp hash(items) do
    items
    |> ExRLP.encode(encoding: :binary)
    |> ExKeccak.hash_256()
  end

  defp sign(hashed_tx, priv_key, chain_id) do
    {:ok, {<<r::size(256), s::size(256)>>, recovery_id}} =
      ExSecp256k1.sign_compact(hashed_tx, priv_key)

    # Refer to EIP-155
    recovery_id = chain_id * 2 + @base_recovery_id_eip_155 + recovery_id

    {recovery_id, r, s}
  end

  def get_nonce(wallet_address, others) do
    {:ok, hex} = HttpClient.eth_get_transaction_count(wallet_address, "latest", others)

    TypeTranslator.hex_to_int(hex)
  end

  defp encode_unsigned(0), do: <<>>
  defp encode_unsigned(number), do: :binary.encode_unsigned(number)
end