defmodule Foodrun.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FoodrunWeb.Telemetry,
      Foodrun.Repo,
      {DNSCluster, query: Application.get_env(:foodrun, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Foodrun.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Foodrun.Finch},
      # Start a daily task to import San Francisco's public food truck data.
      {Foodrun.Imports.ImportTask, Application.get_env(:foodrun, :san_fran_import)},
      # Start to serve requests, typically the last entry
      FoodrunWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Foodrun.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FoodrunWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
