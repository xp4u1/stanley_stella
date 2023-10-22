defmodule StanleyStella.Endpoint do
  require Logger
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  @index_html File.read!("web/index.html")

  get "/" do
    send_resp(conn, 200, @index_html)
  end

  get "/html/details" do
    case params(conn) do
      %{"product_id" => product_id} ->
        case StanleyStella.Web.render_product_details(String.trim(product_id)) do
          {:ok, html} ->
            send_resp(conn, 200, html)

          {:error, _} ->
            send_resp(conn, 200, "<p>Dieses Produkt existiert nicht.</p>")
        end

      _ ->
        send_resp(conn, 400, "Invalid request")
    end
  end

  get "/html/preview" do
    case params(conn) do
      %{"product_id" => product_id, "color_id" => color_id} ->
        # No check if the product_id or color_id is valid.
        # Invalid parameters will result in corrupt image urls.
        send_resp(
          conn,
          200,
          StanleyStella.Web.render_preview_images(String.trim(product_id), color_id)
        )

      _ ->
        send_resp(conn, 400, "Invalid request")
    end
  end

  get "/actions/download" do
    case params(conn) do
      %{"product_id" => product_id} ->
        case StanleyStella.Actions.download_preview_images(String.trim(product_id)) do
          :ok ->
            send_resp(
              conn,
              200,
              "Die Dateien wurden in \"#{StanleyStella.Actions.download_directory_path()}\" gespeichert."
            )

          {:error, errors} ->
            Logger.error(errors)

            send_resp(
              conn,
              200,
              "Beim Speichern ist ein Fehler aufgetreten."
            )
        end

      _ ->
        send_resp(conn, 400, "Invalid request")
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

  # -----

  defp params(conn) do
    fetch_query_params(conn).query_params
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
