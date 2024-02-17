defmodule Rinha.Database do
  require Logger

  def setup(nodes) when is_list(nodes) do
    with :stopped <- :mnesia.stop(),
         :ok <- create_schema(nodes),
         :ok <- :mnesia.start(),
         :ok <- create_tables(nodes),
         :ok <- Rinha.Seeds.start() do
      :ok
    else
      error ->
        error
    end
  end

  # def replicate(node) do
  #   :rpc.call(node, :mnesia, :stop, [])

  #   with :ok <- :rpc.call(node, :mnesia, :start, []),
  #        :ok <- replicate_tables(node) do
  #     Logger.info("Table replicated for #{inspect(node)}")
  #     :ok
  #   else
  #     error ->
  #       Logger.error("Error configuring mnesia nodes: #{inspect(error)}")
  #       :ok
  #   end
  # end

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

    :ok
  end

  # def replicate_tables(node) do
  #   :mnesia.change_config(:extra_db_nodes, [node])
  #   :mnesia.add_table_copy(:schema, node, :disc_copies)
  #   :mnesia.add_table_copy(:customer, node, :disc_copies)
  #   :mnesia.add_table_copy(:transaction, node, :disc_copies)
  #   :mnesia.add_table_copy(:statement, node, :disc_copies)

  #   :ok
  # end

  defp create_tables(nodes) do
    :ok = create_table_customers(nodes)
    :ok = create_table_transactions(nodes)
    :ok = create_table_statements(nodes)
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

  defp create_table_transactions(nodes) do
    case :mnesia.create_table(
           :transaction,
           attributes: [:id, :customer_id, :amount, :inserted_at, :type, :description],
           index: [:customer_id],
           disc_copies: nodes
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
