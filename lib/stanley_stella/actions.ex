defmodule StanleyStella.Actions do
  @doc """
  Downloads preview images for all available colors.
  """
  def download_preview_images(product_id) do
    results =
      StanleyStella.stock!(product_id).colors
      |> Enum.map(& &1.id)
      |> Enum.map(&download_preview_images_internal(product_id, &1))
      |> Enum.reject(&(&1 == :ok))

    case results do
      [] ->
        :ok

      _ ->
        {:error, Enum.uniq(results)}
    end
  end

  defp download_preview_images_internal(product_id, color_id) do
    case {download(
            StanleyStella.Web.preview_image(product_id, color_id, :front),
            "#{product_id}_#{color_id}_Front.jpg"
          ),
          download(
            StanleyStella.Web.preview_image(product_id, color_id, :back),
            "#{product_id}_#{color_id}_Back.jpg"
          )} do
      {:ok, :ok} ->
        :ok

      {result1, result2} ->
        {:error, {result1, result2}}
    end
  end

  @doc """
  Returns the download directory on the current system.
  """
  def download_directory_path do
    File.cwd!() <> "/download"
  end

  defp download(url, filename) do
    File.mkdir_p!(download_directory_path())
    File.write("#{download_directory_path()}/#{filename}", HTTPoison.get!(url).body)
  end
end
