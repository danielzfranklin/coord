defmodule CoordProp.Point do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 1_000]
  import PointHelpers
  use Coord

  describe "conversion should give same result as reference for" do
    property "LatLng -> UTM" do
      forall latlng_point <- latlng_that_can_be_converted_to_utm() do
        utm_point = UTM.from(latlng_point)

        reference_utm_point = GeoConvert.latlng_to_utm(latlng_point)

        assert round(utm_point.e) == reference_utm_point.e
        assert round(utm_point.n) == reference_utm_point.n
        assert utm_point.hemi == reference_utm_point.hemi
        assert utm_point.zone == reference_utm_point.zone
      end
    end

    property "UTM -> LatLng" do
      forall utm_point <- utm() do
        latlng_point = LatLng.from(utm_point)

        reference_latlng_point = GeoConvert.utm_to_latlng(utm_point)

        assert round(latlng_point.lat) == reference_latlng_point.lat
        assert round(latlng_point.lng) == reference_latlng_point.lng
      end
    end
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
      e <- float(),
      n <- float()
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
