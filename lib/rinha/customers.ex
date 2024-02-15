defmodule Rinha.Customers do
  alias Rinha.Customers.Customer
  alias Rinha.Transactions.Transaction

  @mnesia_node :rinha@api01

  def get_customer(id) do
    case :mnesia.read({:customer, id}) do
      [{:customer, id, name, limit, balance}] ->
        {:ok, Customer.new(%{id: id, name: name, limit: limit, balance: balance})}

      [] ->
        {:error, :customer_not_found}
    end
  end

  def update_balance(customer, %Transaction{type: "d", amount: amount} = transaction) do
    new_balance = customer.balance - amount
    do_update_balance(customer, transaction, new_balance)
  end

  def update_balance(customer, %Transaction{type: "c", amount: amount} = transaction) do
    new_balance = customer.balance + amount
    do_update_balance(customer, transaction, new_balance)
  end

  defp do_update_balance(customer, transaction, new_balance) do
    case Customer.update_balance_changeset(customer, transaction.type, %{
           balance: new_balance
         }) do
      %Ecto.Changeset{valid?: true} ->
        customer = Customer.new(%{customer | balance: new_balance})

        :mnesia.write({:customer, customer.id, customer.name, customer.limit, customer.balance})

        {:ok, customer}

      changeset ->
        {:error, changeset}
    end
  end
end
