defmodule Rinha.MixProject do
  use Mix.Project

  def project do
    [
      app: :rinha,
      version: "0.1.0",
      elixir: "~> 1.16.1",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mnesia],
      mod: {Rinha.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:libcluster, "~> 3.3"},
      {:ecto, "~> 3.11"},
      {:highlander, github: "norbajunior/highlander"},
      {:uuidv7, "~> 0.2"}
    ]
  end
end
