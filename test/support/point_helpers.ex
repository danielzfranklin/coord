defmodule PointHelpers do
  import ExUnit.Assertions
  use Coord
  use PropCheck

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

  def latlng_that_can_be_converted_to_utm() do
    let [
      lat <- float(-80.0, 84.0),
      lng <- float(-180.0, 180.0)
    ] do
      LatLng.new(lat, lng)
    end
  end

  def utm() do
    let [
      zone <- integer(1, 60),
      hemi <- oneof([:n, :s]),
      # Many numbers within these bounds are invalid, these are eliminated when
      # they error
      e <- float(100_000.0, 900_000.0),
      n <- float(0.0, 10_000_000.0)
    ] do
      try do
        UTM.new(zone, hemi, e, n)
      rescue
        # if the coordinate is invalid, create a new one
        ArgumentError -> utm()
      end
    end
  end
end
