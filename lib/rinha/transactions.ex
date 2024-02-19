defmodule Rinha.Transactions do
  alias Rinha.Customers
  alias Rinha.Statements
  alias Rinha.Transactions.Transaction

  def create_transaction(attrs) do
    :mnesia.transaction(fn ->
      with {:ok, customer} <- Customers.get_customer(attrs[:customer_id]),
           {:ok, transaction} <- do_create_transaction(attrs),
           {:ok, customer} <- Customers.update_balance(customer, transaction),
           :ok <- Statements.add_transaction(transaction, customer) do
        {:ok, {transaction, customer}}
      end
    end)
    |> handle_result()
  end

  defp do_create_transaction(attrs) do
    case Transaction.changeset(attrs) do
      %Ecto.Changeset{valid?: true} ->
        transaction = Transaction.new(attrs)

        :mnesia.write(
          {:"transaction_#{transaction.customer_id}", transaction.id, transaction.amount,
           transaction.inserted_at, transaction.type, transaction.description}
        )

        {:ok, transaction}

      changeset ->
        {:error, changeset}
    end
  end

  defp handle_result(result) do
    case result do
      {:atomic, {:ok, result}} ->
        {:ok, result}

      {:atomic, {:error, result}} ->
        {:error, result}

      {:aborted, {:error, error}} ->
        {:error, error}
    end
  end
end
