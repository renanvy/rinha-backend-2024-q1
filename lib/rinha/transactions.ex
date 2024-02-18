defmodule Rinha.Transactions do
  alias Rinha.Transactions.Transaction
  alias Phoenix.PubSub

  def create_transaction(attrs) do
    :mnesia.transaction(fn ->
      transaction = Transaction.new(attrs)

      :mnesia.write(
        {:transaction, transaction.id, transaction.customer_id, transaction.amount,
         transaction.inserted_at, transaction.type, transaction.description}
      )

      :mnesia.write(
        {:customer, transaction.customer_id, transaction.customer.limit,
         transaction.customer.balance}
      )

      {:atomic, _transaction} = Statements.add_transaction(transaction)

      :ok =
        PubSub.local_broadcast(
          Rinha.PubSub,
          "customer_statement:#{transaction.customer_id}",
          {:add_transaction, transaction}
        )
    end)
  end
end
