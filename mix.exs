defmodule PestServer.Mixfile do
  use Mix.Project

  def project do
    [app: :pest_server,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {PestServer, []},
     applications: [:phoenix, :cowboy, :logger, :gettext,
                    :kafka_ex, :uuid, :gproc, :oauth2,
                    :httpoison]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2"},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:kafka_ex, "~> 0.5.0"},
     {:uuid, "~> 1.1"},
     {:gproc, "~> 0.5.0"},
     {:oauth2, "~> 0.6"},
     {:httpoison, "~> 0.9.0"}]
  end
end
