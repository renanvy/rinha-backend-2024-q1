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

    if String.starts_with?(Atom.to_string(node()), "rinha1") do
      Process.send_after(self(), :setup_database, 500)
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
    if String.starts_with?(Atom.to_string(node), "rinha2") do
      Rinha.Database.replicate(node)
    end

    {:noreply, [node | state]}
  end

  def handle_info({:nodedown, node}, state) do
    {:noreply, List.delete(state, node)}
  end
end
