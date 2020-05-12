defmodule Ipdust.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ipdust,
      version: "0.0.3",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Ipdust.Application, []},
      extra_applications: [:logger, :runtime_tools, :geolix]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.3"},
      {:phoenix_html, "~> 2.12"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:plug, "~> 1.7"},
      {:timex, "~> 3.1"},
      {:edeliver, "~> 1.6"},
      {:distillery, "~> 2.0", runtime: false, warn_missing: false},
      {:geolix, "~> 0.16"},
      {:remote_ip, "~> 0.1.0"},
      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:rdap, github: "mroach/elixir-rdap"}
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
    ]
  end
end
