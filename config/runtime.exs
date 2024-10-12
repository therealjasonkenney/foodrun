import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/foodrun start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
start_endpoint = System.get_env("PHX_SERVER")

if start_endpoint do
  config :foodrun, FoodrunWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :foodrun, Foodrun.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  # DNS Clustering, allows nodes to talk to each other.
  config :foodrun, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  # No point in configuring the endpoint if we are not starting it.
  if start_endpoint do
    # The secret key base is used to sign/encrypt cookies and other secrets.
    # A default value is used in config/dev.exs and config/test.exs but you
    # want to use a different value for prod and you most likely don't want
    # to check this value into version control, so we use an environment
    # variable instead.
    secret_key_base =
      System.get_env("SECRET_KEY_BASE") ||
        raise """
        environment variable SECRET_KEY_BASE is missing.
        You can generate one by calling: mix phx.gen.secret
        """

    config :foodrun, FoodrunWeb.Endpoint, secret_key_base: secret_key_base

    # This configures the external url which is then used for links and redirects
    # within the app.
    config :foodrun, FoodrunWeb.Endpoint,
      url: [
        host: System.get_env("PHX_HOST") || "localhost",
        port: 443,
        scheme: "https"
      ]

    # This configuration assumes the endpoint is running behind a proxy like caddy or nginx.
    # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
    # for details about using IPv6 vs IPv4 and loopback vs public addresses.
    config :foodrun, FoodrunWeb.Endpoint, http: [ip: :any]

    # Geosearch configuration -- only makes sense when endpoint is started.

    # Might be a security issue if we don't enforce setting these
    # externally.
    office_long =
      System.get_env("OFFICE_LONG") ||
        raise """
            environment variable OFFICE LONG is missing.
            This is needed when determining the origin point for
            distance limiting the food trucks returned.
        """

    office_lat =
      System.get_env("OFFICE_LAT") ||
        raise """
            environment variable OFFICE LAT is missing.
            This is needed when determining the origin point for
            distance limiting the food trucks returned.
        """

    # Further work could add an office address lookup feature and then pass the coordinates
    # into the query, but for now -- lets just have it here.
    config :foodrun, Foodrun.FoodTrucks,
      maximum_meters: System.get_env("MAX_METERS", "3000") |> String.to_integer(),
      maximum_truckage: System.get_env("MAX_TRUCKAGE", "20") |> String.to_integer(),
      office: {office_long, office_lat}
  end
end
