defmodule CodesOnChain.SoulCardRender do
  @moduledoc """
    Generate SoulCard Data!
  """
  alias Components.Ipfs

  def get_module_doc(), do: @moduledoc

  @doc """
    Get data from IPFS with ipfs_cid.
  """
  def get_data(ipfs_cid) do
    conn = %Ipfs.Connection{}
    {:ok, payload} =
      Ipfs.API.get(conn, ipfs_cid)
    try do
      result =
        payload
        |> Poison.decode!()
        |> ExStructTranslator.to_atom_struct()
      {:ok, result}
    rescue
      error ->
        {:error, inspect(error)}
    end
  end
end