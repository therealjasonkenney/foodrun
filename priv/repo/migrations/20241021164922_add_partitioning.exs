defmodule Foodrun.Repo.Migrations.AddPartitioning do
  use Ecto.Migration

  def change do
    drop_if_exists index("food_trucks", [:external_id])

    create_if_not_exists index("food_trucks", [:external_id, :active])
  end
end
