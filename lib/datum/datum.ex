defmodule Coord.Datum do
  @moduledoc """
  An object with the data necessary to create a point in a datum.

  Most likely you want to use the datum WGS84, which is returned by the function
  `Coord.Datum.wgs84/0`. WGS84 is the latest revision of the international default. Many functions
  in this library use WGS84 by default if you don't specify a datum.

  If you need a different datum you will need to create your own instance of `Coord.Datum`. See the
  documentation for `Coord.Datum.new` for details.
  """
  alias Coord.Datum.Ellipsoid

  @type t :: %__MODULE__{
          ellipsoid: Ellipsoid.t()
        }
  defstruct ellipsoid: nil

  @spec new(Ellipsoid.t()) :: %__MODULE__{}
  @doc """
  Create a Datum object by specifying the parameters of the ellipsoid that makes up its surface.

  See `Coord.Datum.Ellipsoid` for details on the parameter.
  """
  def new(%Ellipsoid{} = ellipsoid) do
    %__MODULE__{ellipsoid: ellipsoid}
  end

  @spec wgs84 :: Coord.Datum.t()
  @doc """
  Create a Datum object with data for the WGS84 datum, the latest revision of the international
  default.
  """
  def wgs84 do
    # Data from <https://www.movable-type.co.uk/scripts/geodesy/docs/latlon-ellipsoidal.js.html>
    %__MODULE__{
      ellipsoid: %Ellipsoid{a: 6_378_137, b: 6_356_752.314245, f: 1 / 298.257223563}
    }
  end
end
