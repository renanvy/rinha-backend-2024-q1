defmodule Rinha.Transactions do
  alias Rinha.Statements
  alias Rinha.Transactions.Transaction

  def get_transactions(nil), do: {:error, :customer_not_found}

  def get_transactions(customer_id) do
    # :mnesia.transaction(fn ->

    with [{:customer, id, name, limit, balance}] <- :mnesia.dirty_read({:customer, customer_id}) do
      customer = Customer.new(%{id: id, name: name, limit: limit, balance: balance})
      # transactions =
      #   :mnesia.match_object({:transaction, :_, customer_id, :_, :_, :_, :_})
      #   |> Enum.map(fn {_, id, customer_id, amount, inserted_at, type, description} ->
      #     %Transaction{
      #       id: id,
      #       customer_id: customer_id,
      #       amount: amount,
      #       inserted_at: inserted_at,
      #       type: type,
      #       description: description
      #     }
      #   end)
      #   |> Enum.take(10)
      #   |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})

      result = %{
        customer: customer,
        transactions: []
      }

      {:ok, result}
    end

    # end)
    # |> handle_transaction_result()
  end

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

      :ok = Statements.StatementServer.add_transaction(transaction)
    end)
  end
end
