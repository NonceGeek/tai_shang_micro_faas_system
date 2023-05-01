defmodule TaiShangMicroFaasSystem.CodeFetchers.NFT do
  require Logger

  def get_data(func_str, params) do
    payload =
      func_str
      |> ABI.encode(params)
      |> Base.encode16(case: :lower)

    "0x" <> payload
  end

  def get_creators(nft_id) do
    data = get_data("creators(uint256)", [nft_id])

    result =
      Ethereumex.HttpClient.eth_call(
        %{
          data: data,
          to: Constants.get_contract_addr()},
          "latest",
          [url: Constants.get_contract_endpoint()]
        )
    case result do
      {:ok, value} ->
        TypeTranslator.data_to_str(value)

      {:error, _} ->
        Process.sleep(60000)
        do_get_from_nft(nft_id)
    end
  end

  def get_from_nft(nft_id) do
    ar_txid =
      nft_id
      |> do_get_from_nft()
      |> TypeTranslator.data_to_str()

    ArweaveSdkEx.get_content_in_tx(Constants.get_arweave_node(), ar_txid)
  end

  def do_get_from_nft(nft_id) do
    Logger.info("do get from nft #{Constants.get_contract_endpoint()}, and code_id is #{nft_id}")

    data = get_data("code(uint256)", [nft_id])

    result =
      Ethereumex.HttpClient.eth_call(
        %{
          data: data,
          to: Constants.get_contract_addr()},
          "latest",
          [url: Constants.get_contract_endpoint()]
        )
    case result do
      {:ok, value} ->
        value

      {:error, _} ->
        Process.sleep(60000)
        do_get_from_nft(nft_id)
    end
  end
end
