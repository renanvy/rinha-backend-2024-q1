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

  get "/hello" do
    send_resp(conn, 200, "Hello World!")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
