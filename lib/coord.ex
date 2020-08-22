defmodule Coord do
  @moduledoc """
  This modules aims to be a port of portions of the library
  [Geodesy](https://www.movable-type.co.uk/).

  Right now it provides structs to represent locations with points in UTM and LatLng format, and
  functions to convert between the two formats.

  ## Converting from latitude and longitude to UTM

  ```
  iex> use Coord
  iex> LatLng.new(51.178861, -1.826412) |> UTM.from()
  %Coord.Point.UTM{
   datum: %Coord.Datum{
     ellipsoid: %Coord.Datum.Ellipsoid{
       a: 6378137,
       b: 6356752.314245,
       f: 0.0033528106647474805
     }
   },
   e: 582031.9577723305,
   hemi: :n,
   n: 5670369.804561083,
   zone: 30
  }
  ```

  ## Converting from UTM to latitude and longitude

  ```
  iex> use Coord
  iex> UTM.new(30, :n, 582031.96, 5670369.80) |> LatLng.from()
  %Coord.Point.LatLng{
    lat: 51.17886095867467,
    lng: -1.8264119691783214
  }
  ```

  ## Datum

  The default datum is WGS84, but you can specify a different datum if it can be
  represented by a surface defined using the same parameters as WGS84. See `Coord.Datum` and
  `Coord.Datum.Ellipsoid`.
  """

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
