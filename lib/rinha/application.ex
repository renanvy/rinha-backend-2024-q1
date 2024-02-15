defmodule Rinha.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      epmd: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: Rinha.ClusterSupervisor]]},
      {Bandit, plug: RinhaWeb.Router, scheme: :http, port: System.get_env("PORT", "4000")},
      {Highlander, Rinha.NodeMonitor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
