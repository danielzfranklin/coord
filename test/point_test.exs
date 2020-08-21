defmodule CoordTest.Point do
  use ExUnit.Case
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

  def assert_points_approx_eq(%LatLng{lat: lat_a, lng: lng_a}, %LatLng{lat: lat_b, lng: lng_b}) do
    assert floor(lat_a * 100_000) == floor(lat_b * 100_000)
    assert floor(lng_a * 100_000) == floor(lng_b * 100_000)
  end

  def assert_points_approx_eq(
        %UTM{zone: zone_a, hemi: hemi_a, e: e_a, n: n_a, datum: datum_a},
        %UTM{zone: zone_b, hemi: hemi_b, e: e_b, n: n_b, datum: datum_b}
      ) do
    assert zone_a == zone_b
    assert hemi_a == hemi_b
    assert floor(e_a / 100) == floor(e_b / 100)
    assert floor(n_a / 100) == floor(n_b / 100)
    assert datum_a == datum_b
  end
end
