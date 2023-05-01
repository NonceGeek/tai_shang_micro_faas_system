defmodule TaiShangMicroFaasSystemWeb.FunctionRunnerController do
  use TaiShangMicroFaasSystemWeb, :controller
  alias TaiShangMicroFaasSystem.OnChainCode
  alias TaiShangMicroFaasSystemWeb.ResponseMod
  alias ArweaveSdkEx.CodeRunner
  # ↓Modules for Function on Chain↓
  alias TaiShangMicroFaasSystem.DataToChain
  # @white_list ["5W4YR-EVCG_x2U5LEvTbdW87S1_ZQhfR5XCWP8fys3iAWnf2jPiPQxLXTQFZwtoWDsNwO3JFX27rljV0fFNCSEv5bnPaakelO4duj1yPx8_Q3dQyk7RUmWJ2EhSsSZNKC9oegooE9eOb1D21mFQxxZfhw2LwX-vzKy419wdh-0m33EVWkLU0zhoyyQUU6e51hnFRtO6Ve_3kc8r6sCJ0ohB10L13Ox4nTz57TN_3hzf_Rxmp7xCh-SyJI_nF31KGX29qXfFJ0TCUw9YCT7kg9WKdct6e9iIpcaS4DnZBpKhxhZ_XAP5nrv8-oNvank5xrd-X9Ru_gA1vZNHn1XBU6ND6AB9oTbHBEWinGlqxlw7_42vBTC_BnzAzOOtjqwbX1bZrnlX5n1sHDDVDIi0RNjAT1Lo0AIfoXYBkjHQGbaTbNCEclHiKOLxjTY0hEzuWsIcIvLoNLtTwxKwggZQ_0VkxLYj9qirYHQMTTpGj-d41KMIVyXNVK_xS5ZBJDoH0vaFapHYBRHd2etQfu0qWrS6kf6MMwtOm9GAZtcXSWPmbnqhG1nRGmx2bxgt6CRgyadDS5YePLKO5HLlsEetbnO0_21fK_SRHE6zxPK3dbK_1C13nhkmoDVvCIhSojVa06GEpdt4dUR700dX-LY9bIO6Ef60pzEhHGXe2zWJ7gsM"]
  @prefix "CodesOnChain."

  def get_codes(conn, %{
      "without_content" => "true"
    }) do
    codes =
      OnChainCode.get_all()
      |> Enum.map(fn elem ->
        elem
        |> Map.delete(:code)
        |> ExStructTranslator.struct_to_map()
        |> handle_name()
      end)
    json(conn, codes)
  end

  def get_codes(conn, _params) do
    codes =
      OnChainCode.get_all()
      |> Enum.map(fn elem ->
        elem
        |> ExStructTranslator.struct_to_map()
        |> handle_name()
      end)
    json(conn, codes)
  end

  def get_code(conn, %{"name" => name}) do
    %{code: code} =
      OnChainCode.get_by_name("#{@prefix}#{name}")
    json(conn, %{code: code})
  end

  def get_code(conn, %{"tx_id" =>tx_id}) do
    %{code: code} =
      OnChainCode.get_by_tx_id(tx_id)
    json(conn, %{code: code})
  end

  def handle_name(%{name: name} = code) do
    %{code | name: String.replace(name, @prefix, "")}
  end

  def run(conn, payload) do
    result =
      payload
      |> ExStructTranslator.to_atom_struct()
      |> do_run()
      |> handle_param()
    json(conn, %{result: result})
  end

  def do_run(%{
      tx_id: tx_id,
      func_name: func_name,
    params: params}) do
    %{name: name} = OnChainCode.get_by_tx_id(tx_id)
    CodeRunner.run_func(
      "#{@prefix}#{name}",
      func_name,
      params
    )
  end

  def do_run(%{
    name: name,
    func_name: func_name,
    params: params}) do
    CodeRunner.run_func(
      "#{@prefix}#{name}",
      func_name,
      params
    )
  end

  def handle_param({:ok, result}) do
    %{
      status: :ok,
      payload: do_handle_param(result)
    }
  end
  def handle_param({:error, result}) do
    %{
      status: :error,
      payload: do_handle_param(result)
    }
  end

  def handle_param(payload) when is_struct(payload) do
    ExStructTranslator.struct_to_map(payload)
  end

  def handle_param(payload), do: payload

  def do_handle_param(result) when is_struct(result) do
    ExStructTranslator.struct_to_map(result)
  end

  def do_handle_param(payload), do: payload

end
