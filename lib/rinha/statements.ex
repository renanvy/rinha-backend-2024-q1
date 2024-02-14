defmodule Rinha.Statements do
  @moduledoc """

  """

  alias Rinha.Customers

  def get_statement(customer_id) do
    :mnesia.transaction(fn ->
      {:ok, customer} = Customers.get_customer(customer_id)

      transactions =
        :mnesia.match_object(:transaction, {:transaction, :_, :_, customer_id, :_, :_, :_}, :read)

      {customer, transactions}
    end)
    |> case do
      {:atomic, result} ->
        {:ok, result}

      {:aborted, error} ->
        {:error, error}
    end
  end
end
