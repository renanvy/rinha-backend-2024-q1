defmodule Rinha.Transactions do
  alias Rinha.Customers
  alias Rinha.Transactions.Transaction

  def create_transaction(attrs) do
    :mnesia.transaction(fn ->
      transaction = Transaction.new(attrs)

      :mnesia.write(
        {:transaction, transaction.id, transaction.customer_id, transaction.amount,
         transaction.inserted_at, transaction.type, transaction.description}
      )

      :mnesia.write(
        {:customer, attrs[:customer_id], attrs[:customer][:limit], attrs[:customer][:balance]}
      )

      :ok = StatementServer.add_transaction(transaction)
    end)
  end
end
