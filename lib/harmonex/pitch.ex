defmodule Harmonex.Pitch do
  @moduledoc """
  Provides functions for working with pitches on the Western dodecaphonic scale.
  """

  defstruct bare_name: nil, alteration: :natural

  @type t :: term

  @type bare_name :: :a | :b | :c | :d | :e | :f | :g
  @bare_names     ~w( a    b    c    d    e    f    g )a

  @type alteration :: :natural | :flat | :sharp | :double_flat | :double_sharp
  @alterations     ~w( natural    flat    sharp    double_flat    double_sharp )a

  @doc """
  Constructs a new `Harmonex.Pitch`.

  ## Examples

      iex> Harmonex.Pitch.new :a
      %Harmonex.Pitch{bare_name: :a, alteration: :natural}

      iex> Harmonex.Pitch.new :a, :flat
      %Harmonex.Pitch{bare_name: :a, alteration: :flat}

      iex> Harmonex.Pitch.new :a_flat
      %Harmonex.Pitch{bare_name: :a, alteration: :flat}

      iex> Harmonex.Pitch.new :h
      {:error, "Invalid pitch name -- must be in #{inspect @bare_names} with an optional alteration (e.g, :a_flat)"}

      iex> Harmonex.Pitch.new :a, :out_of_tune
      {:error, "Invalid pitch alteration -- must be in #{inspect @alterations}"}
  """
  @spec new(bare_name | atom) :: t | {:error, binary}
  @spec new(bare_name, alteration) :: t | {:error, binary}
  for bare_name <- @bare_names do
    def new(unquote(bare_name)), do: new(unquote(bare_name), :natural)

    for alteration <- @alterations do
      def new(unquote(bare_name), unquote(alteration)) do
        __MODULE__ |> struct(bare_name: unquote(bare_name),
                             alteration: unquote(alteration))
      end

      name = String.to_atom(to_string(bare_name) <> "_" <> to_string(alteration))
      def new(unquote(name)), do: new(unquote(bare_name), unquote(alteration))
    end

    def new(unquote(bare_name), _) do
      {:error, "Invalid pitch alteration -- must be in #{inspect @alterations}"}
    end
  end

  def new(_) do
    {:error, "Invalid pitch name -- must be in #{inspect @bare_names} with an optional alteration (e.g, :a_flat)"}
  end
end
