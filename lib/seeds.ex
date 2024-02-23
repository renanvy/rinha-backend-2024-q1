defmodule Rinha.Seeds do
  require Logger

  def run do
    case seed_accounts() do
      {:atomic, :ok} ->
        Logger.info("Seeds successfully executed")
        :ok

      error ->
        error
    end
  end

  defp seed_accounts do
    :mnesia.transaction(fn ->
      case :mnesia.read({:account, 1}) do
        [{:account, 1, _, _}] ->
          []

        [] ->
          :mnesia.write({:account, 1, 100_000, 0, []})
          :mnesia.write({:account, 2, 80000, 0, []})
          :mnesia.write({:account, 3, 1_000_000, 0, []})
          :mnesia.write({:account, 4, 10_000_000, 0, []})
          :mnesia.write({:account, 5, 500_000, 0, []})
      end
    end)
  end
end
