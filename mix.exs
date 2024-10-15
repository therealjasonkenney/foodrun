defmodule Foodrun.MixProject do
  use Mix.Project

  def project do
    [
      app: :foodrun,
      version: "1.0.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [ignore_modules: no_cov()],
      aliases: aliases(),
      deps: deps(),

      # Docs
      name: "Foodrun",
      source_url: "https://github.com/therealjasonkenney/foodrun",
      homepage_url: "https://therealjasonkenney.github.io/foodrun",
      docs: [
        # The main page in the docs
        main: "Foodrun",
        output: "./docs"
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Foodrun.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    core_deps() ++
      ci_deps() ++
      [
        # Parsing CSV data - needed for SF Data Import
        {:csv, "~> 3.2"},
        # Make Web requests (For Data Import)
        {:hackney, "~> 1.9"}
      ]
  end

  # These are specifically for CI.
  defp ci_deps() do
    [
      # Audit dependencies for security vulnerabilities.
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  # These are what come with Phoenix app gen.
  defp core_deps() do
    [
      # The Framework
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},

      # Database (Postgres)
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},

      # HTML Rendering
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0-rc.1", override: true},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},

      # Web - JS/CSS
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},

      # Mailer
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},

      # Telemetry
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},

      # i18n Internationalization
      {:gettext, "~> 0.20"},

      # JSON Parser
      {:jason, "~> 1.2"},

      # Allows for deployments to have multiple nodes and for them to find each other
      # without the manual configuration you used to have to do.
      {:dns_cluster, "~> 0.1.1"},

      # Web Server
      {:bandit, "~> 1.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind foodrun", "esbuild foodrun"],
      "assets.deploy": [
        "tailwind foodrun --minify",
        "esbuild foodrun --minify",
        "phx.digest"
      ]
    ]
  end

  # Modules we don't track line coverage for testing.
  # Mostly generated boilerplate, or code with external dependencies.
  defp no_cov() do
    [
      # This is generated by Phoenix, and we don't
      # use all of its functionality.
      FoodrunWeb.CoreComponents,

      # These need to be refactored slightly with dependency injection,
      # or some form of mocking is needed to test http downloads.
      Foodrun.Imports.StreamDownload,
      Foodrun.Imports.ImportTask,

      # Only has one line of boilerplate - no idea why coverage puts it at 50%
      Foodrun.Repo
    ]
  end
end
