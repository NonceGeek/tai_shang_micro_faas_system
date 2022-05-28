defmodule Components.ModuleHandler do
  def get_module_name(module_name) do
    module_name
    |> get_module_name(:full)
    |> String.split(".")
    |> Enum.fetch!(-1)
  end
  def get_module_name(module_name, :full) do
    Atom.to_string(module_name)
  end
end
