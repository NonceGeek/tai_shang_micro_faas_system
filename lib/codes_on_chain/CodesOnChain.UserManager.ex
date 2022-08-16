defmodule CodesOnChain.UserManager do
  @moduledoc """
    create a new User
    authority by ethereum signature, save a key value pair in K-V Table
  """
  require Logger
  alias Components.{KVHandler, Verifier, ModuleHandler}
  alias Components.{GistHandler, Ipfs}
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

      # payload = %{role: %{gist_id or ipfs_link}}
      payload =
        addr
        |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
        |> do_create_user(role, info)

      handle_role(role, addr, info) # update role lists by role type

      KVHandler.put(addr, payload, ModuleHandler.get_module_name(__MODULE__))
    else
      error ->
        {:error, inspect(error)}
    end
  end


  defp do_create_user(nil, role, info) do
    Map.put_new(%{}, String.to_atom(role), info)
  end
  defp do_create_user(payload, role, info) do
    Map.put_new(payload, String.to_atom(role), info)
  end

  def handle_role("dao", addr, %{gist: gist_id}) do
    %{files: files} = Components.GistHandler.get_gist(gist_id)
    name = get_name(files, :gist)
    insert_dao_name_and_addr(addr, name)
  end

  def handle_role("dao", addr, %{ipfs: cid}) do
    {:ok, res} = Ipfs.API.get(%Ipfs.Connection{}, cid)
    name = get_name(res, :ipfs)
    insert_dao_name_and_addr(addr, name)
  end

  def handle_role(role, addr, _info) do
    payloads =
      "#{role}_list"
      |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
      |> handle_kv_value()
      |> add_if_not_exist(addr)
    KVHandler.put("#{role}_list", payloads, ModuleHandler.get_module_name(__MODULE__))
  end

  def get_name(%{"basic_info.json": %{name: name}}, :gist) do
    {:ok, name}
  end
  def get_name(_others, :gist), do: {:error, "the file is not regular"}
  def get_name(payload, :ipfs) do
    res =
      payload
      |> Poison.decode!()
      |> Map.get("name")
    do_get_name(res)
  end
  def do_get_name(nil), do:  {:error, "the file is not regular"}
  def do_get_name(name), do:  {:ok, name}

  def insert_dao_name_and_addr(addr, name) do
    payloads =
      "dao_list"
      |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
      |> handle_kv_value()
      |> add_if_not_exist(addr)
    name_payloads =
      "dao_name_list"
      |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
      |> handle_kv_value()
      |> add_if_not_exist(name)

    KVHandler.put("dao_list", payloads, ModuleHandler.get_module_name(__MODULE__))
    KVHandler.put("dao_name_list", name_payloads, ModuleHandler.get_module_name(__MODULE__))

  end

  def get_role_list("dao") do
    payload = KVHandler.get("dao_list", ModuleHandler.get_module_name(__MODULE__))
    payload_name = KVHandler.get("dao_name_list", ModuleHandler.get_module_name(__MODULE__))
    payload
    |> Enum.zip(payload_name)
    |> Enum.map(fn {elem, elem_name} ->
      %{
        name: elem_name,
        addr: elem
      }
    end)
  end
  def get_role_list(role), do: KVHandler.get("#{role}_list", ModuleHandler.get_module_name(__MODULE__))

  def handle_kv_value(nil), do: []
  def handle_kv_value(others), do: others

  def add_if_not_exist(list, addr) do
    case Enum.find(list, &(&1==addr)) do
      nil ->
        list ++ [addr]
      _ ->
        list
    end
  end

  @doc """
    Update a existed User after verify the ETH signatue and the msg sender.
    info format:
      {
        "ipfs_link": ipfs_link, or "gist_id": gist_id,
      }
  """
  def update_user(info, role, addr, msg, signature) do
    with true <- Verifier.verify_message?(addr, msg, signature),
      true <- time_valid?(msg) do

        payload =
          addr
          |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
          |> do_update_user(role, info)

      KVHandler.put(addr, payload, ModuleHandler.get_module_name(__MODULE__))
    else
      error ->
        {:error, inspect(error)}
    end
  end

  # update both
  def do_update_user(payload, role, %{ipfs: _cid, gist: _gist_id} = info) do
    Map.put(payload, String.to_atom(role), info)
  end
   # update cid
  def do_update_user(payload, role, %{ipfs: cid}) do
    payload
    |> Map.get(String.to_atom(role))
    |> Map.put(:ipfs, cid)
  end
  # update gist
  def do_update_user(payload, role, %{gist: gist_id}) do
    payload
    |> Map.get(String.to_atom(role))
    |> Map.put(:gist, gist_id)
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
