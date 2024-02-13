defmodule Rinha.Seeds do
  require Logger

  def start do
    with :ok <- :mnesia.wait_for_tables([:customer, :transaction], 5000),
         {:atomic, _} <- create_customers() do
      Logger.info("Seeds successfully executed")
      :ok
    else
      error ->
        error
    end
  end

  defp create_customers do
    :mnesia.transaction(fn ->
      case :mnesia.read({:customer, 1}) do
        [{:customer, 1, _, _, _}] ->
          []

        [] ->
          :mnesia.write({:customer, 1, "Alice", 100_000, 0})
          :mnesia.write({:customer, 2, "John", 80000, 0})
          :mnesia.write({:customer, 3, "Mary", 1_000_000, 0})
          :mnesia.write({:customer, 4, "Josh", 10_000_000, 0})
          :mnesia.write({:customer, 5, "Katty", 500_000, 0})
      end
    end)
  end
end
