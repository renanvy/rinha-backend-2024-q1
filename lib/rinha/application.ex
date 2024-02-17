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
        config: [hosts: nodes()]
      ]
    ]

    # Rinha.Database.start()

    children = [
      {Phoenix.PubSub, name: Rinha.PubSub},
      {Highlander, Rinha.StatementConsumer},
      {Cluster.Supervisor, [topologies, [name: Rinha.ClusterSupervisor]]},
      {Bandit, plug: RinhaWeb.Router, scheme: :http, port: port()},
      Rinha.Transactions.TransactionServer,
      Rinha.Statements.StatementServer
      # {Highlander, Rinha.NodeMonitor}
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
