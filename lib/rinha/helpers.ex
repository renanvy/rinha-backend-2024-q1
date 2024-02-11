defmodule Rinha.Helpers do
  require Logger

  @nodes Application.compile_env(:rinha, :nodes, [])

  def check_nodes_connection do
    if Enum.all?(@nodes, &Node.connect/1) do
      :ok
    else
      Logger.error("Nodes not connected")
      {:error, :nodes_not_connected}
    end
  end
end
