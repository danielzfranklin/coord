defmodule Coord.Helpers do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import Coord.Helpers
    end
  end

  def degrees_to_radians(deg), do: deg * (:math.pi() / 180)
  def radians_to_degrees(rad), do: rad * (180 / :math.pi())

  # An approximation of floating-point modulo.
  # From <http://erlang.org/pipermail/erlang-questions/2016-October/090698.html>
  def fmod(a, b), do: a - trunc(a / b) * b
end
