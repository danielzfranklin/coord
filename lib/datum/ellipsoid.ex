defmodule Coord.Datum.Ellipsoid do
  @moduledoc """
  Specified the shape of the surface of a `Coord.Datum`. See the typedoc for
  `t:Coord.Datum.Ellipsoid.t/0` for the specifics of how to create an instance.

  ## Concept

  An ellipsoid is a surface that approximates the shape of the earth. It is
  constructed by flattening a sphere. WGS84 is defined by an ellipsoid with
  specific parameters. Other datum either use different parameters of different
  shapes altogether.

  Source: <https://en.wikipedia.org/wiki/Reference_ellipsoid>
  """

  @typedoc """
  Assumes an oblate sphereoid datum surface like WGS84. Other types of surfaces are not currently
  supported.

  Keys:

  * `:a`: equatorial radius of the sphereoid in meters
  * `:b`: the polar semi-minor axis in meters (equals a * (1 − f))
  * `:f`: flattening (also known as ellipticity or oblateness)

  For example, the function `Coord.Datum.wgs84/0` creates an instance of an `Coord.Datum.Ellipsoid`
  that looks like this:

  ```
  %Coord.Datum.Ellipsoid{a: 6_378_137, b: 6_356_752.314245, f: 1 / 298.257223563}
  ```
  """
  @type t :: %__MODULE__{
          a: integer(),
          b: float(),
          f: float()
        }
  defstruct a: nil, b: nil, f: nil
end
