defmodule CoordTest.Point do
  use ExUnit.Case
  import PointHelpers
  use Coord

  doctest Coord.Point.UTM
  doctest Coord.Point.LatLng

  describe "an example point should round trip" do
    test "utm to latlng" do
      start = %UTM{zone: 30, hemi: :n, e: 582_032, n: 5_670_370, datum: Datum.wgs84()}

      start
      |> LatLng.from()
      |> elem(0)
      |> UTM.from()
      |> elem(0)
      |> assert_points_approx_eq(start)
    end

    test "latlng to utm" do
      start = %LatLng{lat: 51.178861, lng: -1.826412}

      start
      |> UTM.from()
      |> elem(0)
      |> LatLng.from()
      |> elem(0)
      |> assert_points_approx_eq(start)
    end
  end

  describe "the default point at stonehenge should convert correctly" do
    test "latlng from utm" do
      {point, _} = LatLng.from(%UTM{})
      assert_points_approx_eq(point, %LatLng{})
    end

    test "utm from latlng" do
      {point, _} = UTM.from(%LatLng{})
      assert_points_approx_eq(point, %UTM{})
    end
  end
end
