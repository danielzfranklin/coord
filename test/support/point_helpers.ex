defmodule PointHelpers do
  import ExUnit.Assertions
  use Coord

  def assert_points_approx_eq(%LatLng{lat: lat_a, lng: lng_a}, %LatLng{lat: lat_b, lng: lng_b}) do
    assert round(lat_a * 100_000) == round(lat_b * 100_000)
    assert round(lng_a * 100_000) == round(lng_b * 100_000)
  end

  def assert_points_approx_eq(
        %UTM{zone: zone_a, hemi: hemi_a, e: e_a, n: n_a, datum: datum_a},
        %UTM{zone: zone_b, hemi: hemi_b, e: e_b, n: n_b, datum: datum_b}
      ) do
    assert zone_a == zone_b
    assert hemi_a == hemi_b
    assert round(e_a) == round(e_b)
    assert round(n_a) == round(n_b)
    assert datum_a == datum_b
  end
end
