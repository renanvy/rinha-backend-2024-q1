defmodule RinhaWeb.Router do
  use Plug.Router

  alias Rinha.Transactions

  plug(Plug.Logger)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/clientes/:id/transacoes" do
    params = %{
      amount: conn.body_params["valor"],
      customer_id: conn.params["id"] && String.to_integer(conn.params["id"]),
      type: conn.body_params["tipo"],
      description: conn.body_params["descricao"]
    }

    case Transactions.create_transaction(params) do
      {:ok, transaction} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(
          200,
          Jason.encode!(%{
            limite: transaction.customer.limit,
            saldo: transaction.customer.balance
          })
        )

      {:error, :customer_not_found} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, Jason.encode!(%{errors: %{customer: ["Cliente não encontrado"]}}))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(
          422,
          Jason.encode!(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
        )
    end
  end

  get "/clientes/:id/extrato" do
    customer_id = conn.params["id"] && String.to_integer(conn.params["id"])

    case Transactions.get_transactions(customer_id) do
      {:ok, result} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(render_transactions(result)))

      {:error, :customer_not_found} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, Jason.encode!(%{errors: %{customer: ["Cliente não encontrado"]}}))
    end
  end

  defp render_transactions(result) do
    %{
      saldo: %{
        total: result.customer.balance,
        data_extrato: DateTime.utc_now(),
        limite: result.customer.limit
      },
      ultimas_transacoes:
        Enum.map(result.transactions, fn transaction ->
          %{
            valor: transaction.amount,
            tipo: transaction.type,
            descricao: transaction.description,
            realizada_em: transaction.inserted_at
          }
        end)
    }
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
