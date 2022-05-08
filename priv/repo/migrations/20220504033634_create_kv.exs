defmodule FunctionServerBasedOnArweave.Repo.Migrations.CreateKV do
  use Ecto.Migration

  def change do
    create table(:kv) do
      add :key, :string
      add :value, :text

      timestamps()
    end

    create unique_index(:kv, [:key])
  end
end
