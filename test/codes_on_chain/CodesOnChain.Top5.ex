defmodule CodesOnChain.Top5Test do
  use ExUnit.Case

  alias CodesOnChain.Top5

  test "test handle_file_name" do
       assert "CodesOnChain.Top5" == Top5.handle_file_name(:'CodesOnChain.Top5.ex')
       assert "CodesOnChain" == Top5.handle_file_name(:'CodesOnChain')
       assert "CodesOnChain" == Top5.handle_file_name(:'CodesOnChain.ex')
  end
end