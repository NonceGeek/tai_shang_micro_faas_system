defmodule Components.Config do
  defmodule Networks do
    @my_infura_id Application.fetch_env!(:function_server_based_on_arweave, :my_infura_id)
    @external_resource "priv/networks.json"

    def get_full_networks(), do: get_networks_from_f()

    def get_network_names() do
      get_networks_from_f()
      |> Enum.map(fn {k, _v} -> k end)
    end

    def get_network(name) do
      {_k, v} =
        get_networks_from_f()
        |> Enum.find(fn {k, _v} -> k == name end)
      v
    end

    def get_networks_from_f() do
      @external_resource
      |> File.read!()
      |> String.replace("MY_INFURA_ID", @my_infura_id)
      |> Poison.decode!()
    end
  end


end
