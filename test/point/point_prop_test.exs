  use ExUnit.Case, async: true
  use PropCheck, default_opts: [numtests: 1_000]
defmodule CoordTest.Point.PropTest do
  import PointHelpers
  use Coord

  describe "conversion between points should round trip when going" do
    # TODO: get this check to work.
    # The issue is with the utm generator, it generates invalid eastings which
    # reach outside of the zone. These get converted into valid LatLng, which
    # are then converted into a valid UTM which is the correct way of
    # representing the original utm.
    #
    # To fix this we need to better validate eastings in the UTM generator.
    # See the bug report I filed with Geodesy
    # <https://github.com/chrisveness/geodesy/issues/86>

    # property "UTM -> LatLng -> UTM" do
    #   forall start <- utm() do
    #     start
    #     |> LatLng.from()
    #     |> UTM.from()
    #     |> assert_points_approx_eq(start)
    #   end
    # end

    property "LatLng -> UTM -> LatLng" do
      forall start <- latlng_that_can_be_converted_to_utm() do
        start
        |> UTM.from()
        |> LatLng.from()
        |> assert_points_approx_eq(start)
      end
    end
  end

  describe "conversion should give same result as reference for" do
    property "LatLng -> UTM" do
      forall latlng_point <- latlng_that_can_be_converted_to_utm() do
        utm_point = UTM.from(latlng_point)
        reference_utm_point = GeoConvert.latlng_to_utm(latlng_point)
        assert_points_approx_eq(utm_point, reference_utm_point)
      end
    end

    property "UTM -> LatLng" do
      forall utm_point <- utm() do
        latlng_point = LatLng.from(utm_point)
        reference_latlng_point = GeoConvert.utm_to_latlng(utm_point)
        assert_points_approx_eq(latlng_point, reference_latlng_point)
      end
    end
  end

    end
  end
end
