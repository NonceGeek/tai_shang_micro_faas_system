defmodule Components.Ipfs do
    @moduledoc """
      get/set data with IPFS
    """
    alias Components.Ipfs.{Connection, API}

    def get_data(ipfs_cid) do
      conn = Connection.conn(:read)
      API.get(conn, ipfs_cid)
    end

    def get_json_data(ipfs_cid) do
      conn = Connection.conn(:read)
      {:ok, payload} =
        API.get(conn, ipfs_cid)
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

    def put_data(data) do
      conn = Connection.conn(:write)
      API.add(conn, data)
    end

  end
