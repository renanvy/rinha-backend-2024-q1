defmodule Rinha.Database do
  require Logger

  def start do
    :mnesia.stop
    :mnesia.delete_schema([:rinha@api01, :rinha@api02])
    :mnesia.create_schema([:rinha@api01, :rinha@api02])
    :mnesia.start
    create_tables()
    Rinha.Seeds.start()
  end

  defp create_schema() do
    case :mnesia.create_schema([node()]) do
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

  defp create_tables do
    with :ok <- create_table_customers(),
         :ok <- create_table_transactions(),
         :ok <- create_table_statements() do
      :ok
    end
  end

  defp create_table_customers do
    case :mnesia.create_table(
           :customer,
           attributes: [:id, :limit, :balance],
           disc_copies: [node()]
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

  defp create_table_transactions do
    case :mnesia.create_table(
           :transaction,
           attributes: [:id, :customer_id, :amount, :inserted_at, :type, :description],
           index: [:customer_id],
           disc_copies: [node()]
         ) do
      {:atomic, :ok} ->
        Logger.info("transactions table has been created")
        :ok

      {:aborted, {:already_exists, :transaction}} ->
        Logger.info("transactions table already exists")
        :ok

      error ->
        Logger.error("transactions table was not created: #{inspect(error)}")
        error
    end
  end

  defp create_table_statements do
    case :mnesia.create_table(
           :statement,
           attributes: [:customer_id, :limit, :balance, :last_transactions],
           disc_copies: [node()],
           type: :ordered_set
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
