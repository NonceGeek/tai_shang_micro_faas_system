defmodule FunctionServerBasedOnArweave.Repo.Migrations.CreateContract do
  use Ecto.Migration

  def change do
    create table :contract do
      add :addr, :string
      add :abi, {:array, :map}
      add :chain_info, :map # including endpoint & api_explorer
      add :last_block, :integer, default: 0
      timestamps()
    end

    create unique_index(:contract, [:addr])
  end
end
