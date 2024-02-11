defmodule Rinha.Database do
  require Logger

  import Rinha.Helpers, only: [check_nodes_connection: 0]

  @nodes Application.compile_env(:rinha, :nodes, [])

  def start do
    with :ok <- check_nodes_connection(),
         :ok <- create_schema(),
         :ok <- :mnesia.start(),
         :ok <- create_tables() do
      :ok
    else
      error ->
        error
    end
  end

  defp create_schema do
    :mnesia.delete_schema(@nodes)

    case :mnesia.create_schema(@nodes) do
      :ok ->
        Logger.info("schema has been created")
        :ok

      {:error, {_, {:already_exists, _}}} ->
        Logger.info("schema already exists")
        :ok

      error ->
        Logger.error("schema was not created: #{inspect(error)}")
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
           Customer,
           attributes: [:id, :name, :limit, :balance],
           index: []
         ) do
      {:atomic, :ok} ->
        Logger.info("customers table has been created")
        :ok

      {:aborted, {:already_exists, Customer}} ->
        Logger.info("customers table already exists")
        :ok

      error ->
        Logger.error("customers table was not created: #{inspect(error)}")
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
        Logger.info("transactions table has been created")
        :ok

      {:aborted, {:already_exists, Transaction}} ->
        Logger.info("transactions table already exists")
        :ok

      error ->
        Logger.error("transactions table was not created: #{inspect(error)}")
        error
    end
  end
end
