defmodule FunctionServerBasedOnArweave.Repo.Migrations.CreateNFT do
  use Ecto.Migration

  def change do
    create table(:nft) do
      add :token_id, :integer
      add :owner, :string
      add :uri, :text

      timestamps()
    end

    create unique_index(:nft, [:token_id])
  end
end
