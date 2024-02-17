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
        config: [nodes: nodes()]
      ]
    ]

    Rinha.Database.start()
    Rinha.Seeds.start()

    children = [
      {Cluster.Supervisor, [topologies, [name: Rinha.ClusterSupervisor]]},
      {Bandit, plug: RinhaWeb.Router, scheme: :http, port: port()},
      {Highlander, Rinha.NodeMonitor},
      Rinha.Transactions.TransactionServer,
      Rinha.Statements.StatementServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp port do
    Application.get_env(:rinha, :port, 4000)
  end

  defp nodes do
    Application.get_env(:rinha, :nodes, [])
  end
end
