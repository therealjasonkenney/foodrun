import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :foodrun, Foodrun.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "foodrun_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :foodrun, FoodrunWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "hGKBRSCnxK6nblb/Y9tIfMblW1EFJaoyIH7SsKPPfqHIstaoURRW0PGS31JqbUSZ",
  server: false

# In test we don't send emails
config :foodrun, Foodrun.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Configure the test suite to use specific geo information
# for test stability.
config :foodrun, Foodrun.FoodTruckSearches,
  max_distance_meters: 3000.0,
  max_trucks_shown: 1,
  origin: {-122.38453073422282, 37.755030726766726}
