defmodule Foodrun.FoodTruckSearches.Config do
  defstruct max_distance_meters: 0.0,
            max_trucks_shown: 0,
            origin: {0.0, 0.0}

  @type t() :: %__MODULE__{
          max_distance_meters: float(),
          max_trucks_shown: integer(),
          origin: {float(), float()}
        }

  def load() do
    config = Application.get_env(:foodrun, Foodrun.FoodTruckSearches)

    max_distance_meters = config[:max_distance_meters]
    max_trucks_shown = config[:max_trucks_shown]
    origin = config[:origin]

    :ok = validate!(max_distance_meters, max_trucks_shown, origin)

    %__MODULE__{
      max_distance_meters: config[:max_distance_meters],
      max_trucks_shown: config[:max_trucks_shown],
      origin: config[:origin]
    }
  end

  defp validate!(max_distance_meters, max_trucks_shown, {origin_long, origin_lat})
       when is_float(max_distance_meters) and
              is_integer(max_trucks_shown) and
              is_float(origin_long) and
              is_float(origin_lat) do
    :ok
  end
end
