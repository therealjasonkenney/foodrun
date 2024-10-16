defmodule Foodrun.FoodTruckSearches do
  @moduledoc """
  The FoodTrucks context.
  """

  alias Foodrun.Repo

  alias __MODULE__.Config
  alias __MODULE__.FoodTruck
  alias __MODULE__.SearchQuery

  @doc """
  Returns the list of food_trucks.

  ## Examples

      iex> list_food_trucks()
      [%FoodTruck{}, ...]

  """
  @spec list_food_trucks() :: list(FoodTruck.t())
  def list_food_trucks do
    SearchQuery.search(:all, Config.load())
    |> Repo.all()
  end

  @doc """
  Searches food trucks and orders them by rank.
  """
  @spec search_food_trucks(String.t()) :: list(FoodTruck.t())
  def search_food_trucks(search_term) do
    SearchQuery.search(search_term, Config.load())
    |> Repo.all()
  end
end
