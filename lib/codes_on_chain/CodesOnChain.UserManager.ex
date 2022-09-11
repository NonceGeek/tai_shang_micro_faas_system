defmodule CodesOnChain.SoulCard.UserManager do
  @moduledoc """
    manager User
    authority by ethereum signature, save a key value pair in K-V Table
  """
  require Logger
  alias Components.{KVHandler, Verifier, ModuleHandler, MsgHandler}


  def get_module_doc(), do: @moduledoc

  @doc """
    Create a new User after verify the ETH signatue and the msg sender.
    info format:
    {
      "ipfs(optional)": ipfs_link for payload,
      "github_id": github_id(the unique one),
      "gist_id": gist_id,
      # or
      # "payload": payload,
    }

    it will generate item in kv table:

    - key: addr
    - value: {
      type(dao/user): {
        payload: payload,
        gist_id: gist_id,
        ipfs(optional): cid
      }
    }
    - created by: __MODULE__
  """
  def create_user(info, role, addr, msg, signature) do
    create_or_update_user(info, role, addr, msg, signature, :create)
  end

  def create_or_update_user(info, role, addr, msg, signature, type) do
    info = ExStructTranslator.to_atom_struct(info)
    # update user info when the key does not exist
    with true <- Verifier.verify_message?(addr, msg, signature),
      true <- MsgHandler.time_valid?(msg) do
      payload =
        addr
        |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
        |> generate_payload(role, info)

      handle_role(role, addr, info, type) # update role lists by role type

      KVHandler.put(addr, payload, ModuleHandler.get_module_name(__MODULE__))

    else
      error ->
        {:error, inspect(error)}
    end
  end


  defp generate_payload(nil, role, info) do
    Map.put(%{}, String.to_atom(role), info)
  end
  defp generate_payload(payload, role, info) do
    Map.put(payload, String.to_atom(role), info)
  end

  def handle_role("dao", addr, %{payload: %{basic_info: %{name: name}}}, :create) do
    # todo: remember to reject the rep one!
    insert_dao_name_and_addr(addr, name)
  end
  def handle_role("dao", addr, %{payload: %{basic_info: %{name: name}}}, :update) do
    update_dao_name_by_addr(addr, name)
  end

  def handle_role(_other_role, _addr, _info), do: :pass

  def insert_dao_name_and_addr(addr, name) do
    new_payload =
      "dao_map"
      |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
      |> handle_kv_value()
      |> Map.put(String.to_atom(addr), name)

    KVHandler.put("dao_map", new_payload, ModuleHandler.get_module_name(__MODULE__))

  end

  def update_dao_name_by_addr(addr, name) do
    %{name: name_in_database} =
      "dao"
      |> get_role_map()
      |> Enum.find(fn %{addr: addr_in_database} ->
        addr_in_database == addr
      end)
    dao_name_list = KVHandler.get("dao_name_list", ModuleHandler.get_module_name(__MODULE__))
    new_dao_name_list = replace_value_in_list(dao_name_list, name_in_database, name)
    KVHandler.put("dao_name_list", new_dao_name_list, ModuleHandler.get_module_name(__MODULE__))
  end

  def replace_value_in_list(the_list, old_value, new_value) do
    Enum.map(the_list, fn elem ->
      if old_value == elem do
        new_value
      else
        elem
      end
    end)
  end

  def get_role_map(role) do
    "#{role}_map"
    |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
    |> Enum.map(fn {elem, elem_name} ->
      %{
        addr: elem,
        name: elem_name
      }
    end)
  end

  @doc """
    example:\n
    get_role_list("dao", "addr")\n
    get_role_list("dao", "name")\n
  """
  def get_role_list(role, key) do
    "#{role}_map"
    |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
    |> Enum.map(fn {elem, elem_name} ->
      case key do
        "addr" ->
          elem
        "name" ->
          elem_name
      end
    end)
  end

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
  """
  def update_user(info, role, addr, msg, signature) do
    create_user(info, role, addr, msg, signature)
  end


  @doc """
    get user.
  """
  def get_user(addr), do: KVHandler.get(addr, ModuleHandler.get_module_name(__MODULE__))



end
