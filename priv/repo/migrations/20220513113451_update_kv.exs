defmodule FunctionServerBasedOnArweave.Repo.Migrations.UpdateKv do
  use Ecto.Migration

  def change do
    alter table :kv do
      add :created_by, :string
    end
  end
end
