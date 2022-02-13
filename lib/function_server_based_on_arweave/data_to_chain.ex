defmodule FunctionServerBasedOnArweave.DataToChain do

  alias FunctionServerBasedOnArweave.Coupon
  @node Application.fetch_env!(:function_server_based_on_arweave, :arweave_endpoint)
  @jwk ArweaveSdkEx.Wallet.read_jwk_json_from_file("/Users/liaohua/arweave_study/arweave-key-riehAVqG1ihV3kwNb3IandUy2OfLnilk3cj7fSuDEPw.json")
  @tags %{"Content-Type" => "data/run-record"}
  @reward_coefficient 3
  @python_path "/usr/local/bin/python3"

  def data_to_chain_using_couple(data, coupon_id) do
    coupon = Coupon.get_by_coupon_id(coupon_id)
    with false <- is_nil(coupon),
      false <- Coupon.is_used?(coupon) do
        {:ok, _} = Coupon.use_coupon(coupon)
        data_to_chain(data)
      else
        _else ->
        {:error, "the coupon_id is not valid"}
    end
  end

  def record_func(input, output, func_id) do
    payload =
      %{
        input: input,
        output: output,
        func: func_id
      }
    data_to_chain(payload)
  end

  def data_to_chain(data) do
    {tx, tx_id, _} = ArweaveSdkEx.Wallet.sign_tx(
      @node,
      Poison.encode!(data),
      @tags,
      @jwk,
      @reward_coefficient,
      @python_path
    )
    {:ok, _} = ArweaveSdkEx.send(@node, tx)
    tx_id
  end
end
