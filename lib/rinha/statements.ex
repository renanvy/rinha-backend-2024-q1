defmodule Rinha.Statements do
  @moduledoc """

  """
  require Qlc

  def get_statement(customer_id) do
    :mnesia.transaction(fn ->
      customer = :mnesia.read({:customer, customer_id})

      ql_handler =
        "[T || {_, _, CustomerId, _, _, _, _} = T <- Transactions, CustomerId =:= Id]"
        |> Qlc.q(Transactions: :mnesia.table(:transaction), Id: customer_id)
        |> Qlc.keysort(3, order: :descending)
        |> Qlc.cursor()

      transactions = Qlc.next_answers(ql_handler, 10)

      Qlc.delete_cursor(ql_handler)

      {customer, transactions, DateTime.utc_now()}
    end)
    |> case do
      {:atomic, {[], _, _}} ->
        {:error, :customer_not_found}

      {:atomic, {[customer], transactions, statement_datetime}} ->
        {:ok, customer, transactions, statement_datetime}

      {:aborted, error} ->
        {:error, error}
    end
  end
end
