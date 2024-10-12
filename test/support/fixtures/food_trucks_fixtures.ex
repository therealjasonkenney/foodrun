defmodule Foodrun.FoodTrucksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Foodrun.FoodTrucks` context.
  """

  @doc """
  Generate a food_truck.
  """
  def food_truck_fixture(attrs \\ %{}) do
    {:ok, food_truck} =
      attrs
      |> Enum.into(%{
        active: true,
        address: "Some Address",
        external_id: System.unique_integer([:positive]),
        lat: "37.755030726766726",
        long: "-122.38453073422282",
        name: "Some Name",
        menu: "Hot dogs: condiments: soft pretzels.",
        schedule_url: "https://www.example.com/foo.pdf"
      })
      |> Foodrun.FoodTrucks.create_food_truck()

    food_truck
  end

  def food_truck_stream_fixture(stream, attrs \\ %{}) do
    food_truck =
      attrs
      |> Enum.into(%{
        address: "Some Address",
        external_id: System.unique_integer([:positive]),
        lat: "37.755030726766726",
        long: "-122.38453073422282",
        name: "Some Name",
        menu: "Hot dogs: condiments: soft pretzels.",
        schedule_url: "https://www.example.com/foo.pdf"
      })
      |> Foodrun.FoodTrucks.FoodTruck.new_changeset()

    stream
    |> Stream.concat([food_truck])
  end
end
