defmodule RinhaWeb.Router do
  use Plug.Router

  alias Rinha.Accounts

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:check_account_id)
  plug(:dispatch)

  post "/clientes/:id/transacoes" do
    params = %{
      valor: conn.body_params["valor"],
      account_id: conn.assigns.id,
      tipo: conn.body_params["tipo"],
      descricao: conn.body_params["descricao"]
    }

    case Accounts.create_transaction(params) do
      {:ok, {_transaction, account}} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{limite: account.limit, saldo: account.balance}))

      {:error, _changeset} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(422, "")
    end
  end

  get "/clientes/:id/extrato" do
    with {:ok, account} <- Accounts.get_account(conn.assigns.id) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(
        200,
        Jason.encode!(%{
          saldo: %{
            total: account.balance,
            data_extrato: DateTime.utc_now(),
            limite: account.limit
          },
          ultimas_transacoes: account.latest_transactions
        })
      )
    else
      {:error, :account_not_found} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, "")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp check_account_id(conn, _opts) do
    id = conn.params["id"] && String.to_integer(conn.params["id"])

    if id in 1..5 do
      Plug.Conn.assign(conn, :id, id)
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, "")
      |> halt()
    end
  end
end
