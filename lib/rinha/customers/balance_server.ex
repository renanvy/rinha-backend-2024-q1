defmodule Rinha.Customers.BalanceServer do
  @moduledoc """

  """
  @initial_values Application.compile_env(:rinha, :initial_values)

  use GenServer

  def check_limit(customer_id, operation_type, amount) do
    customer_id
    |> name()
    |> GenServer.whereis()
    |> GenServer.call({:check_limit, operation_type, amount})
  end

  def start_link(customer_id) do
    GenServer.start_link(__MODULE__, customer_id, name: name(customer_id))
  end

  @impl true
  def init(customer_id) do
    {id, limit, balance} = Map.get(@initial_values, customer_id)
    {:ok, %{id: id, limit: limit, balance: balance}}
  end

  @impl true
  def handle_call({:check_limit, :c, amount}, _from, %{balance: balance} = state) do
    state = %{state | balance: balance + amount}

    {:reply, {:ok, state.balance, state.limit}, state}
  end

  @impl true
  def handle_call({:check_limit, :d, amount}, _from, %{balance: balance, limit: limit} = state) do
    new_balance = balance - amount

    case new_balance |> abs() |> enough_limit?(limit) do
      true ->
        state = %{state | balance: new_balance}

        {:reply, {:ok, state.balance, state.limit}, state}

      false ->
        {:reply, :no_limit, state}
    end
  end

  defp enough_limit?(new_balance, limit) when new_balance <= limit, do: true
  defp enough_limit?(_, _), do: false

  defp name(customer_id) do
    {:via, Registry, {Rinha.Registry, "customer_balance_#{customer_id}"}}
  end

  def child_spec(customer_id) do
    %{
      id: :"balance_server_#{customer_id}",
      start: {__MODULE__, :start_link, [customer_id]}
    }
  end
end
