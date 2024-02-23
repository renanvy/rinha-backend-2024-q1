defmodule Rinha.Accounts.Account do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          limit: non_neg_integer(),
          balance: integer(),
          latest_transactions: list(Transaction.t())
        }

  @primary_key false
  embedded_schema do
    field(:id, :integer)
    field(:limit, :integer)
    field(:balance, :integer)
    field(:latest_transactions, {:array, :map})
  end

  def changeset(:update_balance, account, transaction_type, attrs) do
    account
    |> cast(attrs, [:balance])
    |> validate_required([:balance])
    |> validate_limit_reached(account, transaction_type)
    |> apply_action(:update_balance)
  end

  def new(attrs) do
    %__MODULE__{
      id: attrs.id,
      limit: attrs.limit,
      balance: attrs.balance,
      latest_transactions: attrs.latest_transactions
    }
  end

  defp validate_limit_reached(%Ecto.Changeset{valid?: true} = changeset, account, :d) do
    balance = changeset |> get_field(:balance) |> abs()

    if balance > account.limit do
      add_error(changeset, :limit, "Limite atingido")
    else
      changeset
    end
  end

  defp validate_limit_reached(changeset, _account, _transaction_type), do: changeset
end
