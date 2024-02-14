defmodule Rinha.Database do
  require Logger

  def setup do
    with :stopped <- :mnesia.stop(),
         :ok <- create_schema(node()),
         :ok <- :mnesia.start(),
         :ok <- create_tables(),
         :ok <- Rinha.Seeds.start() do
      :ok
    else
      error ->
        Logger.error("Error configuring mnesia: #{inspect(error)}")
        :ok
    end
  end

  def replicate(node) do
    :rpc.call(node, :mnesia, :stop, [])

    with :ok <- create_schema(node),
         :ok <- :rpc.call(node, :mnesia, :start, []),
         :ok <- replicate_tables(node) do
      Logger.info("Table replicated for #{inspect(node)}")
      :ok
    else
      error ->
        Logger.error("Error configuring mnesia nodes: #{inspect(error)}")
        :ok
    end
  end

  defp create_schema(node) do
    :mnesia.delete_schema([node])

    case :mnesia.create_schema([node]) do
      :ok ->
        Logger.info("schema has been created")

      {:error, {_node, {:already_exists, _}}} ->
        Logger.info("schema already exists")

      error ->
        Logger.info("error creating schema #{inspect(error)}")
    end

    :ok
  end

  def replicate_tables(node) do
    :mnesia.change_config(:extra_db_nodes, [node])
    :mnesia.add_table_copy(:customer, node, :disc_only_copies)
    :mnesia.add_table_copy(:transaction, node, :disc_only_copies)

    :ok
  end

  defp create_tables do
    :ok = create_table_customers()
    :ok = create_table_transactions()
  end

  defp create_table_customers do
    case :mnesia.create_table(
           :customer,
           attributes: [:id, :name, :limit, :balance],
           index: [],
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
