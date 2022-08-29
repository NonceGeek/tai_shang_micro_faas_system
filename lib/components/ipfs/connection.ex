defmodule Components.Ipfs.Connection do
  @moduledoc """
  The IpfsConnection is used to create the struct that contains connection
  information of IPFS rest endpoint. By default it connects to `http://localhost:5001/api/v0`
  """
  alias Components.Ipfs.Connection


  @type t :: %__MODULE__{
    host: String.t(),
    base: String.t(),
    port: pos_integer()
  }

  defstruct host: "", base: "api/v0", port: 5001

  def conn(:read) do
    %Connection{host: get_read_ipfs_node() }
  end

  def conn(:write) do
    %Connection{host: get_write_ipfs_node() }
  end

  def get_read_ipfs_node() do
    %{read_ipfs_node: payload} = Constants.get_ipfs_node()
    payload
  end

  def get_write_ipfs_node() do
    %{write_ipfs_node: payload} = Constants.get_ipfs_node()
    payload
  end

end
