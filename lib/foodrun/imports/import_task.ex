defmodule Foodrun.Imports.ImportTask do
  require Logger

  use GenServer, restart: :transient

  alias Foodrun.Imports

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  # Callbacks

  @impl true
  def init(config) do
    initial_state = {config[:decoder], config[:run_at_utc_daily], config[:url]}

    if config[:run_at_utc_daily] do
      schedule_work(config[:run_at_utc_daily])
    end

    {:ok, initial_state}
  end

  @impl true
  def handle_info(:work, {decoder, scheduled_time, url} = state) do
    Imports.import(decoder, url)

    schedule_work(scheduled_time)

    {:noreply, state}
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
