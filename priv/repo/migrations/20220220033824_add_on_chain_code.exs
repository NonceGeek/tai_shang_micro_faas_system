defmodule FunctionServerBasedOnArweave.Repo.Migrations.AddOnChainCode do
  use Ecto.Migration

  def change do
    create table :on_chain_code do
      add :name, :string
      add :description, :string
      add :tx_id, :string
      add :code, :text
      timestamps()
    end
  end
end
