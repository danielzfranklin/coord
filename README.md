# Coord

This modules aims to be a port of portions of the library
[Geodesy](https://www.movable-type.co.uk/).
 
Right now it provides structs to represent locations with points in UTM and
LatLng format, and functions to convert between the two formats.

The module has been tested by comparing the results of converting hundreds of
thousands of points against the reference implementation
[GeoConvert](https://geographiclib.sourceforge.io/html/GeoConvert.1.html). The
conversion functions in GeoConvert were initially written by the author of the
paper which introduced the algorithms used by this module and Geodesy to convert
points between latitude/longitude and UTM. Many thanks to the authors of
[PropCheck](https://hexdocs.pm/propcheck/PropCheck.html) and
[PropEr](http://proper.softlab.ntua.gr/) for making this automated testing
feasible.

## Converting from latitude and longitude to UTM

```elixir
iex> use Coord
iex> LatLng.new(51.178861, -1.826412) |> UTM.from()
%Coord.Point.UTM{
  datum: %Coord.Datum{
    ellipsoid: %Coord.Datum.Ellipsoid{
      a: 6378137,
      b: 6356752.314245,
      f: 0.0033528106647474805
    }
  },
  e: 582031.9577723305,
  hemi: :n,
  n: 5670369.804561083,
  zone: 30
}
```

## Converting from UTM to latitude and longitude

```elixir
iex> use Coord
iex> UTM.new(30, :n, 582031.96, 5670369.80) |> LatLng.from()
%Coord.Point.LatLng{
  lat: 51.17886095867467,
  lng: -1.8264119691783214
}
```

## Datum

The default datum is WGS84, but you can specify a different datum if it can be
represented by a surface defined using the same parameters as WGS84. See `Coord.Datum` and
`Coord.Datum.Ellipsoid`.

## Documentation

Published to [https://hexdocs.pm/coord](https://hexdocs.pm/coord)

## Testing
The LatLng -> UTM and UTM -> LatLng conversions in this library are tested
against the reference implementation GeographicLib, which Geodesy is also based
on. This means that to run some of the tests you will need to install the
command line utility
[GeoConvert](https://geographiclib.sourceforge.io/html/GeoConvert.1.html). On
Ubuntu you may be able to do this via `apt install geographiclib-tools`. 

## Installation

The package can be installed by adding `coord` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:coord, "~> 0.1.0"}
  ]
end
```
