defmodule Data.MixProject do
  use Mix.Project

  def project do
    [
      app: :data,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Data.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:dev), do: ["lib", "lib_dev"]
  defp elixirc_paths(:test), do: elixirc_paths(:dev) ++ ["test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ecto_sql, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.0"},
      {:pbkdf2_elixir, "~> 1.0"},
      {:mox, "~> 0.5.1", only: :test},
      {:faker, "~> 0.13.0", only: [:dev, :test]},
      {:sequence, github: "samba6/sequence", only: [:dev, :test]},
      {:absinthe, "~> 1.4"},
      {:absinthe_relay, "~> 1.4"},
      {:dataloader, "~> 1.0"},
      {:arc, "~> 0.11.0"},
      {:arc_ecto, "~> 0.11.1"},
      {:arc_gcs, "~> 0.1.0", only: :prod},
      {:guardian, "~> 1.2"},
      {:timex, "~> 3.6"},
      {:ecto_ulid, "~> 0.2.0"},
      {:emails, in_umbrella: true}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
