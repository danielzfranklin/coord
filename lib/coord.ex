defmodule Coord do
  @doc """
  Alias in useful modules for working with coordinates.


  `use Coord` will alias in `Coord.Point.UTM`, `Coord.Point.LatLng`, and `Coord.Datum`.
  """
  defmacro __using__(_) do
    quote do
      alias Coord.Point.{UTM, LatLng}
      alias Coord.Datum
    end
  end
end
