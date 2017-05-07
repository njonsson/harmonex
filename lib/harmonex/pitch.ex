defmodule Harmonex.Pitch do
  @moduledoc """
  Provides functions for working with pitches on the Western dodecaphonic scale.
  """

  defstruct name: nil, alteration: :natural

  @type t :: term

  @type name :: :a | :b | :c | :d | :e | :f | :g

  @doc """
  Constructs a new `Harmonex.Pitch`.

  ## Examples

      iex> Harmonex.Pitch.new :a
      %Harmonex.Pitch{name: :a, alteration: :natural}

      iex> Harmonex.Pitch.new :h
      {:error, "Invalid pitch name -- must be an atom between :a and :g"}

      iex> Harmonex.Pitch.new :a, :out_of_tune
      {:error, "Invalid pitch alteration -- must be :natural, :flat, :sharp, :double_flat, or :double_sharp"}
  """
  @spec new(name, PitchAlteration.t) :: t | {:error, binary}
  def new(name, alteration \\ :natural) do
    if name in ~w(a b c d e f g)a do
      if alteration in ~w(natural flat sharp double_flat double_sharp)a do
        __MODULE__ |> struct(name: name, alteration: alteration)
      else
        {:error,
         "Invalid pitch alteration -- must be :natural, :flat, :sharp, :double_flat, or :double_sharp"}
      end
    else
      {:error, "Invalid pitch name -- must be an atom between :a and :g"}
    end
  end
end
