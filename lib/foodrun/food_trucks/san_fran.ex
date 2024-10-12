defmodule Foodrun.FoodTrucks.SanFran do
  alias Foodrun.FoodTrucks.FoodTruck

  require Logger

  @moduledoc """
  Handles the decoding and configuration for running an import for
  the food truck data provided by San Fransisco.

  Currently this only supports THIS CSV, but I organized the code this
  way so changes, especially since we don't control the csv can be easily
  maintained.
  """

  @doc """
  Decodes a `Stream` of data that assumes its a `CSV` into an `Ecto.Changset` for `Foodrun.FoodTrucks.FoodTruck`.
  """
  @spec decode!(Enumerable.t(String.t())) :: Enumerable.t(Ecto.Changeset.t())
  def decode!(stream) do
    stream
    |> CSV.decode(seperator: ?,, headers: true)
    |> Stream.filter(&active?/1)
    |> Stream.map(&into_changeset/1)
  end

  def source_url(), do: "https://data.sfgov.org/api/views/rqzj-sfat/rows.csv"

  defp active?({:ok, %{"Status" => "APPROVED"}}), do: true
  defp active?({:ok, _row}), do: false

  defp into_changeset(
         {:ok,
          %{
            "Address" => address,
            "Applicant" => name,
            "FoodItems" => food,
            "Latitude" => lat,
            "locationid" => id,
            "Longitude" => long,
            "Schedule" => url
          }}
       ) do
    FoodTruck.new_changeset(%{
      address: address,
      menu: food,
      external_id: id,
      lat: lat,
      long: long,
      name: name,
      schedule_url: url
    })
  end
end
