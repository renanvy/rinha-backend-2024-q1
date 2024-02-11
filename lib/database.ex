defmodule Database do
  require Logger

  @nodes [:rinha@api01, :rinha@api02]

  def start do
    with :ok <- check_nodes_connection(),
         :ok <- create_schema(),
         :ok <- :mnesia.start(),
         :ok <- create_table_customers(),
         :ok <- create_table_transactions() do
      :ok
    else
      error ->
        Logger.error("Error creating database or tables: #{inspect(error)}")
        error
    end
  end

  defp check_nodes_connection do
    case {Node.connect(:rinha@api01), Node.connect(:rinha@api02)} do
      {true, true} ->
        :ok

      _ ->
        {:error, :nodes_not_connected}
    end
  end

  defp create_schema do
    case :mnesia.create_schema(@nodes) do
      :ok ->
        Logger.info("Schema created")
        :ok

      {:error, {:rinha@api01, {:already_exists, :rinha@api01}}} ->
        Logger.info("Schema already exists")
        :ok

      error ->
        error
    end
  end

  defp create_table_customers do
    case :mnesia.create_table(
           Customer,
           attributes: [:id, :name, :limit, :balance],
           index: []
         ) do
      {:atomic, :ok} ->
        Logger.info("Table customers has been created")
        :ok

      {:aborted, {:already_exists, Customer}} ->
        Logger.info("Table customer already exists")
        :ok

      error ->
        error
    end
  end

  defp create_table_transactions do
    case :mnesia.create_table(
           Transaction,
           attributes: [:id, :customer_id, :amount, :inserted_at, :type, :description],
           index: [:customer_id]
         ) do
      {:atomic, :ok} ->
        Logger.info("Table transactions has been created")
        :ok

      {:aborted, {:already_exists, Transaction}} ->
        Logger.info("Table transactions already exists")
        :ok

      error ->
        error
    end
  end
end
