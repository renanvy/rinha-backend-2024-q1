defmodule Rinha.NodeMonitor do
  @moduledoc """

  """
  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  @impl true
  def init(_args) do
    :ok = :net_kernel.monitor_nodes(true)

    if String.contains?(Atom.to_string(node()), "api01") do
      send(self(), :setup_database)
    end

    {:ok, []}
  end

  @impl true
  def handle_info(:setup_database, state) do
    Rinha.Database.setup()

    {:noreply, state}
  end

  @impl true
  def handle_info({:nodeup, node}, state) do
    {:noreply, [node | state]}
  end

  def handle_info({:nodedown, node}, state) do
    {:noreply, List.delete(state, node)}
  end
end
