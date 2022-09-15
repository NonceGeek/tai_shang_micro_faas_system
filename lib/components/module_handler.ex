defmodule Components.ModuleHandler do
  @doc """
    Example:  Components.ModuleHandler.get_module_name(Components.ModuleHandler.Test)
  """
  def get_module_name(module_name) do
    [_, _, module] =
      module_name
      |> get_module_name(:full)
      |> String.split(".", parts: 3)
    module
  end
  def get_module_name(module_name, :full) do
    Atom.to_string(module_name)
  end
end
