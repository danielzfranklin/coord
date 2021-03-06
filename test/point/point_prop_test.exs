defmodule CoordTest.Point.PropTest do
  # GeoConvert isn't thread safe, don't run it async
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 10_000]
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

    # @tag :prop
    # property "UTM -> LatLng -> UTM" do
    #   forall start <- utm() do
    #     start
    #     |> LatLng.from()
    #     |> UTM.from()
    #     |> assert_points_approx_eq(start)
    #   end
    # end

    @tag :prop
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
    @tag :prop
    property "LatLng -> UTM" do
      forall latlng_point <- latlng_that_can_be_converted_to_utm() do
        utm_point = UTM.from(latlng_point)
        reference_utm_point = GeoConvert.latlng_to_utm(latlng_point)
        assert_points_approx_eq(utm_point, reference_utm_point)
      end
    end

    @tag :prop
    property "UTM -> LatLng" do
      forall utm_point <- utm() do
        latlng_point = LatLng.from(utm_point)
        reference_latlng_point = GeoConvert.utm_to_latlng(utm_point)
        assert_points_approx_eq(latlng_point, reference_latlng_point)
      end
    end
  end

  @tag :prop
  property "UTM.mgrs_band/1 should give same result as reference" do
    forall point <- utm() do
      band = UTM.mgrs_band(point)
      reference_band = GeoConvert.utm_to_mgrs_band(point)
      assert band == reference_band
    end
  end
end
