defmodule Components.Ipfs.Connection do
  @moduledoc """
  The IpfsConnection is used to create the struct that contains connection
  information of IPFS rest endpoint. By default it connects to `http://localhost:5001/api/v0`
  """



  @type t :: %__MODULE__{
    host: String.t(),
    base: String.t(),
    port: pos_integer()
  }

  defstruct host: Constants.get_ipfs_node(), base: "api/v0", port: 5001

end
