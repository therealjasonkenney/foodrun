defmodule Foodrun.Repo do
  use Ecto.Repo,
    otp_app: :foodrun,
    adapter: Ecto.Adapters.Postgres
end
