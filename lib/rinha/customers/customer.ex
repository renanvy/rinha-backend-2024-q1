defmodule Rinha.Customers.Customer do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:id, :integer)
    field(:limit, :integer)
    field(:balance, :integer)
  end

  def update_balance_changeset(customer, attrs) do
    customer
    |> cast(attrs, [:balance])
    |> validate_required([:balance])
  end

  def new(attrs) do
    %__MODULE__{
      id: attrs.id,
      limit: attrs.limit,
      balance: attrs.balance
    }
  end
end
