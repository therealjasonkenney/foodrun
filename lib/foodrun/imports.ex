defmodule Foodrun.Imports do
  @moduledoc """

  ## Configuration
  It is recommended to set a config for each importer, like this:

  ```
  config :foodrun, :san_fran_import,
    # Use the decoder for San Francisco data.
    decoder: :san_fran,
    # Set this to true if you want this to import once Phoenix loads.
    run_at_startup: false,
    # Set a UTC time for this task to run every day, false to disable.
    run_at_utc_daily: false,
    # Set the downloader for the import.
    url: "https://data.sfgov.org/api/views/rqzj-sfat/rows.csv"
  ```

  Then in `lib/foodrun/application.ex` you add this to the gen server list:

  ```
  def start(_type, _args) do
    children = [
      # Obviously there are other servers in here...
      {Foodrun.Imports.ImportTask, Application.get_env(:foodrun, :san_fran_import)},
    ]

    opts = [strategy: :one_for_one, name: Foodrun.Supervisor]
    Supervisor.start_link(children, opts)
  end
  ```

  ## Testing

  For testing `StreamDownload` you need to turn on the
  `MockServer`.

  ```
    {:ok, pid} = Imports.start_mock_server(4009)

    {status, insert_count} = Imports.import(:san_fran, "http://localhost:4009/test.csv")

    Imports.stop_mock_server(pid)
  ```

  """

  alias __MODULE__.Importer
  alias __MODULE__.SanFran
  alias __MODULE__.StreamDownload

  @doc """
  Imports a csv using a transformer and url.
  """
  @spec import(atom(), String.t()) :: {:ok, non_neg_integer()}
  def import(:san_fran, url) do
    {:ok, insert_count} =
      StreamDownload.get!(url)
      |> SanFran.decode!()
      |> Importer.save()
      |> Importer.commit()

    {:ok, insert_count}
  end

  @doc """
  Starts the mock server on the given port
  """
  @spec start_mock_server(non_neg_integer()) :: {:ok, non_neg_integer()}
  def start_mock_server(port)
      when is_number(port) do
    Bandit.start_link(
      plug: __MODULE__.MockServer,
      scheme: :http,
      port: port
    )
  end

  @doc """
  Stops the mock server given it's supervisor pid.
  """
  @spec stop_mock_server(non_neg_integer()) :: :ok
  def stop_mock_server(pid) do
    Supervisor.stop(pid, :normal, 5)
  end
end
