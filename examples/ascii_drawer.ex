defmodule CodesOnChain.AsciiDrawer do
  @moduledoc """
    This is an code-on-chain example:
      Draw ascii pic with param
  """

  def get_module_doc, do: @moduledoc

  @spec get_ascii(String.t()) :: String.t()
  def get_ascii("surprised"), do: "( ✧Д✧) OMG!!"
  def get_ascii("confuse"), do: "(๑•﹏•)⋆* ⁑⋆*"
  def get_ascii("happy"), do: "	(´ ∀ ` *)"
  def get_ascii("table_fliper"), do: "（╯ ͡° ل͜ ͡°）╯︵ ┻━┻"

end
