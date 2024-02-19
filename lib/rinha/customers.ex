defmodule Rinha.Customers do
  alias Rinha.Customers.Customer

  def get_customer(id) do
    case :mnesia.read({:customer, id}) do
      [{:customer, id, limit, balance}] ->
        {:ok, Customer.new(%{id: id, limit: limit, balance: balance})}

      [] ->
        {:error, :customer_not_found}
    end
  end

  def update_balance(customer) do
    :mnesia.write({:customer, customer.id, customer.limit, customer.balance})
  end
end
