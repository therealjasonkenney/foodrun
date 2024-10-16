defmodule Foodrun.FoodTrucksTest do
  use Foodrun.DataCase

  alias Foodrun.FoodTrucks
  alias Foodrun.FoodTruckSearches

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

    test "import_food_trucks!/1 imports food trucks, but does not allow duplicates." do
      external_id = System.unique_integer([:positive])

      # Make sure no side effects are mucking this db up.
      0 =
        FoodTruckSearches.list_food_trucks()
        |> length()

      :ok =
        Stream.concat([])
        |> food_truck_stream_fixture(%{external_id: external_id})
        |> food_truck_stream_fixture(%{external_id: external_id})
        |> FoodTrucks.import_food_trucks()

      count =
        FoodTruckSearches.list_food_trucks()
        |> length()

      assert count === 1
    end
  end
end
