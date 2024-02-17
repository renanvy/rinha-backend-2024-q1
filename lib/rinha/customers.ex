defmodule Rinha.Customers do
  alias Rinha.Customers.Customer
  alias Rinha.Transactions.Transaction

  def get_customer(id) do
    case :mnesia.read({:customer, id}) do
      [{:customer, id, limit, balance}] ->
        {:ok, Customer.new(%{id: id, limit: limit, balance: balance})}

      [] ->
        {:error, :customer_not_found}
    end
  end

  def check_limit(customer_id, type, amount) do
    :mnesia.transaction(fn ->
      [{:customer, customer_id, limit, balance}] = :mnesia.read({:customer, customer_id})
      customer = Customer.new(%{id: id, limit: limit, balance: balance})
      new_balance = new_balance(customer, type)

      case Customer.update_balance_changeset(customer, type, %{balance: new_balance}) do
        %Ecto.Changeset{valid?: true} ->
          {:ok, %{customer | balance: new_balance}}

        changeset ->
          {:error, changeset}
      end
    end)
  end

  def new_balance(customer, "d"), do: customer.balance - amount
  def new_balance(customer, "c"), do: customer.balance + amount

  def update_balance(customer, %Transaction{type: "c", amount: amount} = transaction) do
    new_balance = customer.balance + amount
    do_update_balance(customer, transaction, new_balance)
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
        :mnesia.write({:customer, customer.id, customer.limit, customer.balance})
        {:ok, customer}

      changeset ->
        {:error, changeset}
    end
  end
end
