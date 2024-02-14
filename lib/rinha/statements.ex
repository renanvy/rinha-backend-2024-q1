defmodule Rinha.Statements do
  @moduledoc """

  """

  def get_statement(customer_id) do
    :mnesia.transaction(fn ->
      customer = :mnesia.read({:customer, customer_id})

      transactions =
        :mnesia.match_object(:transaction, {:transaction, :_, :_, customer_id, :_, :_, :_}, :read)

      {customer, transactions}
    end)
    |> case do
      {:atomic, {[], _}} ->
        {:error, :customer_not_found}

      {:atomic, {[customer], transactions}} ->
        {:ok, customer, transactions}

      {:aborted, error} ->
        {:error, error}

      error ->
        error
    end
  end
end
