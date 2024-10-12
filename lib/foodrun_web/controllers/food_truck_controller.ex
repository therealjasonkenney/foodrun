defmodule FoodrunWeb.FoodTruckController do
  use FoodrunWeb, :controller

  alias Foodrun.FoodTrucks

  plug FoodrunWeb.Plugs.RemoveBlankStrings, "search_term" when action in [:index]

  def index(conn, %{"search_term" => search_term}) do
    food_trucks = FoodTrucks.search_food_trucks(search_term)

    conn
    |> assign(:food_trucks, food_trucks)
    |> assign(:search_term, search_term)
    |> render(:index)
  end

  def index(conn, _params) do
    food_trucks = FoodTrucks.list_food_trucks()

    conn
    |> assign(:food_trucks, food_trucks)
    |> assign(:search_term, nil)
    |> render(:index)
  end
end
