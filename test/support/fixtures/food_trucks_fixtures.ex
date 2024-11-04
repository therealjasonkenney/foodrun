defmodule Foodrun.FoodTrucksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Foodrun.Imports` context.
  """

  alias Foodrun.Imports.FoodTruck
  alias Foodrun.Repo

  @doc """
  Generate a food_truck.
  """
  def food_truck_fixture(merge_attrs \\ %{}) do
    attrs =
      merge_attrs
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

    {:ok, food_truck} =
      Ecto.Changeset.cast(%FoodTruck{}, attrs, FoodTruck.__schema__(:fields))
      |> Repo.insert()

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
      |> FoodTruck.new_changeset()

    stream
    |> Stream.concat([food_truck])
  end
end
