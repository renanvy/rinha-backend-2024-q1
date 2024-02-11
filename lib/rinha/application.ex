defmodule Rinha.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      epmd: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: [:rinha@api01, :rinha@api02]]
      ]
    ]

    Database.start()

    children = [
      {Cluster.Supervisor, [topologies, [name: Rinha.ClusterSupervisor]]},
      {Bandit, plug: Rinha.Router, scheme: :http, port: port()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp port do
    Application.get_env(:rinha, :port, 4000)
  end
end
