defmodule Harmonex.Pitch do
  @moduledoc """
  Provides functions for working with pitches on the Western dodecaphonic scale.
  """

  defstruct bare_name: nil, alteration: :natural

  @type t :: term

  @type bare_name :: :a | :b | :c | :d | :e | :f | :g
  @bare_names     ~w( a    b    c    d    e    f    g )a

  @type alteration :: :natural | :flat | :sharp | :double_flat | :double_sharp
  @alteration_offsets %{double_flat: -2,
                        flat:        -1,
                        natural:      0,
                        sharp:        1,
                        double_sharp: 2}
  @alterations @alteration_offsets |> Map.keys

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

  @doc """
  Computes the alteration of a pitch.

  ## Examples

      iex> Harmonex.Pitch.alteration %{alteration: :flat}
      :flat

      iex> Harmonex.Pitch.alteration :a
      :natural

      iex> Harmonex.Pitch.alteration :a_flat
      :flat
  """
  @spec alteration(%{alteration: alteration} | atom) :: alteration
  def alteration(%{alteration: alteration}), do: alteration

  for bare_name <- @bare_names do
    def alteration(unquote(bare_name)), do: :natural

    for alteration <- @alterations do
      name = String.to_atom(to_string(bare_name) <> "_" <> to_string(alteration))
      def alteration(unquote(name)), do: unquote(alteration)
    end
  end

  @doc """
  Computes the bare name of a pitch.

  ## Examples

      iex> Harmonex.Pitch.bare_name %{bare_name: :a}
      :a

      iex> Harmonex.Pitch.bare_name :a
      :a

      iex> Harmonex.Pitch.bare_name :a_flat
      :a
  """
  @spec bare_name(%{bare_name: bare_name} | atom) :: bare_name
  def bare_name(%{bare_name: bare_name}), do: bare_name

  for bare_name <- @bare_names do
    def bare_name(unquote(bare_name)), do: unquote(bare_name)

    for alteration <- @alterations do
      name = String.to_atom(to_string(bare_name) <> "_" <> to_string(alteration))
      def bare_name(unquote(name)), do: unquote(bare_name)
    end
  end

  @doc """
  Determines whether two pitches are enharmonically equivalent.

  ## Examples

      iex> Harmonex.Pitch.enharmonic? %{bare_name: :g, alteration: :sharp}, :a_flat
      true

      iex> Harmonex.Pitch.enharmonic? :c_flat, %{bare_name: :a, alteration: :double_sharp}
      true

      iex> Harmonex.Pitch.enharmonic? :b_sharp, :d_double_flat
      true

      iex> Harmonex.Pitch.enharmonic? :a_sharp, :a_natural
      false
  """
  @spec enharmonic?(%{bare_name: bare_name, alteration: alteration} | atom, %{bare_name: bare_name, alteration: alteration} | atom) :: boolean
  def enharmonic?(pitch1, pitch2) do
    index(full_name(pitch1)) == index(full_name(pitch2))
  end

  @doc """
  Computes the full name of a pitch.

  ## Examples

      iex> Harmonex.Pitch.full_name %{bare_name: :a, alteration: :flat}
      :a_flat

      iex> Harmonex.Pitch.full_name :a
      :a

      iex> Harmonex.Pitch.full_name :a_flat
      :a_flat
  """
  @spec full_name(%{bare_name: bare_name, alteration: alteration} | atom) :: atom

  for bare_name <- @bare_names do
    for alteration <- @alterations do
      name = String.to_atom(to_string(bare_name) <> "_" <> to_string(alteration))
      def full_name(%{bare_name: unquote(bare_name),
                      alteration: unquote(alteration)}) do
        unquote(name)
      end

      def full_name(unquote(name)), do: unquote(name)
    end

    def full_name(%{bare_name: unquote(bare_name)}), do: unquote(bare_name)

    def full_name(unquote(bare_name)), do: unquote(bare_name)
  end

  @spec index(atom) :: integer
  defp index(:c), do:  1
  defp index(:d), do:  3
  defp index(:e), do:  5
  defp index(:f), do:  6
  defp index(:g), do:  8
  defp index(:a), do: 10
  defp index(:b), do: 12

  for bare_name <- @bare_names do
    for {alteration, offset} <- @alteration_offsets do
      name = String.to_atom(to_string(bare_name) <> "_" <> to_string(alteration))
      defp index(unquote(name)) do
        (index(unquote(bare_name)) + unquote(offset)) |> Integer.mod(12) |> abs
      end
    end
  end
end
