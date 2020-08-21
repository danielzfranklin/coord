defmodule GeoConvert do
  use Coord

  def latlng_to_utm(latlng) do
    {out, 0} =
      System.cmd("GeoConvert", [
        # output UTM
        "-u",
        "--input-string",
        latlng_to_geoconv(latlng)
      ])

    %{"zone" => zone, "hemi" => hemi, "e" => e, "n" => n} =
      Regex.named_captures(
        ~r/^
      (?<zone>\d{1,2})
      (?<hemi>[ns]?)\s
      (?<e>\d+)\s
      (?<n>\d+)\s
      /x,
        out
      )

    zone = String.to_integer(zone)

    hemi =
      case hemi do
        "n" -> :n
        "s" -> :s
        "" -> raise ArgumentError, "Does not support UPS (polar coordinates)"
      end

    e = String.to_integer(e)
    n = String.to_integer(n)

    %UTM{zone: zone, hemi: hemi, e: e, n: n, datum: Datum.wgs84()}
  end

  def utm_to_latlng(utm) do
    {out, 0} =
      System.cmd("GeoConvert", [
        # output LatLng in decimal
        "-g",
        "--input-string",
        utm_to_geoconv(utm)
      ])

    %{"lat" => lat, "lng" => lng} =
      Regex.named_captures(
        ~r/^
      (?<lat>-?[\d.]+)\s
      (?<lng>-?[\d.]+)\s
      /x,
        out
      )

    lat = String.to_float(lat)
    lng = String.to_float(lng)

    %LatLng{lat: lat, lng: lng}
  end

  # By default elixir would output floats in scientific notation, which GeoConvert misparses
  defp latlng_to_geoconv(%LatLng{lat: lat, lng: lng}),
    do: "#{float_to_geoconv(lat)} #{float_to_geoconv(lng)}"

  defp utm_to_geoconv(%UTM{zone: zone, hemi: hemi, e: e, n: n}),
    do: "#{zone}#{hemi_to_geoconv(hemi)} #{float_to_geoconv(e)} #{float_to_geoconv(n)}"

  defp hemi_to_geoconv(:n), do: "n"
  defp hemi_to_geoconv(:s), do: "s"

  defp float_to_geoconv(float),
    do: :erlang.float_to_binary(float, [:compact, {:decimals, 20}])
end
