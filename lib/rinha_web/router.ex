defmodule RinhaWeb.Router do
  use Plug.Router

  alias Rinha.{Statements, Transactions}

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

    conn = put_resp_content_type(conn, "application/json")

    case Transactions.create_transaction(params) do
      {:ok, transaction} ->
        send_resp(
          conn,
          200,
          Jason.encode!(%{
            limite: transaction.customer.limit,
            saldo: transaction.customer.balance
          })
        )

      {:error, :customer_not_found} ->
        send_resp(conn, 404, Jason.encode!(%{errors: %{customer: ["Cliente não encontrado"]}}))

      {:error, %Ecto.Changeset{} = changeset} ->
        send_resp(
          conn,
          422,
          Jason.encode!(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
        )
    end
  end

  get "/clientes/:id/extrato" do
    conn = put_resp_content_type(conn, "application/json")

    case Statements.get_statement(String.to_integer(conn.params["id"])) do
      {:ok, {customer, transactions}} ->
        send_resp(
          conn,
          200,
          Jason.encode!(%{
            "saldo" => %{
              "total" => customer.balance,
              "data_extrato" => DateTime.utc_now(:millisecond),
              "limite" => customer.limit
            },
            "ultimas_transacoes" =>
              Enum.map(transactions, fn {_, _id, amount, _c_id, type, description, inserted_at} ->
                %{
                  "valor" => amount,
                  "tipo" => type,
                  "descricao" => description,
                  "realizada_em" => inserted_at
                }
              end)
          })
        )

      {:error, :customer_not_found} ->
        send_resp(conn, 404, Jason.encode!(%{errors: %{customer: ["Cliente não encontrado"]}}))
    end
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
