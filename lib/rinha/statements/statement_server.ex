defmodule Rinha.Statements.StatementServer do
  use GenServer

  alias Rinha.Statements

  def start_link(customer_id) do
    GenServer.start_link(__MODULE__, customer_id, name: name(customer_id))
  end

  def init(customer_id) do
    :ok = Phoenix.PubSub.subscribe(Rinha.PubSub, "customer_statement:#{customer_id}")

    {:ok, nil}
  end

  def handle_info({:add_transaction, transaction}, state) do
    {:atomic, _transaction} = Statements.add_transaction(transaction)
    {:noreply, state}
  end

  def child_spec(customer_id) do
    %{
      id: :"statement_server_#{customer_id}",
      start: {__MODULE__, :start_link, [customer_id]}
    }
  end

  defp name(customer_id) do
    {:via, Registry, {Rinha.Registry, "customer_statement_#{customer_id}"}}
  end
end
