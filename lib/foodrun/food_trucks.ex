defmodule Foodrun.FoodTrucks do
  @moduledoc """
  The FoodTrucks context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias Foodrun.Repo

  alias Foodrun.FoodTrucks.FoodTruck
  alias Foodrun.FoodTrucks.SearchQuery

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
  Returns the list of food_trucks.

  ## Examples

      iex> list_food_trucks()
      [%FoodTruck{}, ...]

  """
  def list_food_trucks do
    SearchQuery.active_and_near(config())
    |> SearchQuery.sort_by_name()
    |> Repo.all()
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

  @doc """
  Searches food trucks and orders them by rank.
  """
  def search_food_trucks(search_term) do
    SearchQuery.active_and_near(config())
    |> SearchQuery.filter_by_search_term(search_term)
    |> SearchQuery.sort_by_search_ranking(search_term)
    |> Repo.all()
  end

  defp config() do
    config = Application.get_env(:foodrun, __MODULE__)

    %{
      maximum_meters: config[:maximum_meters],
      maximum_truckage: config[:maximum_truckage],
      office: config[:office]
    }
  end

  defp deactivate_all() do
    SearchQuery.active()
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
