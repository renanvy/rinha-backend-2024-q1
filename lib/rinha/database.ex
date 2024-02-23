defmodule Rinha.Database do
  require Logger

  def setup(nodes) when is_list(nodes) do
    with {_, []} <- :rpc.multicall(nodes, :mnesia, :stop, []),
         :ok <- create_schema(nodes),
         {_, []} <- :rpc.multicall(nodes, :mnesia, :start, []),
         :ok <- create_table_accounts(nodes),
         :ok <-
           :mnesia.wait_for_tables(
             [
               :account
             ],
             2000
           ),
         :ok <- maybe_clear_tables(),
         :ok <- Rinha.Seeds.run() do
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
    {:atomic, _} = :mnesia.clear_table(:account)

    Logger.info("tables have been cleared")
    :ok
  end

  defp create_table_accounts(nodes) do
    case :mnesia.create_table(
           :account,
           attributes: [:id, :limit, :balance, :latest_transactions],
           disc_copies: nodes
         ) do
      {:atomic, :ok} ->
        Logger.info("accounts table has been created")
        :ok

      {:aborted, {:already_exists, :account}} ->
        Logger.info("accounts table already exists")
        :ok

      error ->
        Logger.error("accounts table was not created: #{inspect(error)}")
        error
    end
  end
end
