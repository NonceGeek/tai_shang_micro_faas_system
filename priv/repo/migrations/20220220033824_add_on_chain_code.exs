defmodule FunctionServerBasedOnArweave.Repo.Migrations.AddOnChainCode do
  use Ecto.Migration

  def change do
    create table :on_chain_code do
      add :name, :string
      add :description, :string
      add :tx_id, :string

      timestamps()
    end
  end
end
