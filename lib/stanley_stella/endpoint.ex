defmodule StanleyStella.Endpoint do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  @index_html File.read!("web/index.html")

  get "/" do
    send_resp(conn, 200, @index_html)
  end

  get "/stock/:id" do
    case StanleyStella.product_table(conn.params["id"]) do
      {:ok, html} ->
        send_resp(conn, 200, html)

      {:error, _} ->
        send_resp(conn, 404, "<p>Dieses Produkt existiert nicht.</p>")
    end
  end

  get "/json/colors/:id" do
    case StanleyStella.stock(conn.params["id"]) do
      {:ok, stock} ->
        json(conn, stock.colors)

      {:error, message} ->
        json_error(conn, 400, message)
    end
  end

  get "/json/sizes/:id" do
    case StanleyStella.stock(conn.params["id"]) do
      {:ok, stock} ->
        json(conn, stock.sizes)

      {:error, message} ->
        json_error(conn, 400, message)
    end
  end

  get "/json/stock/:id" do
    case StanleyStella.stock(conn.params["id"]) do
      {:ok, stock} ->
        json(conn, stock)

      {:error, message} ->
        json_error(conn, 400, message)
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp json(conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(data))
  end

  defp json_error(conn, code, message) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Jason.encode!(%{error: message}))
  end
end
