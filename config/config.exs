# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :foodrun,
  ecto_repos: [Foodrun.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :foodrun, FoodrunWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: FoodrunWeb.ErrorHTML, json: FoodrunWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Foodrun.PubSub,
  live_view: [signing_salt: "RwZBKf5n"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :foodrun, Foodrun.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  foodrun: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  foodrun: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :foodrun, :san_fran_import,
  # Use the decoder for San Francisco data.
  decoder: :san_fran,
  # run_at_startup as well.
  run_at_startup: false,
  # Do not schedule the task to run.
  run_at_utc_daily: false,
  # Download from this URL
  url: "https://data.sfgov.org/api/views/rqzj-sfat/rows.csv"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
