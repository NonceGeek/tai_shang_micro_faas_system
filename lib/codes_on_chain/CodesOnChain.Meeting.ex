defmodule CodesOnChain.Meeting do
  @moduledoc """
    put/get meeting info by signature.
    only in white list(in gist) can get the meeting info.
  """
  require Logger

  alias Components.{GistHandler, KVHandler, Verifier}

  @unsigned_msg_key "sign_msg_0x5e6d1ac9"
  @white_list %{
    gist_id: "4c8b6504b7eb23c8ca75cb3a705eb17b",
    file_name: "white_list_for_bewater_meeting.json"
  }

  def get_module_doc(), do: @moduledoc

  def get_module(), do: Atom.to_string(__MODULE__)

  @doc """
    put meeting after verify the signatue and the msg sender.
  """
  def put_meeting(key, addr, meeting_info, signature) do
    %{admins: admins} = get_white_list()
    with true <- Verifier.verify_message?(addr, meeting_info, signature),
      true <- String.downcase(addr) in admins do
        # update meeting info
        KVHandler.put(key, meeting_info, get_module())
        # update unsigned message
        set_unsigned_msg()
      else
        error ->
          {:error, inspect(error)}
    end
  end

  @doc """
    get meeting after verify the signatue and check if in the whitelist.
  """
  def get_meeting(key, addr, msg, signature) do
    %{members: members} = get_white_list()
    with true <- Verifier.verify_message?(addr, msg, signature),
      true <- String.downcase(addr) in members do
        {:ok, KVHandler.get(key)}
      else
        error ->
        {:error, inspect(error)}
    end
  end
  def get_meeting(key, addr, signature) do
    %{members: members} = get_white_list()
    with true <- Verifier.verify_message?(addr, get_unsigned_msg(), signature),
      true <- String.downcase(addr) in members do
        {:ok, KVHandler.get(key)}
      else
        error ->
        {:error, inspect(error)}
    end
  end

  @spec get_white_list() :: map()
  def get_white_list() do
    %{gist_id: gist_id, file_name: file_name} = @white_list
    %{files: files} = GistHandler.get_gist(gist_id)
    Logger.info(inspect(files))
    %{admins: admins, members: members} =
      files
      |> Map.get(String.to_atom(file_name))
      |> Map.get(:content)
      |> Poison.decode!()
      |> ExStructTranslator.to_atom_struct()

    %{admins: downcase(admins), members: downcase(members)}
  end

  def get_unsigned_msg() do
    do_get_unsigned_msg(KVHandler.get(@unsigned_msg_key))
  end
  defp do_get_unsigned_msg(nil), do: ""
  defp do_get_unsigned_msg(msg), do: msg

  defp set_unsigned_msg(), do: KVHandler.put(@unsigned_msg_key, rand_msg(), get_module())


  def rand_msg(byte_size), do: "0x" <> RandGen.gen_hex(byte_size)
  def rand_msg(), do: "0x" <> RandGen.gen_hex(32)
  defp downcase(addr_list), do:  Enum.map(addr_list, &(String.downcase(&1)))

  # ---
  def test_set_unsigned_msg(), do: set_unsigned_msg()

end
