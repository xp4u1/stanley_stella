defmodule StanleyStella do
  @moduledoc """
  Reverse engineered API for stanleystella.com.
  """

  alias StanleyStella.Data.Color
  alias StanleyStella.Data.Size
  alias StanleyStella.Data.Stock

  @base_url "https://www.stanleystella.com"
  @stock_url "#{@base_url}/en-gb/product/productstockinfo"

  @spec stock(any) :: {:error, any} | {:ok, %{colors: list, sizes: list, stock: list}}
  def stock(product_id) do
    raw_data =
      HTTPoison.get!("#{@stock_url}?productId=#{product_id}").body
      |> Floki.parse_document!()
      |> Floki.find("input[name='__init_stock_model']")
      |> Floki.attribute("value")

    stock_internal(Jason.decode(raw_data))
  end

  defp stock_internal({:ok, data}) do
    colors =
      data
      |> Map.fetch!("rows")
      |> Enum.map(fn %{"id" => id, "name" => color_name, "img" => image_url} ->
        %Color{
          id: id,
          name: color_name,
          image: @base_url <> image_url
        }
      end)
      |> map_by_id()

    sizes =
      data
      |> Map.fetch!("columns")
      |> Enum.map(fn %{"id" => id, "name" => name} ->
        %Size{
          id: id,
          name:
            name
            |> Floki.parse_fragment!()
            |> Floki.text()
        }
      end)
      |> Enum.sort_by(&size_index/1)
      |> map_by_id()

    stock =
      data
      |> Map.fetch!("variants")
      |> Enum.map(fn variant ->
        %Stock{
          id: Map.fetch!(variant, "variantId"),
          color: Map.fetch!(colors, Map.fetch!(variant, "rowId")),
          size: Map.fetch!(sizes, Map.fetch!(variant, "columnId")),
          # mainWarehouse: Belgien
          # warehouse: [Deutschland, Großbritannien]
          quantity:
            variant
            |> Map.fetch!("warehouses")
            # Erstes Element immer Deutschland
            |> Enum.at(0)
            |> Map.fetch!("inventory")
            |> floor()
        }
      end)

    {:ok,
     %{
       colors:
         colors
         |> Map.values(),
       sizes:
         sizes
         |> Map.values()
         |> Enum.sort_by(&size_index/1),
       stock: stock
     }}
  end

  defp stock_internal({:error, _}) do
    {:error, "Invalid product id"}
  end

  def stock!(product_id) do
    {:ok, data} = stock(product_id)
    data
  end

  def product_name(product_id) do
    text =
      HTTPoison.get!("#{@base_url}/de-de/kollektion/#{product_id}").body
      |> Floki.parse_document!()
      |> Floki.find("h1[itemprop='name']")
      |> Floki.text()

    case text do
      "" ->
        {:error, "Invalid product id"}

      _ ->
        {:ok, text}
    end
  end

  def product_name!(product_id) do
    {:ok, name} = product_name(product_id)
    name
  end

  # -------

  def test_white_shirt do
    stock!("STSU011")
    |> Map.fetch!(:stock)
    |> Enum.filter(&String.starts_with?(&1.id, "C001"))
  end

  def product_table(product_id) do
    case stock(product_id) do
      {:ok, data} ->
        {:ok,
         EEx.eval_file("web/stock.eex",
           assigns: [
             name: product_name!(product_id),
             colors: data.colors,
             sizes: data.sizes,
             stock:
               data.stock
               |> Enum.group_by(& &1.color.id)
               |> Enum.map(fn {key, list} ->
                 %{key => Enum.sort_by(list, &size_index(&1.size))}
               end)
               |> Enum.reduce(&Map.merge/2)
           ]
         )}

      error ->
        error
    end
  end

  # -------

  defp map_by_id(structs) when is_list(structs) do
    Enum.reduce(structs, %{}, fn struct, acc ->
      Map.put(acc, struct.id, struct)
    end)
  end

  @sizes ~w(XXS XS S M L XL XXL XXXL)

  defp size_index(size) do
    Enum.find_index(@sizes, &(&1 == size.name))
  end
end
