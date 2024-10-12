defmodule FoodrunWeb.FoodTruckControllerTest do
  use FoodrunWeb.ConnCase

  describe "index" do
    test "lists all food_trucks", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Food Trucks"
    end

    test "lists all food_trucks when search_term is blank", %{conn: conn} do
      conn = get(conn, ~p"/", search_term: "  ")
      assert html_response(conn, 200) =~ "Food Trucks"
    end

    test "searches all food_trucks when search_term is valid", %{conn: conn} do
      conn = get(conn, ~p"/", search_term: "pretzel")
      assert html_response(conn, 200) =~ "Food Trucks"
    end
  end
end
