defmodule CodesOnChain.SoulCard.IpfsInteractor do
  @moduledoc """
    get/set data with IPFS
  """
  alias Components.Ipfs
  alias Components.{Verifier, MsgHandler}

  @upload_limit 500000

  def get_data(ipfs_cid) do
    conn = Ipfs.Connection.conn(:read)
    {:ok, payload} =
      Ipfs.API.get(conn, ipfs_cid)
    {:ok, Base.encode64(payload)}
  end

  @doc """
    put_data(addr, data, msg, signature)
    data is a base64-encoded webpage.
    the upload limit is 500_000 bit = 62.5 kb
  """
  def put_data(addr, data, msg, signature) do
    with true <- Verifier.verify_message?(addr, msg, signature),
      true <- MsgHandler.time_valid?(msg),
      true <-byte_size(data) >= @upload_limit  do

      data_handled = Base.decode64!(data)
      :write
      |> Ipfs.Connection.conn()
      |> Ipfs.API.add(data_handled)
    else
      error ->
        {:error, inspect(error)}
    end
  end

end