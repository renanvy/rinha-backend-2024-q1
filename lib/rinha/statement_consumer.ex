defmodule Rinha.StatementConsumer do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(state) do
    Phoenix.PubSub.subscribe(Rinha.PubSub, "new_transaction")
    {:ok, state}
  end

  def handle_info(transaction, state) do
    Rinha.Statements.update_statement(transaction)
    {:noreply, state}
  end
end
