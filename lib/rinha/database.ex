defmodule Rinha.Database do
  require Logger

  def setup(nodes) when is_list(nodes) do
    with _ <- :rpc.multicall(nodes, :mnesia, :stop, []),
         :ok <- create_schema(nodes),
         _ <- :rpc.multicall(nodes, :mnesia, :start, []),
         :ok <- create_tables(nodes),
         :ok <-
           :mnesia.wait_for_tables(
             [
               :customer,
               :transaction_1,
               :transaction_2,
               :transaction_3,
               :transaction_4,
               :transaction_5,
               :statement
             ],
             2000
           ),
         :ok <- maybe_clear_tables(),
         :ok <- Rinha.Seeds.start() do
      :ok
    end
  end

  defp create_schema(nodes) do
    case :mnesia.create_schema(nodes) do
      :ok ->
        Logger.info("schema has been created")
        :ok

      {:error, {_node, {:already_exists, _}}} ->
        Logger.info("schema already exists")
        :ok

      error ->
        Logger.info("error creating schema #{inspect(error)}")
        error
    end
  end

  defp maybe_clear_tables do
    {:atomic, _} = :mnesia.clear_table(:transaction_1)
    {:atomic, _} = :mnesia.clear_table(:transaction_2)
    {:atomic, _} = :mnesia.clear_table(:transaction_3)
    {:atomic, _} = :mnesia.clear_table(:transaction_4)
    {:atomic, _} = :mnesia.clear_table(:transaction_5)
    {:atomic, _} = :mnesia.clear_table(:customer)
    {:atomic, _} = :mnesia.clear_table(:statement)
    Logger.info("tables has been cleared")
    :ok
  end

  defp create_tables(nodes) do
    with :ok <- create_table_customers(nodes),
         :ok <- create_table_transactions(nodes, 1),
         :ok <- create_table_transactions(nodes, 2),
         :ok <- create_table_transactions(nodes, 3),
         :ok <- create_table_transactions(nodes, 4),
         :ok <- create_table_transactions(nodes, 5),
         :ok <- create_table_statements(nodes) do
      :ok
    end
  end

  defp create_table_customers(nodes) do
    case :mnesia.create_table(
           :customer,
           attributes: [:id, :limit, :balance],
           disc_copies: nodes
         ) do
      {:atomic, :ok} ->
        Logger.info("customers table has been created")
        :ok

      {:aborted, {:already_exists, :customer}} ->
        Logger.info("customers table already exists")
        :ok

      error ->
        Logger.error("customers table was not created: #{inspect(error)}")
        error
    end
  end

  defp create_table_transactions(nodes, customer_id) do
    table_name = :"transaction_#{customer_id}"

    case :mnesia.create_table(
           table_name,
           attributes: [:id, :amount, :inserted_at, :type, :description],
           disc_copies: nodes
         ) do
      {:atomic, :ok} ->
        Logger.info("transactions table has been created")
        :ok

      {:aborted, {:already_exists, ^table_name}} ->
        Logger.info("transactions table already exists")
        :ok

      error ->
        Logger.error("transactions table was not created: #{inspect(error)}")
        error
    end
  end

  defp create_table_statements(nodes) do
    case :mnesia.create_table(
           :statement,
           attributes: [:customer_id, :limit, :balance, :last_transactions],
           disc_copies: nodes
         ) do
      {:atomic, :ok} ->
        Logger.info("statement table has been created")
        :ok

      {:aborted, {:already_exists, :statement}} ->
        Logger.info("statement table already exists")
        :ok

      error ->
        Logger.error("statement table was not created: #{inspect(error)}")
        error
    end
  end
end
