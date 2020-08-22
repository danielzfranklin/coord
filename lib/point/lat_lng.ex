defmodule Coord.Point.LatLng do
  @moduledoc """
  A point represented by a latitude and longitude.

  ```
  iex> use Coord
  iex> _point = LatLng.new(51.178861, -1.826412)
  %Coord.Point.LatLng{lat: 51.178861, lng: -1.826412}
  ```

  By the way, the default values of the struct point to the same point at
  Stonehenge as the default values of the `Coord.Point.LatLng` struct for
  testing purposes.

  ## Concept

  The latitude of a point is defined as the angle between a line from that point
  to the center of the earth and the equatorial plane. Latitude lines run from
  north to south. This library follows the convention that north of the equator
  is positive and south of the equator is negative.

  The longitude of a point is defined as the angle between the meridian that
  passes through that point and the prime meridian. Longitude lines run east to
  west. This library follows the convention that meridians east of the prime
  meridian are positive and meridians west of the prime meridian are negative.

  Great ellipses are the intersection the earth and planes that pass through the
  center of the earth. Meridians are halves of the great ellipses which also
  pass through the poles.

  Source:
  <https://en.wikipedia.org/wiki/Geographic_coordinate_system#Latitude_and_longitude>
  """
  alias Coord.Point.UTM
  use Coord.Helpers

  @typedoc """
  A struct containing a latitude and longitude.

  Keys:

  * `:lat`: The latitude as a float
  * `:lng`: The longitude as a float
  """
  @type t :: %__MODULE__{
          lat: float(),
          lng: float()
        }

  defstruct lat: 51.178861, lng: -1.826412

  @doc """
  Create a new LatLng point for a latitude and longitude
  """
  @spec new(float(), float()) :: t()
  def new(lat, lng), do: %__MODULE__{lat: lat, lng: lng}

  @doc """
  Create a LatLng point from an UTM point.

  Uses [Karney's method](https://arxiv.org/abs/1002.1417). Accurate up to 5nm if the point is within
  3900km of the central meridian.
  """
  @spec from(UTM.t()) :: t()
  def(from(%UTM{zone: z, hemi: h, e: easting, n: northing, datum: datum})) do
    # /**
    #  * Converts UTM zone/easting/northing coordinate to latitude/longitude.
    #  *
    #  * Implements Karney's method, using Krüger series to order n⁶, giving results accurate to 5nm
    #  * for distances up to 3900km from the central meridian.
    #  *
    #  * @param   {Utm} utmCoord - UTM coordinate to be converted to latitude/longitude.
    #  * @returns {LatLon} Latitude/longitude of supplied grid reference.
    #  *
    #  * @example
    #  *   const grid = new Utm(31, 'N', 448251.795, 5411932.678);
    #  *   const latlong = grid.toLatLon(); // 48°51′29.52″N, 002°17′40.20″E
    #  */
    # toLatLon() {
    # const { zone: z, hemisphere: h } = this;

    # const falseEasting = 500e3, falseNorthing = 10000e3;
    falseEasting = 500_000
    falseNorthing = 10_000_000

    # const { a, f } = this.datum.ellipsoid; // WGS-84: a = 6378137, f = 1/298.257223563;
    %{a: a, f: f} = datum.ellipsoid

    # const k0 = 0.9996; // UTM scale on the central meridian
    k0 = 0.9996

    # const x = this.easting - falseEasting;                            // make x ± relative to central meridian
    x = easting - falseEasting

    # const y = h=='S' ? this.northing - falseNorthing : this.northing; // make y ± relative to equator
    y =
      case h do
        :s -> northing - falseNorthing
        :n -> northing
      end

    # // ---- from Karney 2011 Eq 15-22, 36:

    # const e = Math.sqrt(f*(2-f)); // eccentricity
    e = :math.sqrt(f * (2 - f))
    # const n = f / (2 - f);        // 3rd flattening
    n = f / (2 - f)
    # const n2 = n*n, n3 = n*n2, n4 = n*n3, n5 = n*n4, n6 = n*n5;
    n2 = n * n
    n3 = n * n2
    n4 = n * n3
    n5 = n * n4
    n6 = n * n5

    # const A = a/(1+n) * (1 + 1/4*n2 + 1/64*n4 + 1/256*n6); // 2πA is the circumference of a meridian
    a_cap = a / (1 + n) * (1 + 1 / 4 * n2 + 1 / 64 * n4 + 1 / 256 * n6)

    # const η = x / (k0*A);
    # const ξ = y / (k0*A);
    η = x / (k0 * a_cap)
    ξ = y / (k0 * a_cap)

    # const β = [ null, // note β is one-based array (6th order Krüger expressions)
    #     1/2*n - 2/3*n2 + 37/96*n3 -    1/360*n4 -   81/512*n5 +    96199/604800*n6,
    #             1/48*n2 +  1/15*n3 - 437/1440*n4 +   46/105*n5 - 1118711/3870720*n6,
    #                     17/480*n3 -   37/840*n4 - 209/4480*n5 +      5569/90720*n6,
    #                               4397/161280*n4 -   11/504*n5 -  830251/7257600*n6,
    #                                             4583/161280*n5 -  108847/3991680*n6,
    #                                                           20648693/638668800*n6 ];
    β = [
      nil,
      1 / 2 * n - 2 / 3 * n2 + 37 / 96 * n3 - 1 / 360 * n4 - 81 / 512 * n5 + 96199 / 604_800 * n6,
      1 / 48 * n2 + 1 / 15 * n3 - 437 / 1440 * n4 + 46 / 105 * n5 - 1_118_711 / 3_870_720 * n6,
      17 / 480 * n3 - 37 / 840 * n4 - 209 / 4480 * n5 + 5569 / 90720 * n6,
      4397 / 161_280 * n4 - 11 / 504 * n5 - 830_251 / 7_257_600 * n6,
      4583 / 161_280 * n5 - 108_847 / 3_991_680 * n6,
      20_648_693 / 638_668_800 * n6
    ]

    # let ξʹ = ξ;
    # for (let j=1; j<=6; j++) ξʹ -= β[j] * Math.sin(2*j*ξ) * Math.cosh(2*j*η);
    ξʹ =
      Enum.reduce(1..6, ξ, fn j, ξʹ ->
        ξʹ - Enum.at(β, j) * :math.sin(2 * j * ξ) * :math.cosh(2 * j * η)
      end)

    # let ηʹ = η;
    # for (let j=1; j<=6; j++) ηʹ -= β[j] * Math.cos(2*j*ξ) * Math.sinh(2*j*η);
    ηʹ =
      Enum.reduce(1..6, η, fn j, ηʹ ->
        ηʹ - Enum.at(β, j) * :math.cos(2 * j * ξ) * :math.sinh(2 * j * η)
      end)

    # const sinhηʹ = Math.sinh(ηʹ);
    sinhηʹ = :math.sinh(ηʹ)
    # const sinξʹ = Math.sin(ξʹ), cosξʹ = Math.cos(ξʹ);
    sinξʹ = :math.sin(ξʹ)
    cosξʹ = :math.cos(ξʹ)

    # const τʹ = sinξʹ / Math.sqrt(sinhηʹ*sinhηʹ + cosξʹ*cosξʹ);
    τʹ = sinξʹ / :math.sqrt(sinhηʹ * sinhηʹ + cosξʹ * cosξʹ)

    # let δτi = null;
    # let τi = τʹ;
    # do {
    #     const σi = Math.sinh(e*Math.atanh(e*τi/Math.sqrt(1+τi*τi)));
    #     const τiʹ = τi * Math.sqrt(1+σi*σi) - σi * Math.sqrt(1+τi*τi);
    #     δτi = (τʹ - τiʹ)/Math.sqrt(1+τiʹ*τiʹ)
    #         * (1 + (1-e*e)*τi*τi) / ((1-e*e)*Math.sqrt(1+τi*τi));
    #     τi += δτi;
    # } while (Math.abs(δτi) > 1e-12); // using IEEE 754 δτi -> 0 after 2-3 iterations
    # // note relatively large convergence test as δτi toggles on ±1.12e-16 for eg 31 N 400000 5000000
    # const τ = τi;
    converge_τ = fn
      τi, converge_τ ->
        σi = :math.sinh(e * :math.atanh(e * τi / :math.sqrt(1 + τi * τi)))
        τiʹ = τi * :math.sqrt(1 + σi * σi) - σi * :math.sqrt(1 + τi * τi)

        δτi =
          (τʹ - τiʹ) / :math.sqrt(1 + τiʹ * τiʹ) * (1 + (1 - e * e) * τi * τi) /
            ((1 - e * e) * :math.sqrt(1 + τi * τi))

        τi = τi + δτi

        if abs(δτi) > 1.0e-12 do
          converge_τ.(τi, converge_τ)
        else
          τi
        end
    end

    τ = converge_τ.(τʹ, converge_τ)

    # const φ = Math.atan(τ);
    φ = :math.atan(τ)

    # let λ = Math.atan2(sinhηʹ, cosξʹ);
    λ = :math.atan2(sinhηʹ, cosξʹ)

    # // ---- convergence: Karney 2011 Eq 26, 27

    # let p = 1;
    # for (let j=1; j<=6; j++) p -= 2*j*β[j] * Math.cos(2*j*ξ) * Math.cosh(2*j*η);

    # let q = 0;
    # for (let j=1; j<=6; j++) q += 2*j*β[j] * Math.sin(2*j*ξ) * Math.sinh(2*j*η);

    # const γʹ = Math.atan(Math.tan(ξʹ) * Math.tanh(ηʹ));
    # const γʺ = Math.atan2(q, p);

    # // ---- scale: Karney 2011 Eq 28

    # const sinφ = Math.sin(φ);

    # const kʹ = Math.sqrt(1 - e*e*sinφ*sinφ) * Math.sqrt(1 + τ*τ) * Math.sqrt(sinhηʹ*sinhηʹ + cosξʹ*cosξʹ);

    # const kʺ = A / a / Math.sqrt(p*p + q*q);

    # const k = k0 * kʹ * kʺ;

    # // ------------

    # const λ0 = ((z-1)*6 - 180 + 3).toRadians(); // longitude of central meridian
    λ0 = degrees_to_radians((z - 1) * 6 - 180 + 3)
    # λ += λ0; // move λ from zonal to global coordinates
    λ = λ + λ0

    # // round to reasonable precision
    # const lat = Number(φ.toDegrees().toFixed(14)); // nm precision (1nm = 10^-14°)
    lat = radians_to_degrees(φ)

    # const lon = Number(λ.toDegrees().toFixed(14)); // (strictly lat rounding should be φ⋅cosφ!)
    lon = radians_to_degrees(λ)

    # const convergence = Number(γ.toDegrees().toFixed(9));

    # const scale = Number(k.toFixed(12));

    # const latLong = new LatLon_Utm(lat, lon, 0, this.datum);
    # NOTE: the constructor above wraps the lat and lon
    lat = wrap_lat(lat)
    lon = wrap_lng(lon)

    # // ... and add the convergence and scale into the LatLon object ... wonderful JavaScript!
    # latLong.convergence = convergence;
    # latLong.scale = scale;
    # return latLong;
    # }

    %__MODULE__{
      lat: lat,
      lng: lon
    }
  end

  defp wrap_lng(lng) when -180 < lng and lng <= 180 do
    # From <https://cdn.jsdelivr.net/npm/geodesy@2/dms.js>, eventually called by the LatLon_Utm
    # constructor
    #
    # /**
    #  * Constrain degrees to range -180..+180 (e.g. for longitude); -181 => 179, 181 => -179.
    #  *
    #  * @private
    #  * @param {number} degrees
    #  * @returns degrees within range -180..+180.
    #    */
    # static wrap180(degrees) {if (-180<degrees && degrees<=180) return degrees; // avoid rounding
    #   due to arithmetic ops if within range
    lng
  end

  defp wrap_lng(lng) do
    #   return (degrees+540)%360-180; // sawtooth wave p:180, a:±180
    # }
    fmod(lng + 540, 360) - 180
  end

  defp wrap_lat(lat) when -90 <= lat and lat <= 90 do
    # From <https://cdn.jsdelivr.net/npm/geodesy@2/dms.js>, eventually called by the LatLon_Utm
    # constructor
    #
    # /**
    #  * Constrain degrees to range -90..+90 (e.g. for latitude); -91 => -89, 91 => 89.
    #  *
    #  * @private
    #  * @param {number} degrees
    #  * @returns degrees within range -90..+90.
    #  */
    # static wrap90(degrees) {
    #   if (-90<=degrees && degrees<=90) return degrees; // avoid rounding due to arithmetic ops if within range
    lat
  end

  defp wrap_lat(lat) do
    #   return Math.abs((degrees%360 + 270)%360 - 180) - 90; // triangle wave p:360 a:±90 TODO: fix e.g. -315°
    # }
    # TODO: what is the implication of the todo comment above?
    abs(fmod(fmod(lat, 360) + 270, 360) - 180) - 90
  end
end
