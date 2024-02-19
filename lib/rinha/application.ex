defmodule Rinha.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Rinha.{
    Customers.BalanceServer,
    Transactions.TransactionServer
  }

  @impl true
  def start(_type, _args) do
    topologies = [
      gossip: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    children =
      [
        {Cluster.Supervisor, [topologies, [name: Rinha.ClusterSupervisor]]},
        {Bandit, plug: RinhaWeb.Router, scheme: :http, port: System.get_env("PORT")},
        {Phoenix.PubSub, name: Rinha.PubSub},
        {Registry, keys: :unique, name: Rinha.Registry},
        {Highlander, Rinha.NodeMonitor},
        {TransactionServer, 1},
        {TransactionServer, 2},
        {TransactionServer, 3},
        {TransactionServer, 4},
        {TransactionServer, 5}
      ] ++ balance_servers()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp balance_servers do
    if node() == :api01@localhost do
      [
        {BalanceServer, 1},
        {BalanceServer, 2},
        {BalanceServer, 3},
        {BalanceServer, 4},
        {BalanceServer, 5}
      ]
    else
      []
    end
  end
end
