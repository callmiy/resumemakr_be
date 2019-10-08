defmodule Emails.MixProject do
  use Mix.Project

  def project do
    [
      app: :emails,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:phoenix] ++ Mix.compilers()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:swoosh, "~> 0.23.4"},
      {:gen_smtp, "~> 0.15.0"},
      {:mox, "~> 0.5.1", only: :test},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_html, "~> 2.13"}
    ]
  end
end
