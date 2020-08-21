defmodule PointHelpers do
  import ExUnit.Assertions
  use Coord

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
