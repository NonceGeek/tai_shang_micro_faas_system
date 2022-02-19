defmodule FunctionServerBasedOnArweaveWeb.FunctionRunnerController do
  use FunctionServerBasedOnArweaveWeb, :controller

  alias FunctionServerBasedOnArweaveWeb.ResponseMod
  alias ArweaveSdkEx.CodeRunner
  # ↓Modules for Function on Chain↓
  alias FunctionServerBasedOnArweave.DataToChain

  @node Application.fetch_env!(:function_server_based_on_arweave, :arweave_endpoint)
  @white_list ["5W4YR-EVCG_x2U5LEvTbdW87S1_ZQhfR5XCWP8fys3iAWnf2jPiPQxLXTQFZwtoWDsNwO3JFX27rljV0fFNCSEv5bnPaakelO4duj1yPx8_Q3dQyk7RUmWJ2EhSsSZNKC9oegooE9eOb1D21mFQxxZfhw2LwX-vzKy419wdh-0m33EVWkLU0zhoyyQUU6e51hnFRtO6Ve_3kc8r6sCJ0ohB10L13Ox4nTz57TN_3hzf_Rxmp7xCh-SyJI_nF31KGX29qXfFJ0TCUw9YCT7kg9WKdct6e9iIpcaS4DnZBpKhxhZ_XAP5nrv8-oNvank5xrd-X9Ru_gA1vZNHn1XBU6ND6AB9oTbHBEWinGlqxlw7_42vBTC_BnzAzOOtjqwbX1bZrnlX5n1sHDDVDIi0RNjAT1Lo0AIfoXYBkjHQGbaTbNCEclHiKOLxjTY0hEzuWsIcIvLoNLtTwxKwggZQ_0VkxLYj9qirYHQMTTpGj-d41KMIVyXNVK_xS5ZBJDoH0vaFapHYBRHd2etQfu0qWrS6kf6MMwtOm9GAZtcXSWPmbnqhG1nRGmx2bxgt6CRgyadDS5YePLKO5HLlsEetbnO0_21fK_SRHE6zxPK3dbK_1C13nhkmoDVvCIhSojVa06GEpdt4dUR700dX-LY9bIO6Ef60pzEhHGXe2zWJ7gsM"]

  def run(conn, payload) do
    %{tx_id: tx_id, params: params} =
      ExStructTranslator.to_atom_struct(payload)
    payload =
      with true <- check_white_list(tx_id),
        {:ok, %{code: code, if_record: if_record}} <- CodeRunner.get_ex_by_tx_id(@node, tx_id)
        do
          code
          |> do_run(params, tx_id, if_record)
          |> ResponseMod.get_res(:ok)
        else
          error ->
            error
            |> inspect()
            |> ResponseMod.get_res(:error)
      end
    json(conn, payload)
  end

  def do_run(code, params, tx_id, if_record) do
    res = %{output: output} =
      code
      |> CodeRunner.run_ex(params)
      |> Map.put(:code_online, @node <> "/" <> tx_id)

    if if_record == true do
      tx_id = DataToChain.record_func(params, output, tx_id)
      Map.put(res, :run_record, tx_id)
    else
      res
    end
  end

  def check_white_list(tx_id) do
    {:ok, %{raw_data: %{"owner" => owner}}} =
      ArweaveSdkEx.get_tx(@node, tx_id)
    owner in @white_list
  end


end
