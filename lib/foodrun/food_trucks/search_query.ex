defmodule Foodrun.FoodTrucks.SearchQuery do
  import Ecto.Query, warn: false

  alias Foodrun.FoodTrucks.FoodTruck

  def active() do
    from(_ in FoodTruck, as: :food_trucks)
    |> where([food_trucks: f], f.active == true)
  end

  def active_and_near(%{
        maximum_truckage: limit,
        maximum_meters: distance,
        office: center
      })
      when is_integer(limit) and
             is_integer(distance) and
             is_tuple(center) do
    active()
    |> only_near(distance, center)
    |> limit(^limit)
  end

  def filter_by_search_term(query, search_term)
      when is_binary(search_term) do
    query
    |> where(
      [food_trucks: f],
      fragment("? @@ websearch_to_tsquery(?)", f.searchable, ^search_term)
    )
  end

  def sort_by_name(query) do
    query
    |> order_by([food_trucks: f], f.name)
  end

  def sort_by_search_ranking(query, search_term)
      when is_binary(search_term) do
    query
    |> order_by(
      [food_trucks: f],
      {:desc, fragment("ts_rank(?, websearch_to_tsquery(?))", f.searchable, ^search_term)}
    )
  end

  defp only_near(query, distance, {long, lat})
       when is_integer(distance) do
    # All derived from config, so its safe.

    center = "SRID=4326;POINT(#{long} #{lat})"

    where(
      query,
      [food_trucks: f],
      fragment(
        "ST_DWithin(?, ST_GeographyFromText(?), ?)",
        f.location,
        type(^center, :string),
        type(^distance, :float)
      )
    )
  end
end
