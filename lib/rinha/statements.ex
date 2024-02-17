defmodule Rinha.Statements do
  def add_transaction(transaction) do
    :mnesia.transaction(fn ->
      [{_, _, _, _, last_transactions}] =
        :mnesia.read({:statement, transaction.customer_id})

      if Enum.count(last_transactions) + 1 < 11 do
        last_transactions = [transaction | last_transactions]

        :mnesia.write(
          {:statement, transaction.customer_id, transaction.customer.limit,
           transaction.customer.balance, last_transactions}
        )
      else
        last_transactions = List.delete_at(last_transactions, -1)
        last_transactions = [transaction | last_transactions]

        :mnesia.write(
          {:statement, transaction.customer_id, transaction.customer.limit,
           transaction.customer.balance, last_transactions}
        )
      end
    end)
  end

  def get_statement(customer_id) do
    :mnesia.transaction(fn ->
      [{_, _, limit, balance, last_transactions}] = :mnesia.read({:statement, customer_id})

      statement = %{
        balance: balance,
        limit: limit,
        last_transactions: last_transactions
      }

      {:ok, statement}
    end)
    |> handle_result()
  end

  defp handle_result(result) do
    case result do
      {:atomic, result} ->
        result

      {:aborted, error} ->
        error
    end
  end
end
