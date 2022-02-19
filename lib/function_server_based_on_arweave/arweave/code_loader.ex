defmodule FunctionServerBasedOnArweave.Arweave.CodeLoader do
  use Ecto.Schema
  import Ecto.Changeset

  schema "code_loaders" do
    field :name, :string
    field :text, :string
    field :method_name, :string
    field :output, :string

    timestamps()
  end

  @doc false
  def changeset(code_loader, attrs \\ %{}) do
    code_loader
    |> cast(attrs, [:name, :text, :output])
    # |> validate_required([:name])
  end
end
