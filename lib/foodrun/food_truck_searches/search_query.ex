defmodule Foodrun.FoodTruckSearches.SearchQuery do
  @moduledoc false

  import Ecto.Query, warn: false

  import Foodrun.Postgis

  # This should only be accessed within FoodTruckSearches.
  @doc false
  def search(:all, %{
        max_trucks_shown: limit,
        max_distance_meters: distance,
        origin: {origin_long, origin_lat}
      })
      when is_integer(limit) and
             is_float(distance) and
             is_float(origin_long) and
             is_float(origin_lat) do
    active_and_nearest(distance, origin_long, origin_lat)
    |> limit([food_trucks: f], ^limit)
  end

  def search(search_term, %{
        max_trucks_shown: limit,
        max_distance_meters: distance,
        origin: {origin_long, origin_lat}
      })
      when is_binary(search_term) and
             is_integer(limit) and
             is_float(distance) and
             is_float(origin_long) and
             is_float(origin_lat) do
    s =
      active_and_nearest(distance, origin_long, origin_lat)
      |> select_merge([food_trucks: f], %{searchable: f.searchable})
      |> filter_by_search_term(search_term)
      |> subquery()

    from(_ in s, as: :food_trucks)
    |> sort_by_search_ranking(search_term)
    |> limit([food_trucks: f], ^limit)
  end

  defp active_and_nearest(distance, origin_long, origin_lat) do
    from(f in "food_trucks",
      as: :food_trucks,
      select: %{
        name: fragment("DISTINCT ON(?) ?", f.name, f.name),
        menu: f.menu,
        schedule_url: f.schedule_url,
        address: f.address,
        distance: distance_between(f.location, geo_point(^origin_long, ^origin_lat))
      },
      where:
        f.active == true and
          distance_within(f.location, geo_point(^origin_long, ^origin_lat), ^distance),
      order_by: [asc: f.name, asc: 5]
    )
  end

  defp filter_by_search_term(query, search_term) do
    query
    |> where(
      [food_trucks: f],
      fragment("? @@ websearch_to_tsquery(?)", f.searchable, ^search_term)
    )
  end

  defp sort_by_search_ranking(query, search_term) do
    query
    |> order_by(
      [food_trucks: f],
      {:desc, fragment("ts_rank(?, websearch_to_tsquery(?))", f.searchable, ^search_term)}
    )
  end
end
