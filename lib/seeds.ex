defmodule Rinha.Seeds do
  require Logger

  def start do
    with :ok <- :mnesia.wait_for_tables([Customer, Transaction], 5000),
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
      case :mnesia.read({Customer, 1}) do
        [{Customer, 1, _, _, _}] ->
          []

        [] ->
          :mnesia.write({Customer, 1, "Alice", 100_000, 0})
          :mnesia.write({Customer, 2, "John", 80000, 0})
          :mnesia.write({Customer, 3, "Mary", 1_000_000, 0})
          :mnesia.write({Customer, 4, "Josh", 10_000_000, 0})
          :mnesia.write({Customer, 5, "Katty", 500_000, 0})
      end
    end)
  end
end
