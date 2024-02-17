defmodule Rinha.Transactions.TransactionServer do
  use GenServer

  def create_transaction(params) do
    GenServer.cast(__MODULE__, {:create_transaction, params})
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, opts}
  end

  def handle_cast({:create_transaction, params}, state) do
    {:atomic, _transaction} = Rinha.Transactions.create_transaction(params)
    {:noreply, state}
  end
end
