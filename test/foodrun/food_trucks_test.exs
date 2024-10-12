defmodule Foodrun.FoodTrucksTest do
  use Foodrun.DataCase

  alias Foodrun.FoodTrucks

  describe "food_trucks" do
    import Foodrun.FoodTrucksFixtures
    import Foodrun.SanFranFixtures

    test "decode!/2 decodes a csv into a FoodTruck changeset" do
      expected_changeset =
        FoodTrucks.FoodTruck.new_changeset(%{
          address: "Assessors Block /Lot",
          external_id: "1514024",
          name: "F & C Catering",
          menu:
            "Cold Truck: Hot/Cold Sandwiches: Water: Soda: Juice: Snacks: Milk: Candies: Canned Food: Soups: Cup of Noodles: Fruit: Salad",
          schedule_url:
            "http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=21MFF-00035&ExportPDF=1&Filename=21MFF-00035_schedule.pdf",
          lat: "0",
          long: "0"
        })

      received_changeset =
        san_fran_stream_fixture()
        |> FoodTrucks.decode!(:san_fran)
        |> Enum.at(0)

      assert received_changeset == expected_changeset
    end

    test "list_food_trucks/0 returns food_trucks within configured meters" do
      food_truck = food_truck_fixture()
      assert FoodTrucks.list_food_trucks() == [food_truck]
    end

    test "list_food_trucks/0 will not return out of range trucks." do
      food_truck_fixture(%{lat: 0})
      assert FoodTrucks.list_food_trucks() == []
    end

    # Because this relies on an index, we can't test this properly with sandbox for when
    # matching results appear, So we only have one for when none appear.
    test "search_food_trucks/1 does not return food trucks when none have burgers" do
      assert FoodTrucks.search_food_trucks("ketchup burgers") == []
    end

    test "import_food_trucks!/1 imports food trucks, but does not allow duplicates." do
      external_id = System.unique_integer([:positive])

      # Make sure no side effects are mucking this db up.
      0 =
        FoodTrucks.list_food_trucks()
        |> length()

      :ok =
        Stream.concat([])
        |> food_truck_stream_fixture(%{external_id: external_id})
        |> food_truck_stream_fixture(%{external_id: external_id})
        |> FoodTrucks.import_food_trucks()

      count =
        FoodTrucks.list_food_trucks()
        |> length()

      assert count === 1
    end
  end
end
