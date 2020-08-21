defmodule CoordTest.Point do
  use ExUnit.Case, async: true
  import PointHelpers
  use Coord

  doctest Coord.Point.UTM
  doctest Coord.Point.LatLng

  describe "conversion between points should round trip" do
    test "UTM -> LatLng -> UTM" do
      start = %UTM{zone: 30, hemi: :n, e: 582_032, n: 5_670_370, datum: Datum.wgs84()}

      start
      |> LatLng.from()
      |> UTM.from()
      |> assert_points_approx_eq(start)
    end

    test "LatLng -> UTM -> LatLng" do
      start = %LatLng{lat: 51.178861, lng: -1.826412}

      start
      |> UTM.from()
      |> LatLng.from()
      |> assert_points_approx_eq(start)
    end
  end

  describe "the default point at stonehenge should convert correctly" do
    test "latlng from utm" do
      LatLng.from(%UTM{})
      |> assert_points_approx_eq(%LatLng{})
    end

    test "utm from latlng" do
      UTM.from(%LatLng{})
      |> assert_points_approx_eq(%UTM{})
    end
  end
end
