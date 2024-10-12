defmodule Foodrun.FoodTrucks.FoodTruck do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  schema "food_trucks" do
    field :external_id, :integer
    field :active, :boolean, default: false
    field :name, :string
    field :lat, :float
    field :long, :float
    # These can be blank
    field :address, :string
    field :menu, :string
    field :schedule_url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def new_changeset(attrs) do
    %FoodTruck{}
    |> cast(attrs, [:address, :external_id, :lat, :long, :name, :menu, :schedule_url])
    |> put_change(:active, true)
    |> validate_required([:lat, :long, :name])
  end
end
