defmodule Ipdust.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ipdust,
      version: version(),
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

  def version do
    version_from_file()
    |> handle_file_version()
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.4"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.12"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:timex, "~> 3.1"},
      {:edeliver, "~> 1.6"},
      {:distillery, "~> 2.0", runtime: false, warn_missing: false},
      {:geolix, "~> 0.16"},
      {:remote_ip, "~> 0.1.0"},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
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

  defp version_from_file, do: File.read("VERSION")

  defp handle_file_version({:ok, content}) do
    content
    |> String.trim
  end
  defp handle_file_version({:error, _}), do: semver_from_git()

  # Creates a version string that uses the git revision but is still parsable by Version.parse/1
  # Valid semver example: 0.0.0+7d68c8f-dirty
  defp semver_from_git do
    "0.0.0+" <> git_revision()
  end

  # Get current git revision. If dirty, gets appended with "-dirty"
  defp git_revision do
    System.cmd("git", ~w{describe --dirty --always --tags --first-parent})
    |> elem(0)
    |> String.trim
  end
end
