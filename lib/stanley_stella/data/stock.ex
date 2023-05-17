defmodule StanleyStella.Data.Stock do
  @derive {Jason.Encoder, except: [:color, :size]}
  defstruct [
    :id,
    :color,
    :size,
    :quantity
  ]
end
