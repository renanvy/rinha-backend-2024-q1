defmodule RinhaWeb.Router do
  use Plug.Router

  alias Rinha.{Customers, Statements, Transactions}

  plug(Plug.Logger)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/clientes/:id/transacoes" do
    customer_id = conn.params["id"] && String.to_integer(conn.params["id"])

    if customer_id > 5 do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, Jason.encode!(%{errors: %{customer: ["Cliente não encontrado"]}}))
    else
      params = %{
        amount: conn.body_params["valor"],
        customer_id: customer_id,
        type: conn.body_params["tipo"],
        description: conn.body_params["descricao"]
      }

      with %Ecto.Changeset{valid?: true} <- Transactions.Transaction.changeset(params),
           {:ok, customer, new_balance} <- Customers.check_limit(params[:customer_id], params[:type], params[:amount]) do

        transaction_attrs = Map.put(params, :customer, customer)

        :ok = TransactionServer.create_transaction(transaction_attrs)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(
          200,
          Jason.encode!(%{
            limite: customer.limit,
            saldo: customer.balance
          })
        )
      else
        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(
            422,
            Jason.encode!(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
          )
      end
    end
  end

  get "/clientes/:id/extrato" do
    customer_id = conn.params["id"] && String.to_integer(conn.params["id"])

    if customer_id > 5 do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, Jason.encode!(%{errors: %{customer: ["Cliente não encontrado"]}}))
    else
      {:ok, statement} = Statements.get_statement(customer_id)

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(
        200,
        Jason.encode!(%{
          saldo: %{
            total: statement.balance,
            data_extrato: DateTime.utc_now(),
            limite: statement.limit
          },
          ultimas_transacoes:
            statement.last_transactions
            |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
            |> Enum.map(fn transaction ->
              %{
                valor: transaction.amount,
                tipo: transaction.type,
                descricao: transaction.description,
                realizada_em: transaction.inserted_at
              }
            end)
        })
      )
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
