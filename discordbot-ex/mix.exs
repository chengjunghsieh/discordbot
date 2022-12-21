defmodule Exbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :exbot,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Exbot, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.5.1"},
      {:tesla, "~> 1.4"},
      # optional, but recommended adapter
      {:hackney, "~> 1.17"},
      # optional, required by JSON middleware
      {:jason, ">= 1.0.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
