defmodule Rinha.Seeds do
  require Logger

  def start do
    case create_customers() do
      {:atomic, :ok} ->
        Logger.info("Seeds successfully executed")
        :ok

      error ->
        error
    end
  end

  defp create_customers do
    :mnesia.transaction(fn ->
      :mnesia.write({Customer, 1, "Alice", 100_000, 0})
      :mnesia.write({Customer, 2, "John", 80000, 0})
      :mnesia.write({Customer, 3, "Mary", 1_000_000, 0})
      :mnesia.write({Customer, 4, "Josh", 10_000_000, 0})
      :mnesia.write({Customer, 5, "Katty", 500_000, 0})
    end)
  end
end
