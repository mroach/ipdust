defmodule Ipdust.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ipdust,
      version: version(),
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      build_path: build_path(Mix.env())
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
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.3"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:plug, "~> 1.7"},
      {:timex, "~> 3.6"},
      {:geolix, "~> 2.0"},
      {:remote_ip, "~> 0.2"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
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
    []
  end

  defp version do
    case File.read("VERSION") do
      {:ok, str} -> String.trim(str)
      _ -> "0.0.1"
    end
  end

  # When you use the MIX_BUILD_PATH environment variable it overrides all
  # other configuration and disables building per environment.
  # This causes problems with some applications that have different compile-time
  # behaviour per environment. For example, mix_text_watch was totally broken.
  defp build_path(env) do
    root = System.get_env("MIX_BUILD_PATH_ROOT") || "_build"
    Path.join(root, to_string(env))
  end
end
