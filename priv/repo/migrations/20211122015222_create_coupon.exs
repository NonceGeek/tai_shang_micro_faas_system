defmodule FunctionServerBasedOnArweave.Repo.Migrations.CreateCoupon do
  use Ecto.Migration

  def change do
    create table :coupon do
      add :func_id, :string
      add :coupon_id, :string, default: false
      add :is_used, :boolean

      timestamps()

    end
    create unique_index(:coupon, [:coupon_id])
  end
end
