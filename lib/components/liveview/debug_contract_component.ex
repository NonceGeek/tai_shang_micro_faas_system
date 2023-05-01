defmodule Components.Liveview.DebugContractComponent do
  use TaiShangMicroFaasSystemWeb, :live_component
  require Logger

  alias TypeTranslator
  alias Ethereumex.HttpClient
  alias Constants

  @url "https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161"

  def render(assigns) do
    ~H"""
    <div id="web3-account" x-ref="web3Account" x-data="web3Account" phx-hook="Web3Account"
      x-init="() => { $watch('account.addr', addr => $dispatch('web3-changed', { addr })); $watch('network.chainId', chainId => $dispatch('web3-changed', { chainId })) }"
      @messageverified="handleVerifiedResult($event.detail.result)"
    >

      <div>
        <form phx-submit="get_it" phx-target={@myself}>
          <input type="text" name="address" placeholder="Your contract address"/>
          <input type="submit" value="Get it"/>
        </form>

        <div>
          get data is:  <%= @data %>
        </div>
      </div>

      <div>
        <button phx-click="gas" phx-target={@myself}>
          estimate gas
        </button>

        <span> gas fee: <%=@gas_fee %> </span>
        <span> gas price: <%=@gas_price %> </span>

      </div>

      <div x-data="{addr: '', func: '', params: ''}">
        <input type="text" x-model="addr" placeholder="0x0000000"/>
        <input type="text" x-model="func" placeholder="set"/>
        <input type="text" x-model="params" placeholder="[]" />
        <button @click="sendTransaction(addr, func, params)">
          Send Transaction
        </button>
      </div>

    </div>
    """
  end

  def update(_assigns, socket) do
    socket =
      socket
      |> assign(:data, "")
      |> assign(:gas_fee, "")
      |> assign(:gas_price, "")

    {:ok, socket}
  end

  def handle_event("get_it", %{"address" => address}, socket) do
    IO.inspect("get it")
    IO.inspect(address)

    transaction = %{
      "to" => address,
      "data" => TypeTranslator.get_data("get()", [])
    }

    {:ok, result} = HttpClient.eth_call(transaction, "latest", url: @url)

    socket = socket |> assign(:data, result |> TypeTranslator.data_to_int())
    {:noreply, socket}
  end

  def handle_event("gas", _, socket) do
    IO.inspect("gas")

    transaction = %{
      "to" => "0x545EDf91e91b96cFA314485F5d2A1757Be11d384",
      "data" => TypeTranslator.get_data("set(string)", ["test"])
    }

    {:ok, gas} = HttpClient.eth_estimate_gas(transaction, url: @url)

    {:ok, gas_price} = HttpClient.eth_gas_price(url: @url)

    socket =
      socket
      |> assign(:gas_fee, gas |> TypeTranslator.hex_to_int())
      |> assign(:gas_price, gas_price |> TypeTranslator.hex_to_int())

    {:noreply, socket}
  end

  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end
end
