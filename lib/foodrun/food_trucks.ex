defmodule Foodrun.FoodTrucks do
  @moduledoc """
  The FoodTrucks context.
  """

  import Ecto.Query, warn: false

  require Logger

  alias Foodrun.Repo

  alias Foodrun.FoodTrucks.FoodTruck

  @doc false
  # This is just used for fixtures in the test() environment.
  def create_food_truck(attrs) do
    FoodTruck.new_changeset(attrs)
    |> Repo.insert()
  end

  def decode!(stream, :san_fran) do
    Foodrun.FoodTrucks.SanFran.decode!(stream)
  end

  @doc """
  Imports food trucks from a `Stream` within a transaction.

  ## Examples

    iex> import_food_trucks!(stream)
    :ok

  """
  @spec import_food_trucks(Enumerable.t(map())) :: :ok | {:error, term(), Ecto.ChangeSet.t()}
  def import_food_trucks(stream) do
    {:ok, :ok} =
      Repo.transaction(fn ->
        deactivate_all()

        # May want to look into catching the error or doing something downstream
        # if we want to have slightly better error handling.
        stream
        |> Stream.each(&import_food_truck!/1)
        |> Stream.run()
      end)

    Logger.debug("Transaction comitted")
    :ok
  end

  defp deactivate_all() do
    from(f in FoodTruck, where: f.active == true)
    |> Repo.update_all(set: [active: false])
  end

  defp import_food_truck!(changeset) do
    changeset
    |> Repo.insert!(
      on_conflict: {:replace, [:active, :menu, :lat, :long, :name, :schedule_url]},
      conflict_target: :external_id
    )
  end
end
