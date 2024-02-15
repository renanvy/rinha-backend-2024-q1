defmodule Rinha.Database do
  require Logger

  def start do
    :mnesia.stop()

    with :ok <- create_schema(),
         :ok <- :mnesia.start(),
         :ok <- create_tables() do
      :ok
    else
      error ->
        error
    end
  end

  defp create_schema() do
    :mnesia.delete_schema([node()])

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
         :ok <- create_table_transactions() do
      :ok
    end
  end

  defp create_table_customers do
    case :mnesia.create_table(
           :customer,
           attributes: [:id, :name, :limit, :balance],
           disc_only_copies: [node()]
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
           disc_only_copies: [node()]
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
end
