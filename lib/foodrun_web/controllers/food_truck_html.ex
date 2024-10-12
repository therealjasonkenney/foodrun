defmodule FoodrunWeb.FoodTruckHTML do
  @moduledoc """
  This module is a Heex Component, see the [guide](https://hexdocs.pm/phoenix/components.html) for
  documentation on `Phoenix.Component`.

  The project generator creates `FoodrunWeb` and `FoodrunWeb.CoreComponents` which empower
  this module and the views generated.
  """

  use FoodrunWeb, :html

  embed_templates "food_truck_html/*"

  @doc """
  Renders a search form that reloads the page with the results
  of a text based search based on either the company name or menu items of
  a food truck.

  See `Foodrun.FoodTrucks.search_food_trucks/1` and
  [websearch_to_tsquery/1](https://pgpedia.info/w/websearch_to_tsquery.html)
  """
  def search(assigns) do
    # TODO: Make a changeset, because that's what Phoenix would prefer.
    ~H"""
    <.form :let={f} for={%{"search_term" => @search_term}} action={~p"/"} method="get">
      <div class="relative">
        <.input field={f[:search_term]} />
        <.button class="absolute right-0 inset-y-0">
          <span class="sr-only">Search</span>
          <.icon name="hero-magnifying-glass-circle-solid" class="h-4 w-4" />
        </.button>
      </div>
    </.form>
    """
  end
end
