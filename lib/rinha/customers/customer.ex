defmodule Rinha.Customers.Customer do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:id, :integer)
    field(:limit, :integer)
    field(:balance, :integer)
  end

  def update_balance_changeset(customer, transaction_type, attrs) do
    customer
    |> cast(attrs, [:balance])
    |> validate_required([:balance])
    |> validate_limit_reached(customer, transaction_type)
  end

  def new(attrs) do
    %__MODULE__{
      id: attrs.id,
      limit: attrs.limit,
      balance: attrs.balance
    }
  end

  defp validate_limit_reached(%Ecto.Changeset{valid?: true} = changeset, customer, "d") do
    balance = changeset |> get_field(:balance) |> abs()

    if balance > customer.limit do
      add_error(changeset, :limit, "Limite atingido")
    else
      changeset
    end
  end

  defp validate_limit_reached(changeset, _customer, _transaction_type), do: changeset
end
