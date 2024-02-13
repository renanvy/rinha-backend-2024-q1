defmodule Rinha.NodeMonitor do
  @moduledoc """

  """
  use GenServer

  require Logger

  @first_node Application.compile_env!(:rinha, :nodes) |> List.first()

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  @impl true
  def init(_args) do
    :ok = :net_kernel.monitor_nodes(true)

    if node() == @first_node do
      Process.send_after(self(), :config_database, 500)
    end

    {:ok, []}
  end

  @impl true
  def handle_info(:config_database, state) do
    Rinha.Database.setup()

    {:noreply, state}
  end

  @impl true
  def handle_info({:nodeup, node}, state) do
    Rinha.Database.replicate(node)

    {:noreply, [node | state]}
  end

  def handle_info({:nodedown, node}, state) do
    {:noreply, List.delete(state, node)}
  end
end
