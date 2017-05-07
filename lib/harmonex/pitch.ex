defmodule Harmonex.Pitch do
  @moduledoc """
  Provides functions for working with pitches on the Western dodecaphonic scale.
  """

  defstruct bare_name: nil, alteration: :natural

  @type t :: term

  @type bare_name :: :a | :b | :c | :d | :e | :f | :g
  @bare_names      ~w(a    b    c    d    e    f    g)a

  @type alteration :: :natural | :flat | :sharp | :double_flat | :double_sharp
  @alteration       ~w(natural    flat    sharp    double_flat    double_sharp)a

  @doc """
  Constructs a new `Harmonex.Pitch`.

  ## Examples

      iex> Harmonex.Pitch.new :a
      %Harmonex.Pitch{bare_name: :a, alteration: :natural}

      iex> Harmonex.Pitch.new :h
      {:error, "Invalid pitch bare name -- must be an atom between :a and :g"}

      iex> Harmonex.Pitch.new :a, :out_of_tune
      {:error, "Invalid pitch alteration -- must be :natural, :flat, :sharp, :double_flat, or :double_sharp"}
  """
  @spec new(bare_name, alteration) :: t | {:error, binary}
  def new(bare_name, alteration \\ :natural) do
    if bare_name in @bare_names do
      if alteration in @alteration do
        __MODULE__ |> struct(bare_name: bare_name, alteration: alteration)
      else
        {:error,
         "Invalid pitch alteration -- must be :natural, :flat, :sharp, :double_flat, or :double_sharp"}
      end
    else
      {:error, "Invalid pitch bare name -- must be an atom between :a and :g"}
    end
  end
end
