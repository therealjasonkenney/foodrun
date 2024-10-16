defmodule Foodrun.FoodTruckSearchesTest do
  use Foodrun.DataCase

  alias Foodrun.FoodTruckSearches

  describe "food_trucks" do
    import Foodrun.FoodTrucksFixtures

    test "list_food_trucks/0 returns food_trucks within configured meters" do
      food_truck_fixture()

      expected = %{
        address: "Some Address",
        menu: "Hot dogs: condiments: soft pretzels.",
        name: "Some Name",
        schedule_url: "https://www.example.com/foo.pdf",
        distance: 0.0
      }

      assert FoodTruckSearches.list_food_trucks() == [expected]
    end

    test "list_food_trucks/0 will not return out of range trucks." do
      food_truck_fixture(%{lat: 0})
      assert FoodTruckSearches.list_food_trucks() == []
    end

    # Because this relies on an index, we can't test this properly with sandbox for when
    # matching results appear, So we only have one for when none appear.
    test "search_food_trucks/1 does not return food trucks when none have burgers" do
      assert FoodTruckSearches.search_food_trucks("ketchup burgers") == []
    end
  end
end
