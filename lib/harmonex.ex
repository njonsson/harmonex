defmodule Harmonex do
  @moduledoc """
  Provides general-purpose functions.
  """

  @typedoc """
  The result of comparing two values.

  See `Harmonex.Pitch.compare/2`.
  """
  @type comparison :: :lt | :gt | :eq

  @typedoc """
  A failure result.
  """
  @type error :: {:error, binary}
end
