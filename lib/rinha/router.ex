defmodule Rinha.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)
  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  post "/clientes/:id/transacoes" do
    send_resp(conn, 200, "Transações!")
  end

  get "/clientes/:id/extrato" do
    send_resp(conn, 200, "Extrato!")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
