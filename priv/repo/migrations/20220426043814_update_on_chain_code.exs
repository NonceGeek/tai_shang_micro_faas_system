defmodule FunctionServerBasedOnArweave.Repo.Migrations.UpdateOnChainCode do
  use Ecto.Migration

  def change do
    alter table :on_chain_code do
      add :type, :string, default: "ar"
    end
  end
end
