defmodule CodesOnChain.Verifier do
  @moduledoc """
    An Example to verify the ethereum msg signature.
  """

  @ethereum_message_prefix "\x19Ethereum Signed Message:\n"
  @base_recovery_id 27
  @base_recovery_id_eip_155 35

  def get_module_doc, do: @moduledoc

  @doc "Verifies if a message was signed by a wallet keypair given a the public address, message, signature"
  @spec verify_message?(String.t(), String.t(), String.t()) :: boolean
  def verify_message?(public_address, message, signature) do
    hash = hash_message(message)

    case verify_signature(hash, signature) do
      {:ok, recovered_key} ->
        recovered_address = get_address(recovered_key)
        String.downcase(recovered_address) == String.downcase(public_address)

      _ ->
        false
    end
  end

  @doc "Get Public Ethereum Address from Public Key"
  @spec get_address(String.t()) :: String.t()
  def get_address(public_key) do
    <<4::size(8), key::binary-size(64)>> = public_key
    <<_::binary-size(12), eth_address::binary-size(20)>> = ExKeccak.hash_256(key)
    "0x#{Base.encode16(eth_address)}"
  end

  # ------ simple test ------
  def test_valid_verify_message() do
    verify_message?(
      "0x132b9dbb51f336d6f43e4b8078b5c5ae737e2ef9",
      "test",
      "0x57d23d24c09c627f17b9696df8ce442ee719aa0a8e7d888dea25b39cd740c4b661cc2c2901af114f44e1c43d09660db728d1ee334878217a96894bca5eada4b21b"
    )
  end

  def test_invalid_verify_message() do
    verify_message?(
      "0x132b9dbb51f336d6f43e4b8078b5c5ae737e2ef9",
      "test",
      "0x66d23d24c09c627f17b9696df8ce442ee719aa0a8e7d888dea25b39cd740c4b661cc2c2901af114f44e1c43d09660db728d1ee334878217a96894bca5eada4b21b"
    )
  end

  # ------ defps ------

  # @doc Hashes a binary message and removes ethereum message prefix & length from the beginning of the binary.
  defp hash_message(message) when is_binary(message) do
    eth_message = @ethereum_message_prefix <> get_message_length_bytes(message) <> message
    ExKeccak.hash_256(eth_message)
  end

  defp get_message_length_bytes(message) when is_binary(message) do
    Integer.to_string(String.length(message))
  end

  @doc "Destructure a signature to r, s, v to be used by Secp256k1 recover"
  defp destructure_sig(sig) do
    r = sig |> String.slice(2, 64) |> Base.decode16!(case: :lower)
    s = sig |> String.slice(66, 64) |> Base.decode16!(case: :lower)

    {v, _} =
      sig
      |> String.slice(130, 2)
      |> String.upcase()
      |> Integer.parse(16)

    {:ok, v, _} = decode_signature(v)

    {r, s, v}
  end

  defp decode_signature(signature_v) do
    # There are three cases:
    #  1. It is a simple 0,1 recovery id
    #  2. It is 0,1 + base recovery_id, in which case we need to subtract that and add EIP-155
    #  3. It is already EIP-155 compliant

    cond do
      is_simple_signature?(signature_v) ->
        {:ok, signature_v, nil}

      is_pre_eip_155_signature?(signature_v) ->
        {:ok, signature_v - @base_recovery_id, nil}

      true ->
        network_id = trunc((signature_v - @base_recovery_id_eip_155) / 2)

        {:ok, signature_v - @base_recovery_id_eip_155 - network_id * 2, network_id}
    end
  end

  # Returns true is signature is simple 0,1-type recovery_id
  defp is_simple_signature?(v), do: v < @base_recovery_id

  # Returns true if signature is pre EIP-155 Ethereum signature
  defp is_pre_eip_155_signature?(v), do: v < @base_recovery_id_eip_155

  defp verify_signature(hash, signature) do
    {r, s, v} = destructure_sig(signature)
    :libsecp256k1.ecdsa_recover_compact(hash, r <> s, :uncompressed, v)
  end

end
