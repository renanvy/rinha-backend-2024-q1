defmodule Rinha.Transactions.TransactionServer do
  use GenServer

  def start_link(customer_id) do
    GenServer.start_link(__MODULE__, customer_id, name: name(customer_id))
  end

  def init(customer_id) do
    :ok = Phoenix.PubSub.subscribe(Rinha.PubSub, "customer_transactions:#{customer_id}")

    {:ok, nil}
  end

  def handle_info({:create_transaction, params}, state) do
    {:atomic, _transaction} = Rinha.Transactions.create_transaction(params)
    {:noreply, state}
  end

  def child_spec(customer_id) do
    %{
      id: :"transaction_server_#{customer_id}",
      start: {__MODULE__, :start_link, [customer_id]}
    }
  end

  defp name(customer_id) do
    {:via, Registry, {Rinha.Registry, "customer_transactions_#{customer_id}"}}
  end
end
