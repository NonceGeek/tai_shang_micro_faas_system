defmodule CodesOnChain.DAOManager do
  @moduledoc """
    create a new DAO
    authority by ethereum signature, save a key value pair in K-V Table:
    gist_id --> github_id
    key: ethereum_addr, value: {github_id: github_id, gist_id: gist_id}
  """
  require Logger
  alias Components.{GistHandler, KVHandler, Verifier}
  @unsigned_msg_key "unsigned_msg_0x5e6d1ac9"

  def get_module_doc(), do: @moduledoc

  def get_module(), do: Atom.to_string(__MODULE__)

  @doc """
    Create a new DAO after verify the ETH signatue and the msg sender.
  """
  def create_dao(addr, dao_info, signature) do

    # update dao info when the key does not exist
    with true <- Verifier.verify_message?(addr, dao_info, signature) do
      KVHandler.put(addr, dao_info, "DAOMaganer")
      # update unsigned message
      set_unsigned_msg()
    else
      error ->
        {:error, inspect(error)}
    end
  end

  @doc """
    get dao.
  """
  def get_dao(addr), do: KVHandler.get(addr)

  def get_unsigned_msg() do
    do_get_unsigned_msg(KVHandler.get(@unsigned_msg_key))
  end

  defp do_get_unsigned_msg(nil), do: ""
  defp do_get_unsigned_msg(msg), do: msg

  defp set_unsigned_msg(), do: KVHandler.put(@unsigned_msg_key, rand_msg(), get_module())

  def rand_msg(byte_size), do: "0x" <> RandGen.gen_hex(byte_size)
  def rand_msg(), do: "0x" <> RandGen.gen_hex(32)
  defp downcase(addr_list), do: Enum.map(addr_list, &String.downcase(&1))

  # ---
  def test_set_unsigned_msg(), do: set_unsigned_msg()
end
