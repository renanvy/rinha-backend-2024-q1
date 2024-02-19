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
    case :mnesia.dirty_read({:customer, 1}) do
      [{:customer, 1, _, _}] ->
        []

      [] ->
        :mnesia.dirty_write({:customer, 1, 100_000, 0})
        :mnesia.dirty_write({:customer, 2, 80000, 0})
        :mnesia.dirty_write({:customer, 3, 1_000_000, 0})
        :mnesia.dirty_write({:customer, 4, 10_000_000, 0})
        :mnesia.dirty_write({:customer, 5, 500_000, 0})

        :mnesia.dirty_write({:statement, 1, 100_000, 0, []})
        :mnesia.dirty_write({:statement, 2, 80000, 0, []})
        :mnesia.dirty_write({:statement, 3, 1_000_000, 0, []})
        :mnesia.dirty_write({:statement, 4, 10_000_000, 0, []})
        :mnesia.dirty_write({:statement, 5, 500_000, 0, []})
    end
  end
end
