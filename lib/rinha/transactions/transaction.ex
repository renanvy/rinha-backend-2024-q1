defmodule Rinha.Transactions.Transaction do
  use Ecto.Schema

  import Ecto.Changeset

  alias Rinha.Customers.Customer

  @primary_key false
  embedded_schema do
    field(:id, :integer)
    field(:amount, :integer)
    field(:customer_id, :integer)
    field(:type, Ecto.Enum, values: [:c, :d])
    field(:description, :string)
    field(:inserted_at, :utc_datetime)

    embeds_one(:customer, Customer)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:amount, :customer_id, :type, :description])
    |> validate_required([:amount, :customer_id, :type, :description])
    |> validate_length(:description, min: 1, max: 10)
    |> validate_number(:amount, greater_than: 0)
  end

  def new(attrs) do
    %__MODULE__{
      id: Ecto.UUID.generate(),
      amount: attrs.amount,
      customer_id: attrs.customer_id,
      type: attrs.type,
      description: attrs.description,
      inserted_at: DateTime.utc_now()
    }
  end
end
