defmodule Rinha.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Rinha.{Transactions.TransactionServer, Statements.StatementServer}

  @impl true
  def start(_type, _args) do
    topologies = [
      gossip: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: Rinha.ClusterSupervisor]]},
      {Bandit, plug: RinhaWeb.Router, scheme: :http, port: System.get_env("PORT")},
      {Phoenix.PubSub, name: Rinha.PubSub},
      {Registry, keys: :unique, name: Rinha.Registry},
      {TransactionServer, 1},
      {TransactionServer, 2},
      {TransactionServer, 3},
      {TransactionServer, 4},
      {TransactionServer, 5},
      {StatementServer, 1},
      {StatementServer, 2},
      {StatementServer, 3},
      {StatementServer, 4},
      {StatementServer, 5},
      {Highlander, Rinha.NodeMonitor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
