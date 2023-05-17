defmodule StanleyStella.Data.Color do
  @derive Jason.Encoder
  defstruct [
    :id,
    :name,
    :image
  ]
end
