defmodule CodesOnChain.UserManager do
  @moduledoc """
    create a new User
    authority by ethereum signature, save a key value pair in K-V Table
  """
  require Logger
  alias Components.{KVHandler, Verifier}
  @valid_time 3600 # 1 hour

  def get_module_doc(), do: @moduledoc

  @doc """
    Create a new User after verify the ETH signatue and the msg sender.
    info format:
    {
      "ipfs_link": ipfs_link, or "gist_id": gist_id,
      "role": "DAO" or "User"
    }
  """
  def create_user(info, addr, msg, signature) do

    # update user info when the key does not exist
    with true <- Verifier.verify_message?(addr, msg, signature),
      true <- time_valid?(msg) do
      KVHandler.put(addr, info, "UserManager")
    else
      error ->
        {:error, inspect(error)}
    end
  end

  @doc """
    get user.
  """
  def get_user(addr), do: KVHandler.get(addr)

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
