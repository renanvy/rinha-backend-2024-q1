defmodule Rinha.Transactions do
  alias Rinha.Customers
  alias Rinha.Transactions.Transaction

  def create_transaction(attrs) do
    :mnesia.transaction(fn ->
      with {:ok, customer} <- Customers.get_customer(attrs[:customer_id]),
           {:ok, transaction} <- do_create_transaction(attrs),
           {:ok, customer} <- Customers.update_balance(customer, transaction) do
        {:ok, %{transaction | customer: customer}}
      end
    end)
    |> handle_transaction_result()
  end

  defp do_create_transaction(attrs) do
    case Transaction.changeset(attrs) do
      %Ecto.Changeset{valid?: true} ->
        transaction = Transaction.new(attrs)

        :mnesia.write(
          {:transaction, transaction.id, transaction.amount, transaction.customer_id,
           transaction.type, transaction.description, transaction.inserted_at}
        )

        {:ok, transaction}

      changeset ->
        {:error, changeset}
    end
  end

  defp handle_transaction_result(result) do
    case result do
      {:atomic, result} ->
        result

      {:aborted, error} ->
        error
    end
  end
end
