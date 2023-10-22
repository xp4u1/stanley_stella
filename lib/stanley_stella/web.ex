defmodule StanleyStella.Web do
  @preview_images_eex File.read!("web/preview_images.eex")
  @product_details_eex File.read!("web/product_details.eex")

  def render_preview_images(product_id, color_id) do
    EEx.eval_string(@preview_images_eex,
      assigns: [
        front_url: preview_image(product_id, color_id, :front),
        back_url: preview_image(product_id, color_id, :back),
        time: Time.utc_now()
      ]
    )
  end

  def render_product_details(product_id) do
    case StanleyStella.stock(product_id) do
      {:ok, data} ->
        {:ok,
         EEx.eval_string(@product_details_eex,
           assigns: [
             name: StanleyStella.product_name!(product_id),
             colors: data.colors,
             sizes: data.sizes,
             stock:
               data.stock
               |> Enum.group_by(& &1.color.id)
               |> Enum.map(fn {key, list} ->
                 %{key => Enum.sort_by(list, &StanleyStella.size_index(&1.size))}
               end)
               |> Enum.reduce(&Map.merge/2),
             preview_images_fragment:
               render_preview_images(product_id, Enum.at(data.colors, 0).id)
           ]
         )}

      error ->
        error
    end
  end

  def preview_image(product_id, color_id, :front) do
    preview_image_internal(product_id, color_id, "PFM0")
  end

  def preview_image(product_id, color_id, :back) do
    preview_image_internal(product_id, color_id, "PBM0")
  end

  defp preview_image_internal(product_id, color_id, image_id) do
    "https://res.cloudinary.com/www-stanleystella-com/t_webshop_large/TechnicalNames/#{image_id}_#{product_id}_#{color_id}.jpg"
  end
end
