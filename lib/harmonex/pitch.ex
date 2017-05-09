defmodule Harmonex.Pitch do
  @moduledoc """
  Provides functions for working with pitches on the Western dodecaphonic scale.
  """

  defstruct bare_name: nil, alteration: :natural

  @type t :: %{bare_name: bare_name, alteration: alteration} |
             %{bare_name: bare_name}                         |
             atom

  @type bare_name :: :a | :b | :c | :d | :e | :f | :g
  @bare_names     ~w( a    b    c    d    e    f    g )a

  @type alteration :: :natural | :flat | :sharp | :double_flat | :double_sharp
  @alteration_offsets %{double_flat: -2,
                        flat:        -1,
                        natural:      0,
                        sharp:        1,
                        double_sharp: 2}
  @alterations @alteration_offsets |> Map.keys

  @type quality :: :perfect | :diminished | :augmented | :minor | :major

  @type interval_diatonic :: {quality, 1..7}

  @type semitones :: 0..11

  @doc """
  Computes the alteration of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.alteration %{alteration: :flat}
      :flat

      iex> Harmonex.Pitch.alteration :a
      :natural

      iex> Harmonex.Pitch.alteration :a_flat
      :flat
  """
  @spec alteration(%{alteration: alteration} | atom) :: alteration
  def alteration(%{alteration: alteration}=_pitch), do: alteration

  for bare_name <- @bare_names do
    def alteration(unquote(bare_name)=_pitch), do: :natural

    for alteration <- @alterations do
      name = String.to_atom(to_string(bare_name) <> "_" <> to_string(alteration))
      def alteration(unquote(name)=_pitch), do: unquote(alteration)
    end
  end

  @doc """
  Computes the bare name of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.bare_name %{bare_name: :a}
      :a

      iex> Harmonex.Pitch.bare_name :a
      :a

      iex> Harmonex.Pitch.bare_name :a_flat
      :a
  """
  @spec bare_name(%{bare_name: bare_name} | atom) :: bare_name
  def bare_name(%{bare_name: bare_name}=_pitch), do: bare_name

  for bare_name <- @bare_names do
    def bare_name(unquote(bare_name)=pitch), do: pitch

    for alteration <- @alterations do
      name = String.to_atom(to_string(bare_name) <> "_" <> to_string(alteration))
      def bare_name(unquote(name)=_pitch), do: unquote(bare_name)
    end
  end

  @doc """
  Determines whether the specified `pitch1` and `pitch2` are enharmonically
  equivalent.

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
  @spec enharmonic?(t, t) :: boolean
  def enharmonic?(pitch1, pitch2) do
    index1 = pitch1 |> full_name |> index_chromatic
    index2 = pitch2 |> full_name |> index_chromatic
    index1 == index2
  end

  @doc """
  Computes the full name of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.full_name %{bare_name: :a, alteration: :flat}
      :a_flat

      iex> Harmonex.Pitch.full_name %{bare_name: :a}
      :a

      iex> Harmonex.Pitch.full_name :a
      :a

      iex> Harmonex.Pitch.full_name :a_flat
      :a_flat
  """
  @spec full_name(t) :: atom

  for bare_name <- @bare_names do
    for alteration <- @alterations do
      name = String.to_atom(to_string(bare_name) <> "_" <> to_string(alteration))
      def full_name(%{bare_name: unquote(bare_name),
                      alteration: unquote(alteration)}=_pitch) do
        unquote(name)
      end

      def full_name(unquote(name)=pitch), do: pitch
    end

    def full_name(%{bare_name: unquote(bare_name)}=_pitch) do
      unquote(bare_name)
    end

    def full_name(unquote(bare_name)=pitch), do: pitch
  end

  @doc """
  Computes the quality and number of the interval between the specified
  `low_pitch` and `high_pitch`.

  ## Examples

      iex> Harmonex.Pitch.interval_diatonic %{bare_name: :a, alteration: :sharp}, %{bare_name: :c}
      {:diminished, 3}

      iex> Harmonex.Pitch.interval_diatonic :b_flat, :c
      {:major, 2}

      iex> Harmonex.Pitch.interval_diatonic :d_double_sharp, :a_double_sharp
      {:perfect, 5}

      iex> Harmonex.Pitch.interval_diatonic :c_flat, :c_natural
      {:augmented, 1}

      iex> Harmonex.Pitch.interval_diatonic :a_flat, :e_sharp
      {:error, "Not a diatonic interval"}
  """
  @spec interval_diatonic(t, t) :: interval_diatonic | {:error, binary}
  def interval_diatonic(low_pitch, high_pitch) do
    semitones = semitones(low_pitch, high_pitch)

    low_staff_position  = low_pitch  |> bare_name |> staff_position
    high_staff_position = high_pitch |> bare_name |> staff_position
    number = Integer.mod(high_staff_position - low_staff_position, 7) + 1

    semitones_and_number_to_interval_diatonic semitones, number
  end

  @doc """
  Constructs a new `Harmonex.Pitch` with the specified `name`.

  ## Examples

      iex> Harmonex.Pitch.new :a
      %Harmonex.Pitch{bare_name: :a, alteration: :natural}

      iex> Harmonex.Pitch.new :a_flat
      %Harmonex.Pitch{bare_name: :a, alteration: :flat}

      iex> Harmonex.Pitch.new :h
      {:error, "Invalid pitch name -- must be in #{inspect @bare_names} with an optional alteration (e.g, :a_flat)"}
  """
  @spec new(atom) :: t | {:error, binary}
  @spec new(bare_name, alteration) :: t | {:error, binary}
  for bare_name <- @bare_names do
    def new(unquote(bare_name)=name), do: new(name, :natural)

    for alteration <- @alterations do
      @doc """
      Constructs a new `Harmonex.Pitch` with the specified `bare_name` and
      `alteration`.

      ## Examples

          iex> Harmonex.Pitch.new :a, :flat
          %Harmonex.Pitch{bare_name: :a, alteration: :flat}

          iex> Harmonex.Pitch.new :a, :out_of_tune
          {:error, "Invalid pitch alteration -- must be in #{inspect @alterations}"}
      """
      def new(unquote(bare_name)=bare_name, unquote(alteration)=alteration) do
        __MODULE__ |> struct(bare_name: bare_name, alteration: alteration)
      end

      full_name = String.to_atom(to_string(bare_name) <>
                                 "_"                  <>
                                 to_string(alteration))
      def new(unquote(full_name)=_full_name) do
        new(unquote(bare_name), unquote(alteration))
      end
    end

    def new(unquote(bare_name)=_bare_name, _invalid_alteration) do
      {:error, "Invalid pitch alteration -- must be in #{inspect @alterations}"}
    end
  end

  def new(_invalid_name) do
    {:error, "Invalid pitch name -- must be in #{inspect @bare_names} with an optional alteration (e.g, :a_flat)"}
  end

  @doc """
  Computes the distance in half steps between the specified `low_pitch` and
  `high_pitch`.

  ## Examples

      iex> Harmonex.Pitch.semitones %{bare_name: :a, alteration: :flat}, %{bare_name: :c, alteration: :sharp}
      5

      iex> Harmonex.Pitch.semitones :a_flat, :b_flat
      2

      iex> Harmonex.Pitch.semitones :d_double_sharp, :b_double_sharp
      9
  """
  @spec semitones(t, t) :: semitones
  def semitones(low_pitch, high_pitch) do
    low_index  = low_pitch  |> full_name |> index_chromatic
    high_index = high_pitch |> full_name |> index_chromatic
    (high_index - low_index) |> Integer.mod(12)
  end

  @spec index_chromatic(atom) :: semitones
  defp index_chromatic(:c), do:  0
  defp index_chromatic(:d), do:  2
  defp index_chromatic(:e), do:  4
  defp index_chromatic(:f), do:  5
  defp index_chromatic(:g), do:  7
  defp index_chromatic(:a), do:  9
  defp index_chromatic(:b), do: 11

  for bare_name <- @bare_names do
    for {alteration, offset} <- @alteration_offsets do
      name = String.to_atom(to_string(bare_name) <> "_" <> to_string(alteration))
      defp index_chromatic(unquote(name)) do
        index_chromatic = index_chromatic(unquote(bare_name))
        (index_chromatic + unquote(offset)) |> Integer.mod(12)
      end
    end
  end

  @spec semitones_and_number_to_interval_diatonic(semitones, 1..7) :: interval_diatonic |
                                                                      {:error, binary}
  defp semitones_and_number_to_interval_diatonic( 0, 1), do: {:perfect,    1}
  defp semitones_and_number_to_interval_diatonic( 1, 1), do: {:augmented,  1}
  defp semitones_and_number_to_interval_diatonic( 0, 2), do: {:diminished, 2}
  defp semitones_and_number_to_interval_diatonic( 1, 2), do: {:minor,      2}
  defp semitones_and_number_to_interval_diatonic( 2, 2), do: {:major,      2}
  defp semitones_and_number_to_interval_diatonic( 3, 2), do: {:augmented,  2}
  defp semitones_and_number_to_interval_diatonic( 2, 3), do: {:diminished, 3}
  defp semitones_and_number_to_interval_diatonic( 3, 3), do: {:minor,      3}
  defp semitones_and_number_to_interval_diatonic( 4, 3), do: {:major,      3}
  defp semitones_and_number_to_interval_diatonic( 5, 3), do: {:augmented,  3}
  defp semitones_and_number_to_interval_diatonic( 4, 4), do: {:diminished, 4}
  defp semitones_and_number_to_interval_diatonic( 5, 4), do: {:perfect,    4}
  defp semitones_and_number_to_interval_diatonic( 6, 4), do: {:augmented,  4}
  defp semitones_and_number_to_interval_diatonic( 6, 5), do: {:diminished, 5}
  defp semitones_and_number_to_interval_diatonic( 7, 5), do: {:perfect,    5}
  defp semitones_and_number_to_interval_diatonic( 8, 5), do: {:augmented,  5}
  defp semitones_and_number_to_interval_diatonic( 7, 6), do: {:diminished, 6}
  defp semitones_and_number_to_interval_diatonic( 8, 6), do: {:minor,      6}
  defp semitones_and_number_to_interval_diatonic( 9, 6), do: {:major,      6}
  defp semitones_and_number_to_interval_diatonic(10, 6), do: {:augmented,  6}
  defp semitones_and_number_to_interval_diatonic( 9, 7), do: {:diminished, 7}
  defp semitones_and_number_to_interval_diatonic(10, 7), do: {:minor,      7}
  defp semitones_and_number_to_interval_diatonic(11, 7), do: {:major,      7}
  defp semitones_and_number_to_interval_diatonic( 0, 7), do: {:augmented,  7}
  defp semitones_and_number_to_interval_diatonic( _, _), do: {:error, "Not a diatonic interval"}

  @spec staff_position(bare_name) :: 0..6
  defp staff_position(:c), do: 0
  defp staff_position(:d), do: 1
  defp staff_position(:e), do: 2
  defp staff_position(:f), do: 3
  defp staff_position(:g), do: 4
  defp staff_position(:a), do: 5
  defp staff_position(:b), do: 6
end
