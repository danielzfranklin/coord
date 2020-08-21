defmodule Coord.Point.UTM do
  @moduledoc """
  A point represented by a hemisphere of the globe (north or south), one of sixty numbered 6 degrees
  of longitude wide zones, an easting, and a northing.

    iex> use Coord
    iex> _point = UTM.new(30, :n, 582_032, 5_670_370)
    %Coord.Point.UTM{
      datum: %Coord.Datum{
        ellipsoid: %Coord.Datum.Ellipsoid{
          a: 6378137,
          b: 6356752.314245,
          f: 0.0033528106647474805
        }
      },
      e: 582032,
      hemi: :n,
      n: 5670370,
      zone: 30
    }

  You may see UTM coordinates which specify hemispheres with the letter N or S, or you may see them
  specify an [MGRS](https://en.wikipedia.org/wiki/Military_Grid_Reference_System) band instead. This
  library chooses to specify UTM coordinates with a hemisphere and provide the function
  `Coord.Point.UTM.mgrs_band/1` to compute the band. There are 20 MGRS bands each 8 degrees of
  latitude wide. They are numbered C to X, where C is the southmost and X is the northmost band. I
  and O are skipped to avoid mixing them up with the numbers 1 and 0. Unfortunately, this means it
  can be unclear whether a UTM coordinate uses the letter S to specify band S (which is in the
  northern hemisphere), or the southern hemisphere.

  Zone one starts at the international date line (which passes between Russia and Alaska), and the
  zones count eastward (zone 2 is east of zone 1).

  The easting counts the number of meters a point is east of the false origin, a line 500,000 meters
  west of the central meridian of the zone. A point 100m east of the central meridian of the zone
  would have an easting of `500_000 + 100 = 500_100`, and a point 100m west of the central meridian
  of the zone would have an easting of `500_000 - 100 = 499_900`. The east-west distance between
  those two eastings can be calculated by finding the difference between them (`500_100 - 499_900 =
  200`). An easting is always a six digit number.

  In the northern hemisphere the northing counts the number of meters a point is north of the
  equator, while in the southern hemisphere it counts the number of meters a point is north of a
  line 10,000,000 meters south of the equator. That definition ensures if point A is north of point
  B point A will always have a larger northing. A northing is always a number with between one and
  seven digits.

  A datum represents the approximation used to fit a grid system onto our irregularly shaped world.

  By the way, the default values of the struct point to the same point at Stonehenge as the
  `Coord.Point.LatLng` struct for testing purposes.

  For an more detailed explanation of UTM and examples of how UTM coordinates can be abbreviated see
  <http://geokov.com/education/utm.aspx>. The explanation above is primarily a paraphrase of the
  resources at Geokov.com.
  """
  alias Coord.Datum
  alias Coord.Point.LatLng
  use Coord.Helpers

  @type zone :: 1..60
  @type hemi :: :n | :s

  @type t :: %__MODULE__{
          zone: zone(),
          hemi: hemi(),
          e: float(),
          n: float(),
          datum: Datum.t()
        }

  defstruct zone: 30,
            hemi: :n,
            e: 582_032,
            n: 5_670_370,
            datum: Datum.wgs84()

  # NOTE: Each zone is segmented into 20 latitude bands. Each latitude band is 8 degrees high, and
  # is lettered starting from "C" at 80°S, increasing up the English alphabet until "X", omitting
  # the letters "I" and "O" (because of their similarity to the numerals one and zero). The last
  # latitude band, "X", is extended an extra 4 degrees, so it ends at 84°N latitude, thus covering
  # the northernmost land on Earth.
  #
  # Latitude bands "A" and "B" do exist, as do bands "Y" and "Z". They cover the western and eastern
  # sides of the Antarctic and Arctic regions respectively. A convenient mnemonic to remember is
  # that the letter "N" is the first letter in "northern hemisphere", so any letter coming before
  # "N" in the alphabet is in the southern hemisphere, and any letter "N" or after is in the
  # northern hemisphere.
  #
  # Credit Wikipedia
  # <https://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system#Latitude%20bands>
  @mgrs_bands ~w(C D E F G H J K L M N P Q R S T U V W X X)

  @spec new(zone(), hemi(), float(), float(), Datum.t()) :: %__MODULE__{}
  def new(zone, hemi, e, n, datum \\ Datum.wgs84()) do
    validate_zone!(zone)
    validate_hemisphere!(hemi)
    validate_easting!(e)
    validate_northing!(hemi, n)

    %__MODULE__{
      zone: zone,
      hemi: hemi,
      e: e,
      n: n,
      datum: datum
    }
  end

  defp validate_zone!(zone) do
    # if (!(1<=zone && zone<=60)) throw new RangeError(`invalid UTM zone ‘${zone}’`);
    #     if (zone != parseInt(zone)) throw new RangeError(`invalid UTM zone ‘${zone}’`);
    if not (is_integer(zone) and 1 <= zone and zone <= 60) do
      raise ArgumentError, "Zone does not exist"
    end
  end

  # if (typeof hemisphere != 'string' || !hemisphere.match(/[NS]/i)) throw new RangeError(`invalid UTM hemisphere ‘${hemisphere}’`);
  defp validate_hemisphere!(:n), do: nil
  defp validate_hemisphere!(:s), do: nil
  defp validate_hemisphere!(_), do: raise(ArgumentError, "Hemisphere does not exist")

  # if (!(0<=easting && easting<=1000e3)) throw new RangeError(`invalid UTM easting ‘${easting}’`);
  # The code is incorrect, an easting can never be zero. See <https://www.maptools.com/tutorials/grid_zone_details>
  defp validate_easting!(e) when 0 < e and e <= 1_000_000, do: nil
  defp validate_easting!(_), do: raise(ArgumentError, "Easting out of bounds")

  # if (hemisphere.toUpperCase()=='N' && !(0<=northing && northing<9328094)) throw new RangeError(`invalid UTM northing ‘${northing}’`);
  # if (hemisphere.toUpperCase()=='S' && !(1118414<northing && northing<=10000e3)) throw new RangeError(`invalid UTM northing ‘${northing}’`);
  defp validate_northing!(:n, n) when 0 <= n and n < 9_328_094, do: nil
  defp validate_northing!(:s, n) when 1_118_414 < n and n <= 10_000_000, do: nil

  defp validate_northing!(hemi, _),
    do: raise(ArgumentError, "Northing out of bounds for hemisphere #{hemi}")

  @doc """
  Create an UTM point from a LatLng point.

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

  Returns a `Coord.Point.UTM` and a `Coord.Point.Accuracy` describing the
  accuracy of the representation of the UTM easting and northing as a
  representation of a point in the real world.

  Uses [Karney's method](https://arxiv.org/abs/1002.1417). Accurate up to 5nm if
  the point is within 3900km of the central meridian.
  """
  @spec from(%LatLng{}, %Datum{}) :: %__MODULE__{}
  def from(%LatLng{lng: lng} = latlng, datum \\ Datum.wgs84()) do
    # let zone = zoneOverride || Math.floor((this.lon+180)/6) + 1; // longitudinal zone
    from(latlng, datum, floor((lng + 180) / 6) + 1)
  end

  @doc """
  Create an UTM point from a LatLng point, overriding the correct zone with a different zone.

  The zone specified will be used instead of the zone where the point lies. The exceptions for
  Norway/Svalbard will be applied to the zone specified. This means the code assumes that the zone
  specified was calculated without taking the exceptions into account.

  See `Coord.Point.UTM.from/2` for details.
  """
  @spec from(%LatLng{}, %Datum{}, zone()) :: %__MODULE__{}
  def from(%LatLng{lat: lat, lng: lon}, datum, zone) do
    # /**
    #  * Converts latitude/longitude to UTM coordinate.
    #  *
    #  * Implements Karney’s method, using Krüger series to order n⁶, giving results accurate to 5nm
    #  * for distances up to 3900km from the central meridian.
    #  *
    #  * @param   {number} [zoneOverride] - Use specified zone rather than zone within which point lies;
    #  *          note overriding the UTM zone has the potential to result in negative eastings, and
    #  *          perverse results within Norway/Svalbard exceptions.
    #  * @returns {Utm} UTM coordinate.
    #  * @throws  {TypeError} Latitude outside UTM limits.
    #  *
    #  * @example
    #  *   const latlong = new LatLon(48.8582, 2.2945);
    #  *   const utmCoord = latlong.toUtm(); // 31 N 448252 5411933
    #  */
    # toUtm(zoneOverride=undefined) {

    validate_within_utm_limits!(lat)

    # const falseEasting = 500e3, falseNorthing = 10000e3;
    falseEasting = 500_000
    falseNorthing = 10_000_000

    # let λ0 = ((zone-1)*6 - 180 + 3).toRadians(); // longitude of central meridian
    λ0 = degrees_to_radians((zone - 1) * 6 - 180 + 3)

    # // ---- handle Norway/Svalbard exceptions
    # // grid zones are 8° tall; 0°N is offset 10 into latitude bands array

    # const mgrsLatBands = 'CDEFGHJKLMNPQRSTUVWXX'; // X is repeated for 80-84°N
    # const latBand = mgrsLatBands.charAt(Math.floor(this.lat/8+10));
    latBand = Enum.at(@mgrs_bands, floor(lat / 8 + 10))

    # // adjust zone & central meridian for Norway
    {zone, λ0} =
      cond do
        # if (zone==31 && latBand=='V' && this.lon>= 3) { zone++; λ0 += (6).toRadians(); }
        zone == 31 and latBand == "V" and lon >= 3 -> {zone + 1, λ0 + degrees_to_radians(6)}
        # // adjust zone & central meridian for Svalbard
        # if (zone==32 && latBand=='X' && this.lon<  9) { zone--; λ0 -= (6).toRadians(); }
        zone == 32 and latBand == "X" and lon < 9 -> {zone - 1, λ0 - degrees_to_radians(6)}
        # if (zone==32 && latBand=='X' && this.lon>= 9) { zone++; λ0 += (6).toRadians(); }
        zone == 32 and latBand == 'X' and lon >= 9 -> {zone + 1, λ0 + degrees_to_radians(6)}
        # if (zone==34 && latBand=='X' && this.lon< 21) { zone--; λ0 -= (6).toRadians(); }
        zone == 34 and latBand == 'X' and lon < 21 -> {zone - 1, λ0 - degrees_to_radians(6)}
        # if (zone==34 && latBand=='X' && this.lon>=21) { zone++; λ0 += (6).toRadians(); }
        zone == 34 and latBand == 'X' and lon >= 21 -> {zone + 1, λ0 + degrees_to_radians(6)}
        # if (zone==36 && latBand=='X' && this.lon< 33) { zone--; λ0 -= (6).toRadians(); }
        zone == 36 and latBand == 'X' and lon < 33 -> {zone - 1, λ0 - degrees_to_radians(6)}
        # if (zone==36 && latBand=='X' && this.lon>=33) { zone++; λ0 += (6).toRadians(); }
        zone == 36 and latBand == 'X' and lon >= 33 -> {zone + 1, λ0 + degrees_to_radians(6)}
        true -> {zone, λ0}
      end

    # const φ = this.lat.toRadians();      // latitude ± from equator
    φ = degrees_to_radians(lat)
    # const λ = this.lon.toRadians() - λ0; // longitude ± from central meridian
    λ = degrees_to_radians(lon) - λ0

    # // allow alternative ellipsoid to be specified
    # const ellipsoid = this.datum ? this.datum.ellipsoid : LatLonEllipsoidal.ellipsoids.WGS84;
    # const { a, f } = ellipsoid; // WGS-84: a = 6378137, f = 1/298.257223563;
    %{a: a, f: f} = datum.ellipsoid

    # const k0 = 0.9996; // UTM scale on the central meridian
    k0 = 0.9996

    # // ---- easting, northing: Karney 2011 Eq 7-14, 29, 35:

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

    # const cosλ = Math.cos(λ), sinλ = Math.sin(λ), tanλ = Math.tan(λ);
    cosλ = :math.cos(λ)
    sinλ = :math.sin(λ)
    # tanλ = :math.tan(λ)
    # NOTE: tanλ is unused

    # const τ = Math.tan(φ); // τ ≡ tanφ, τʹ ≡ tanφʹ; prime (ʹ) indicates angles on the conformal sphere
    τ = :math.tan(φ)
    # const σ = Math.sinh(e*Math.atanh(e*τ/Math.sqrt(1+τ*τ)));
    σ = :math.sinh(e * :math.atanh(e * τ / :math.sqrt(1 + τ * τ)))

    # const τʹ = τ*Math.sqrt(1+σ*σ) - σ*Math.sqrt(1+τ*τ);
    τʹ = τ * :math.sqrt(1 + σ * σ) - σ * :math.sqrt(1 + τ * τ)

    # const ξʹ = Math.atan2(τʹ, cosλ);
    ξʹ = :math.atan2(τʹ, cosλ)
    # const ηʹ = Math.asinh(sinλ / Math.sqrt(τʹ*τʹ + cosλ*cosλ));
    ηʹ = :math.asinh(sinλ / :math.sqrt(τʹ * τʹ + cosλ * cosλ))

    # const A = a/(1+n) * (1 + 1/4*n2 + 1/64*n4 + 1/256*n6); // 2πA is the circumference of a meridian
    a_cap = a / (1 + n) * (1 + 1 / 4 * n2 + 1 / 64 * n4 + 1 / 256 * n6)

    # const α = [ null, // note α is one-based array (6th order Krüger expressions)
    #     1/2*n - 2/3*n2 + 5/16*n3 +   41/180*n4 -     127/288*n5 +      7891/37800*n6,
    #           13/48*n2 -  3/5*n3 + 557/1440*n4 +     281/630*n5 - 1983433/1935360*n6,
    #                    61/240*n3 -  103/140*n4 + 15061/26880*n5 +   167603/181440*n6,
    #                            49561/161280*n4 -     179/168*n5 + 6601661/7257600*n6,
    #                                              34729/80640*n5 - 3418889/1995840*n6,
    #                                                           212378941/319334400*n6 ];
    α = [
      nil,
      1 / 2 * n - 2 / 3 * n2 + 5 / 16 * n3 + 41 / 180 * n4 - 127 / 288 * n5 + 7891 / 37800 * n6,
      13 / 48 * n2 - 3 / 5 * n3 + 557 / 1440 * n4 + 281 / 630 * n5 - 1_983_433 / 1_935_360 * n6,
      61 / 240 * n3 - 103 / 140 * n4 + 15061 / 26880 * n5 + 167_603 / 181_440 * n6,
      49561 / 161_280 * n4 - 179 / 168 * n5 + 6_601_661 / 7_257_600 * n6,
      34729 / 80640 * n5 - 3_418_889 / 1_995_840 * n6,
      212_378_941 / 319_334_400 * n6
    ]

    # let ξ = ξʹ;
    # for (let j=1; j<=6; j++) ξ += α[j] * Math.sin(2*j*ξʹ) * Math.cosh(2*j*ηʹ);
    ξ =
      Enum.reduce(1..6, ξʹ, fn j, ξ ->
        ξ + Enum.at(α, j) * :math.sin(2 * j * ξʹ) * :math.cosh(2 * j * ηʹ)
      end)

    # let η = ηʹ;
    # for (let j=1; j<=6; j++) η += α[j] * Math.cos(2*j*ξʹ) * Math.sinh(2*j*ηʹ);
    η =
      Enum.reduce(1..6, ηʹ, fn j, η ->
        η + Enum.at(α, j) * :math.cos(2 * j * ξʹ) * :math.sinh(2 * j * ηʹ)
      end)

    # let x = k0 * A * η;
    x = k0 * a_cap * η
    # let y = k0 * A * ξ;
    y = k0 * a_cap * ξ

    # // ---- convergence: Karney 2011 Eq 23, 24

    # let pʹ = 1;
    # for (let j=1; j<=6; j++) pʹ += 2*j*α[j] * Math.cos(2*j*ξʹ) * Math.cosh(2*j*ηʹ);

    # let qʹ = 0;
    # for (let j=1; j<=6; j++) qʹ += 2*j*α[j] * Math.sin(2*j*ξʹ) * Math.sinh(2*j*ηʹ);

    # const γʹ = Math.atan(τʹ / Math.sqrt(1+τʹ*τʹ)*tanλ);
    # const γʺ = Math.atan2(qʹ, pʹ);
    # const γ = γʹ + γʺ;
    # NOTE: the above lines are unused

    # // ---- scale: Karney 2011 Eq 25

    # const sinφ = Math.sin(φ);

    # const kʹ = Math.sqrt(1 - e*e*sinφ*sinφ) * Math.sqrt(1 + τ*τ) / Math.sqrt(τʹ*τʹ + cosλ*cosλ);

    # const kʺ = A / a * Math.sqrt(pʹ*pʹ + qʹ*qʹ);

    # const k = k0 * kʹ * kʺ;

    # // ------------

    # // shift x/y to false origins
    # x = x + falseEasting;             // make x relative to false easting
    x = x + falseEasting

    # if (y < 0) y = y + falseNorthing; // make y in southern hemisphere relative to false northing
    y = if y < 0, do: y + falseNorthing, else: y

    # // round to reasonable precision
    # x = Number(x.toFixed(6)); // nm precision
    # y = Number(y.toFixed(6)); // nm precision
    # const convergence = Number(γ.toDegrees().toFixed(9));
    # const scale = Number(k.toFixed(12));

    # const h = this.lat>=0 ? 'N' : 'S'; // hemisphere
    h = if lat >= 0, do: :n, else: :s

    # return new Utm(zone, h, x, y, this.datum, convergence, scale, !!zoneOverride);
    # }
    %__MODULE__{
      zone: zone,
      hemi: h,
      e: x,
      n: y,
      datum: datum
    }
  end

  # if (!(-80<=this.lat && this.lat<=84)) throw new RangeError(`latitude ‘${this.lat}’ outside UTM limits`);
  defp validate_within_utm_limits!(lat) when -80 <= lat and lat <= 84, do: nil
  defp validate_within_utm_limits!(_), do: raise(ArgumentError, "Latitude outside UTM limits")

  # def grid_zone(%__MODULE__{} = utm)
end
