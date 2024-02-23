defmodule Rinha.Accounts.Transaction do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          valor: integer(),
          tipo: :c | :d | String.t(),
          descricao: String.t(),
          realizada_em: DateTime.t()
        }
  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field(:valor, :integer)
    field(:tipo, Ecto.Enum, values: [:c, :d])
    field(:descricao, :string)
    field(:realizada_em, :utc_datetime)
  end

  def changeset(attrs) do
    attrs = Map.put(attrs, :realizada_em, DateTime.utc_now())

    %__MODULE__{}
    |> cast(attrs, [:valor, :tipo, :descricao, :realizada_em])
    |> validate_required([:valor, :tipo, :descricao])
    |> validate_length(:descricao, min: 1, max: 10)
    |> validate_number(:valor, greater_than: 0)
    |> apply_action(:validate)
  end
end
