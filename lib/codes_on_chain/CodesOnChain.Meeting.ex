defmodule CodesOnChain.Meeting do
  @moduledoc """
    put/get meeting info by signature.
    only in white list(in gist) can get the meeting info.
  """
  require Logger

  alias Components.{GistHandler, KvHandler, Verifier}

  @admin_addr "0x2913825f11434a5070797d32df3a892e28d891a0"
  @white_list %{
    gist_id: "4c8b6504b7eb23c8ca75cb3a705eb17b",
    file_name: "white_list_for_bewater_meeting.json"
  }

  def get_module_doc(), do: @moduledoc

  @doc """
    put meeting after verify the signatue and the msg sender.
  """
  def put_meeting(key, addr, meeting_info, signature) do
    with true <- Verifier.verify_message?(addr, meeting_info, signature),
      true <- String.downcase(addr) == @admin_addr do
        KvHandler.put(key, meeting_info)
      else
        error ->
          {:error, inspect(error)}
    end
  end

  @doc """
    get meeting after verify the signatue and check if in the whitelist.
  """
  def get_meeting(addr, meeting_info, signature) do
    with true <- Verifier.verify_message?(addr, meeting_info, signature),
      true <- addr in get_white_list() do
        {:ok, KvHandler.get(addr)}
      else
        error ->
        {:error, inspect(error)}
    end
  end

  defp get_white_list() do
    %{gist_id: gist_id, file_name: file_name} = @white_list
    %{files: files} = GistHandler.get_gist(gist_id)
    Logger.info(inspect(files))
    files |> Map.get(String.to_atom(file_name)) |> Map.get(:content) |> Poison.decode!()
  end

end
