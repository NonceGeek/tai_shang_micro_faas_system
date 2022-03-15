defmodule FunctionServerBasedOnArweave.DataToChain do

  alias FunctionServerBasedOnArweave.Coupon
  @node Application.fetch_env!(:function_server_based_on_arweave, :arweave_endpoint)
  # @jwk ArweaveSdkEx.Wallet.read_jwk_json_from_file("priv.json.secret")
  @jwk %{}
  @tags %{
    record: %{"Content-Type" => "data/run-record"}
  }
  @reward_coefficient 3

  # def data_to_chain_using_couple(data, coupon_id) do
  #   coupon = Coupon.get_by_coupon_id(coupon_id)
  #   with false <- is_nil(coupon),
  #     false <- Coupon.is_used?(coupon) do
  #       {:ok, _} = Coupon.use_coupon(coupon)
  #       data_to_chain(data, @tags.record)
  #     else
  #       _else ->
  #       {:error, "the coupon_id is not valid"}
  #   end
  # end

  def code_to_chain(data, language) do
    data_to_chain(data,build_tags(language))
  end

  def build_tags(language) do
    %{"Content-Type" => "application/#{language}"}
  end

  def record_func(input, output, func_id) do
    payload =
      %{
        input: input,
        output: output,
        func: func_id
      }
    payload
    |> Poison.encode()
    |> data_to_chain(@tags.record)
  end

  def data_to_chain(data, tags) do
    {tx, tx_id, _} = ArweaveSdkEx.Wallet.sign_tx(
      @node,
      data,
      tags,
      @jwk,
      @reward_coefficient
    )
    {:ok, _} = ArweaveSdkEx.send(@node, tx)
    tx_id
  end
end
