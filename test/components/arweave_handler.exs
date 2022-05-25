defmodule Components.ArweaveHandlerTest do
  use ExUnit.Case
  alias Components.ArweaveHandler

  test "do get content" do
    tx_id = "rr5p8_FJ4l0KvjhCtIzmxfBNN3UiN2Cv2Ml08ys9odE"
    {res, _} = ArweaveHandler.get_content(tx_id)
    assert :ok == res
  end
end
