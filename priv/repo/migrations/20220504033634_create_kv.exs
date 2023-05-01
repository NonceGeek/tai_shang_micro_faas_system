defmodule TaiShangMicroFaasSystem.Repo.Migrations.CreateKV do
  use Ecto.Migration

  def change do
    create table(:kv) do
      add :key, :string
      add :value, :text
      add :created_by, :string

      timestamps()
    end

    create unique_index(:kv, [:key, :created_by], name: :key_and_created_by)
  end
end
