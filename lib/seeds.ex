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
      case :mnesia.read({:customer, 1}) do
        [{:customer, 1, _, _}] ->
          []

        [] ->
          :mnesia.write({:customer, 1, 100_000, 0})
          :mnesia.write({:customer, 2, 80000, 0})
          :mnesia.write({:customer, 3, 1_000_000, 0})
          :mnesia.write({:customer, 4, 10_000_000, 0})
          :mnesia.write({:customer, 5, 500_000, 0})

          :mnesia.write({:statement, 1, 100_000, 0, []})
          :mnesia.write({:statement, 2, 80000, 0, []})
          :mnesia.write({:statement, 3, 1_000_000, 0, []})
          :mnesia.write({:statement, 4, 10_000_000, 0, []})
          :mnesia.write({:statement, 5, 500_000, 0, []})
      end
    end)
  end
end
