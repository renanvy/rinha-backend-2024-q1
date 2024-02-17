defmodule Rinha.Statements.StatementServer do
  use GenServer

  alias Rinha.Statements

  def add_transaction(transaction) do
    GenServer.cast(__MODULE__, {:add_transaction, transaction})
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:add_transaction, transaction}, state) do
    {:ok, transaction} = Statements.add_transaction(transaction)
    {:noreply, state}
  end
end
