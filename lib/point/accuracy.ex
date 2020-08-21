defmodule Coord.Point.Accuracy do
  @moduledoc """
  Represents the accuracy of a point via scale and convergence. Produced by some functions that
  output points.
  """

  @type t :: %__MODULE__{scale: float(), convergence: float()}
  defstruct scale: nil, convergence: nil
end
