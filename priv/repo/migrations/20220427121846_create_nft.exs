defmodule TaiShangMicroFaasSystem.Repo.Migrations.CreateNFT do
  use Ecto.Migration

  def change do
    create table(:nft) do
      add :token_id, :integer
      add :owner, :string
      add :uri, :text
      add :contract_id, :integer
      timestamps()
    end
  end
end
