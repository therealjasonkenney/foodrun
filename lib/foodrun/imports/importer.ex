defmodule Foodrun.Imports.Importer do
  @moduledoc false

  alias Foodrun.Imports.FoodTruck
  alias Foodrun.Repo
  alias Ecto.Multi

  @type t() :: Stream.t(Ecto.Multi.t())

  @spec commit(t()) :: {:ok, non_neg_integer()} | {:error, list({term(), term()})}
  def commit(stream) do
    %{inserts: inserts, error: errors} =
      stream
      |> Stream.map(&Repo.transaction/1)
      |> Stream.map(&handle_results/1)
      |> Enum.reduce(%{}, fn x, acc ->
        Map.merge(acc, x, &merge_results/3)
      end)

    success = Enum.empty?(errors)

    if success do
      # Blow up if THIS transaction fails b/c it never should.
      {:ok, _results} = deploy()

      {:ok, inserts}
    else
      rollback()

      # This should return errors
      {:error, errors}
    end
  end

  @doc """
  Saves a stream of food trucks within a transaction.
  """
  @spec save(FoodTruck.stream()) :: t()
  def save(stream) do
    stream
    |> Stream.chunk_every(500)
    |> Stream.map(&into_transaction/1)
  end

  defp handle_results({:ok, results}) do
    insert_count =
      Map.values(results)
      |> Enum.reduce(0, &(&1 + &2))

    %{inserts: insert_count}
  end

  defp handle_results({:error, failed_operation, failed_value, _changes_so_far}) do
    %{errors: [{failed_operation, failed_value}]}
  end

  defp merge_results(:errors, left, right), do: [right | left]
  defp merge_results(:inserts, left, right), do: left + right

  defp deploy() do
    Multi.new()
    |> Multi.delete_all(:remove_old, FoodTruck.active?())
    |> Multi.update_all(:activation, FoodTruck, set: [active: true])
    |> Repo.transaction()
  end

  defp into_transaction(changesets) do
    changesets
    |> Enum.reduce(Multi.new(), fn x, acc ->
      changeset_id = FoodTruck.changeset_id(x)

      acc
      |> Multi.insert({:food_trucks, changeset_id}, x, on_conflict: :nothing)
    end)
  end

  defp rollback() do
    FoodTruck.active?(false)
    |> Repo.delete_all()
  end
end
