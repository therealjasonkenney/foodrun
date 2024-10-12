defmodule Foodrun.Imports.ImportTask do
  require Logger

  use GenServer, restart: :transient

  alias Foodrun.Imports.StreamDownload
  alias Foodrun.FoodTrucks

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  # Callbacks

  @impl true
  def init(config) do
    initial_state = {config[:decoder], config[:run_at_utc_daily], config[:url]}

    # Sometimes, such as in Production
    # we might want to run this task right when we
    # boot this.
    if config[:run_at_startup] === true do
      send(self(), :work)
    else
      schedule_work(config[:run_at_utc_daily])
    end

    {:ok, initial_state}
  end

  @impl true
  def handle_info(:work, {decoder, scheduled_time, url} = state) do
    import_data!(decoder, url)

    schedule_work(scheduled_time)

    {:noreply, state}
  end

  def import_data!(decoder, url) do
    StreamDownload.get!(url)
    |> FoodTrucks.decode!(decoder)
    |> FoodTrucks.import_food_trucks()
    |> log_results(url)
  end

  defp log_results({:error, payload}, source_url) do
    Logger.error("Unable to import records from source.",
      error_payload: payload,
      source_url: source_url
    )

    :ok
  end

  defp log_results(:ok, source_url) do
    Logger.info("Records imported from source.",
      source_url: source_url
    )

    :ok
  end

  defp schedule_work(false), do: :ok

  defp schedule_work(scheduled_time) do
    {:ok, now} = DateTime.now("Etc/UTC")

    {:ok, scheduled_datetime} =
      Date.utc_today()
      |> Date.add(1)
      |> DateTime.new(scheduled_time, "Etc/UTC")

    timer_ms = DateTime.diff(scheduled_datetime, now, :millisecond)

    Process.send_after(self(), :work, timer_ms)

    :ok
  end
end
