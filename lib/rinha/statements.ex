defmodule Rinha.Statements do
  @moduledoc """

  """
  require Qlc

  def get_statement(customer_id) do
    :mnesia.transaction(fn ->
      customer = :mnesia.read({:customer, customer_id})

      ql_handler =
        "[T || {_, _, _, CustomerId, _, _, _} = T <- Transactions, CustomerId =:= Id]"
        |> Qlc.q(Transactions: :mnesia.table(:transaction), Id: customer_id)
        |> Qlc.keysort(4, order: :descending)
        |> Qlc.cursor()

      transactions = Qlc.next_answers(ql_handler, 10)

      Qlc.delete_cursor(ql_handler)

      {:ok, customer, transactions}
    end)
    |> case do
      {:atomic, {:ok, [], _}} ->
        {:error, :customer_not_found}

      {:atomic, {:ok, [customer], transactions}} ->
        {:ok, customer, transactions}

      {:aborted, error} ->
        {:error, error}
    end
  end
end
