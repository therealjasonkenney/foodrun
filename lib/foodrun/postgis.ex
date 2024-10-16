defmodule Foodrun.Postgis do
  @moduledoc """
  ## Ecto macros for postgis functions we use.
  """

  @typedoc "An point consisting of longitude,latitude."
  @type geo_point() :: {float(), float()}

  @doc """
  Calculates the distance in meters between the column in the table and a long,lat point
  given.
  """
  defmacro distance_between(geo_one, geo_two) do
    quote do: fragment("ST_Distance(?, ?, false)", unquote(geo_one), unquote(geo_two))
  end

  defmacro geo_point(long, lat) do
    quote do:
            fragment(
              "ST_POINT(?, ?, 4326)::geography",
              type(unquote(long), :float),
              type(unquote(lat), :float)
            )
  end

  defmacro distance_within(geo_one, geo_two, distance) do
    quote do:
            fragment(
              "ST_DWithin(?, ?, ?, false)",
              unquote(geo_one),
              unquote(geo_two),
              type(unquote(distance), :float)
            )
  end
end
