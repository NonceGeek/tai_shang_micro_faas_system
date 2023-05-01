defmodule TaiShangMicroFaasSystem.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :role, :string, null: false, default: "user"
      add :email, :string, null: false
      add :password_hash, :string, redact: true

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
