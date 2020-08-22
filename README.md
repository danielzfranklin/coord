# Coord

This modules aims to be a port of portions of the library
[Geodesy](https://www.movable-type.co.uk/).
 
Right now it provides structs to represent locations with points in UTM and
LatLng format, and functions to convert between the two formats.

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

The only datum provided by default is WGS84, but you can specify a different
datum if it can be represented by a surface defined using the same parameters as
WGS84.

## Testing
The LatLng -> UTM and UTM -> LatLng conversions in this library are tested
against the reference implementation GeographicLib, which Geodesy is also based
on. This means that to run some of the tests you will need to install the
command line utility
[GeoConvert](https://geographiclib.sourceforge.io/html/GeoConvert.1.html). On
Ubuntu you may be able to do this via `apt install geographiclib-tools`. 


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `coord` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:coord, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/coord](https://hexdocs.pm/coord).
