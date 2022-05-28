defmodule CodesOnChain.UserManager do
  @moduledoc """
    create a new User
    authority by ethereum signature, save a key value pair in K-V Table
  """
  require Logger
  alias Components.{KVHandler, Verifier, ModuleHandler}
  @valid_time 3600 # 1 hour

  def get_module_doc(), do: @moduledoc

  @doc """
    Create a new User after verify the ETH signatue and the msg sender.
    info format:
    {
      "ipfs_link": ipfs_link, or "gist_id": gist_id,
    }
  """
  def create_user(info, role, addr, msg, signature) do
    # update user info when the key does not exist
    with true <- Verifier.verify_message?(addr, msg, signature),
      true <- time_valid?(msg) do
      payload =
        addr
        |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
        |> do_create_user(role, info)
      KVHandler.put(addr, payload, "UserManager")
    else
      error ->
        {:error, inspect(error)}
    end
  end

  def do_create_user(nil, role, info) do
    Map.put(%{}, role, info)
  end
  def do_create_user(payload, role, info) do
    Map.put(payload, role, info)
  end

  @doc """
    get user.
  """
  def get_user(addr), do: KVHandler.get(addr, ModuleHandler.get_module_name(__MODULE__))

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
