defmodule Scheherazade.Mixfile do
  use Mix.Project

  def project do
    [app: :scheherazade,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps,
     aliases: aliases]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Scheherazade, []},
     applications: [:phoenix, :cowboy, :postgrex, :ecto, :comeonin, :logger]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 0.9.0"},
     {:cowboy, "~> 1.0"},
     {:postgrex, "0.7.0"},
     {:ecto, "~> 0.8.1"},
     {:comeonin, "~> 0.2"}]
  end

  defp aliases do
    [serve: "phoenix.server",
     up: "ecto.migrate",
     down: "ecto.rollback",
     migration: "ecto.gen.migration",
     routes: "phoenix.routes"]
  end
end
