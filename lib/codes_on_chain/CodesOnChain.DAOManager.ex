defmodule CodesOnChain.DAOManager do
  @moduledoc """
    create a new DAO
    authority by ethereum signature, save a key value pair in K-V Table:
    gist_id --> ipfs_link
    key: ethereum_addr, value: %{ipfs: ipfs_link}
  """
  require Logger
  alias Components.{KVHandler, Verifier}
  @valid_time 3600 # 1 hour

  def get_module_doc(), do: @moduledoc

  def get_module(), do: Atom.to_string(__MODULE__)

  @doc """
    Create a new DAO after verify the ETH signatue and the msg sender.
  """
  def create_dao(dao_info, addr, msg, signature) do

    # update dao info when the key does not exist
    with true <- Verifier.verify_message?(addr, msg, signature),
      true <- time_valid?(msg) do
      KVHandler.put(addr, dao_info, "DAOMaganer")
      # update unsigned message

    else
      error ->
        {:error, inspect(error)}
    end
  end

  @doc """
    get dao.
  """
  def get_dao(addr), do: KVHandler.get(addr)

  def time_valid?(msg) do
    [_, timestamp] = String.split(msg, "_")
    timestamp
    |> String.to_integer()
    |> do_time_valid?(timestamp_now())
  end
  defp do_time_valid?(time_before, time_now) when time_now - time_before < @valid_time do
    true
  end
  defp do_time_valid?(_time_before, _time_now), do: false

  def rand_msg(), do: "0x#{RandGen.gen_hex(16)}_#{timestamp_now()}"

  def timestamp_now(), do: :os.system_time(:second)

end
