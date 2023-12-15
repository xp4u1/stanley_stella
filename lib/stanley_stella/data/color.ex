defmodule StanleyStella.Data.Color do
  @derive Jason.Encoder
  defstruct [
    :id,
    :name,
    :image
  ]

  @spec color_by_id(String.t()) :: StanleyStella.Data.Color | nil
  def color_by_id(id) do
    list_colors()
    |> Enum.filter(&(&1.id == id))
    |> Enum.at(0)
  end

  @spec list_colors() :: list(StanleyStella.Data.Color)
  def list_colors do
    HTTPoison.get!("https://www.stanleystella.com/de-de/colour-card").body
    |> Floki.parse_document!()
    |> Floki.find(".colorEntry")
    |> Enum.map(fn element ->
      id =
        element
        |> Floki.attribute("data-colorid")
        |> Enum.at(0)

      %StanleyStella.Data.Color{
        id: id,
        name:
          element
          |> Floki.attribute("data-colorname")
          |> Enum.at(0),
        image: "https://www.stanleystella.com/content/files/images/ColorImages/#{id}.png"
      }
    end)
  end
end
