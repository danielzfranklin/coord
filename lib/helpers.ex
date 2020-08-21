defmodule Coord.Helpers do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import Coord.Helpers, only: [degrees_to_radians: 1, radians_to_degrees: 1]
    end
  end

  def degrees_to_radians(deg), do: deg * (:math.pi() / 180)
  def radians_to_degrees(rad), do: rad * (180 / :math.pi())
end
