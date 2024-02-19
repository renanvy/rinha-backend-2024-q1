defmodule Rinha.Transactions do
  alias Rinha.{Customers, Transactions.Transaction}

  def new_transaction(attrs) do
    %Transaction{
      id: UUIDv7.generate(),
      amount: attrs.amount,
      customer_id: attrs.customer_id,
      customer: attrs.customer,
      type: attrs.type,
      description: attrs.description,
      inserted_at: DateTime.utc_now()
    }
  end

  def create_transaction(t = %Transaction{}) do
    :mnesia.transaction(fn ->
      :mnesia.write(
        {:"transaction_#{t.customer_id}", t.id, t.amount, t.inserted_at, t.type, t.description}
      )

      Rinha.Statements.add_transaction(t)

      Customers.update_balance(t.customer)
    end)
  end

  def change_transaction(attrs) do
    Transaction.changeset(attrs)
  end
end
