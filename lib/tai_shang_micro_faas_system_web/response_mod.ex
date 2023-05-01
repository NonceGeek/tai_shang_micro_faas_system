defmodule TaiShangMicroFaasSystemWeb.ResponseMod do
  @resp_success %{
    error_code: 0,
    error_msg: "success",
    result: ""
  }

  @resp_failure %{
    error_code: 1,
    error_msg: "",
    result: ""
  }

  def get_res(payload, :ok) do
    Map.put(@resp_success, :result, payload)
  end

  def get_res(payload, :error) do
    Map.put(@resp_failure, :error_msg, payload)
  end
end
