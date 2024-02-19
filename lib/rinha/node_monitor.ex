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

    {:ok, []}
  end

  @impl true
  def handle_info({:nodeup, _node}, state) do
    Rinha.Database.setup(nodes())

    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    {:noreply, List.delete(state, node)}
  end

  defp nodes do
    Application.get_env(:rinha, :nodes, [])
  end
end
