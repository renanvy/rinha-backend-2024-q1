defmodule Rinha.Accounts do
  @moduledoc """
  `Rinha.Accounts` context
  """
  alias Rinha.Accounts.{Account, Transaction}

  @doc """
  Returns an account with its last 10 transactions

  ## Examples

      iex> get_account(1)
      {:ok, %Account{id: 1, limit: 1_000_000, balance: 0, latest_transactions: [%Transaction{}, ...]}}

      iex> get_account(1)
      {:error, :account_not_found}
  """
  @spec get_account(non_neg_integer()) :: {:ok, Account.t()} | {:error, :account_not_found}
  def get_account(id) do
    case :mnesia.dirty_read({:account, id}) do
      [{:account, id, limit, balance, latest_transactions}] ->
        {:ok,
         Account.new(%{
           id: id,
           limit: limit,
           balance: balance,
           latest_transactions: latest_transactions
         })}

      [] ->
        {:error, :account_not_found}
    end
  end

  @doc """
  Creates a transaction and updates the account balance

  ## Examples

  * Creates successfully

      iex> create_transaction(%{valor: 500_000, tipo: "c", descricao: "salário"})
      {:ok, %Transaction{}, %Account{}}

  * Error due to not enough funds

      iex> create_transaction(%{valor: 500_000, tipo: "d", descricao: "pensão"})
      {:error, %Ecto.Changeset{errors: [limit: "Limite atingido"]}}

  """
  @spec create_transaction(map()) ::
          {:ok, {Transaction.t(), Account.t()}} | {:error, Ecto.Changeset.t()}
  def create_transaction(attrs) do
    :mnesia.transaction(fn ->
      with {:ok, account} <- read_account(attrs[:account_id]),
           {:ok, transaction} <- Transaction.changeset(attrs),
           {:ok, account} <- change_account_balance(account, transaction),
           :ok <- write_transaction(account, transaction) do
        {:ok, {transaction, account}}
      end
    end)
    |> case do
      {:atomic, {:ok, result}} ->
        {:ok, result}

      {:atomic, {:error, result}} ->
        {:error, result}

      {:aborted, {:error, error}} ->
        {:error, error}
    end
  end

  defp read_account(id) do
    case :mnesia.wread({:account, id}) do
      [{:account, id, limit, balance, latest_transactions}] ->
        {:ok,
         Account.new(%{
           id: id,
           limit: limit,
           balance: balance,
           latest_transactions: latest_transactions
         })}

      [] ->
        {:error, :account_not_found}
    end
  end

  defp change_account_balance(account, %Transaction{tipo: :c, valor: amount} = transaction) do
    new_balance = account.balance + amount
    Account.changeset(:update_balance, account, transaction.tipo, %{balance: new_balance})
  end

  defp change_account_balance(account, %Transaction{tipo: :d, valor: amount} = transaction) do
    new_balance = account.balance - amount
    Account.changeset(:update_balance, account, transaction.tipo, %{balance: new_balance})
  end

  defp write_transaction(account, transaction) do
    transactions = [transaction | account.latest_transactions]

    :mnesia.write(
      {:account, account.id, account.limit, account.balance, Enum.take(transactions, 10)}
    )
  end
end
