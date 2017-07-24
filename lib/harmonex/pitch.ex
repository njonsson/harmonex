defmodule Harmonex.Pitch do
  @moduledoc """
  Provides functions for working with pitches on the Western dodecaphonic scale.
  """

  alias Harmonex.Interval

  defstruct natural_name: nil, accidental: :natural, octave: nil
  @typedoc """
  A `Harmonex.Pitch` struct.
  """
  @type pitch :: %Harmonex.Pitch{natural_name: natural_name,
                                 accidental: accidental,
                                 octave: octave}

  @typedoc """
  An expression describing a pitch.
  """
  @type t :: t_map | t_atom

  @typedoc """
  A map expression describing a pitch.
  """
  @type t_map :: %{natural_name: natural_name, accidental: accidental, octave: octave} |
                 %{natural_name: natural_name, accidental: accidental}                 |
                 %{natural_name: natural_name,                         octave: octave} |
                 %{natural_name: natural_name}                                         |
                 pitch

  @typedoc """
  An atom expression describing a pitch. Can be a `t:natural_name/0`, or a
  `t:natural_name/0` joined by underscore with an `t:accidental/0` (e.g.,
  `:a_flat`).
  """
  @type t_atom :: natural_name | atom

  @typedoc """
  The name of a pitch whose accidental is ♮ (natural).
  """
  @type     natural_name :: :c  | :d  | :e  | :f  | :g  | :a  | :b
  @position_by_natural_name [c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11]
  @natural_names @position_by_natural_name |> Keyword.keys
  @natural_names_count @natural_names |> length

  @typedoc """
  The alteration of a pitch from its natural value.
  """
  @type accidental :: :natural | :flat | :sharp | :double_flat | :double_sharp
  @accidental_by_offset [double_flat: -2,
                         flat:        -1,
                         natural:      0,
                         sharp:        1,
                         double_sharp: 2]
  @accidentals @accidental_by_offset |> Keyword.keys

  @typedoc """
  The numeric element of scientific pitch notation.
  """
  @type octave :: integer | nil

  @invalid_name "Invalid pitch name -- must be in #{inspect Enum.sort(@natural_names)}"
  @invalid_accidental_or_octave "Invalid accidental or octave -- must be in #{inspect @accidentals} or be an integer"
  @invalid_accidental "Invalid accidental -- must be in #{inspect @accidentals}"
  @invalid_octave "Invalid octave -- must be an integer"

  @doc """
  Computes the accidental of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.accidental %{natural_name: :a, accidental: :flat, octave: 6}
      :flat

      iex> Harmonex.Pitch.accidental %{natural_name: :a}
      :natural

      iex> Harmonex.Pitch.accidental :a_flat
      :flat

      iex> Harmonex.Pitch.accidental :a
      :natural
  """
  @spec accidental(t) :: accidental | Harmonex.error
  def accidental(pitch) do
    with %{accidental: pitch_accidental} <- pitch |> new do
      pitch_accidental
    end
  end

  @doc """
  **(DEPRECATED)** Computes a pitch that is the sum of the specified `pitch` and
  the specified `adjustment` in semitones.

  ## Examples

      iex> Harmonex.Pitch.adjust_by_semitones %{natural_name: :a, accidental: :sharp}, 14
      %Harmonex.Pitch{natural_name: :c, accidental: :natural}

      iex> Harmonex.Pitch.adjust_by_semitones :b_flat, -2
      :g_sharp

      iex> Harmonex.Pitch.adjust_by_semitones :c, 0
      :c_natural
  """
  @spec adjust_by_semitones(t_map, integer) :: pitch | Harmonex.error
  def adjust_by_semitones(pitch, adjustment) when is_map(pitch) do
    with pitch_name when is_atom(pitch_name) <- name(pitch) do
      pitch_name |> adjust_by_semitones(adjustment) |> new
    end
  end

  @spec adjust_by_semitones(t_atom, integer) :: t_atom | Harmonex.error
  def adjust_by_semitones(pitch, adjustment) do
    with pitch_name when is_atom(pitch_name) <- name(pitch) do
      (position(pitch_name) + adjustment) |> Integer.mod(12)
                                          |> names_at
                                          |> Enum.sort_by(&complexity_score/1)
                                          |> List.first
    end
  end

  @doc """
  Computes the pitch class corresponding to the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.class %{natural_name: :a, accidental: :flat, octave: 6}
      %Harmonex.Pitch{natural_name: :a, accidental: :flat}

      iex> Harmonex.Pitch.class %{natural_name: :a}
      %Harmonex.Pitch{natural_name: :a, accidental: :natural}

      iex> Harmonex.Pitch.class :a_flat
      :a_flat

      iex> Harmonex.Pitch.class :a
      :a_natural
  """
  @spec class(t_map) :: pitch | Harmonex.error
  def class(pitch) when is_map(pitch) do
    with pitch_name when is_atom(pitch_name) <- pitch |> name do
      pitch_name |> new
    end
  end

  @spec class(t_atom) :: t_atom | Harmonex.error
  def class(pitch), do: pitch |> name

  @doc """
  Determines if the specified `pitch` represents a pitch class.

  ## Examples

      iex> Harmonex.Pitch.class? %{natural_name: :a, accidental: :flat, octave: 6}
      false

      iex> Harmonex.Pitch.class? %{natural_name: :a}
      true

      iex> Harmonex.Pitch.class? :a_flat
      true

      iex> Harmonex.Pitch.class? :a
      true
  """
  @spec class?(t) :: boolean | Harmonex.error
  def class?(pitch) do
    case pitch |> octave do
      pitch_octave when is_integer(pitch_octave) -> false
      pitch_octave when is_nil(pitch_octave)     -> true
      other                                      -> other
    end
  end

  @doc """
  Enharmonically compares the specified `pitch1` and `pitch2`.

  It returns:

  * `:eq` if they are identical or enharmonically equivalent
  * `:lt` if `pitch1` is enharmonically lower
  * `:gt` if `pitch1` is enharmonically higher

  If either specified pitch is missing an octave (see `octave/1`) then octaves
  are ignored and the smaller of the two intervals between them is measured.

  ## Examples

      iex> Harmonex.Pitch.compare %{natural_name: :a, octave: 4}, %{natural_name: :a, octave: 4}
      :eq

      iex> Harmonex.Pitch.compare %{natural_name: :b, accidental: :sharp, octave: 5}, %{natural_name: :c, octave: 6}
      :eq

      iex> Harmonex.Pitch.compare %{natural_name: :b, accidental: :sharp, octave: 5}, %{natural_name: :c, octave: 5}
      :gt

      iex> Harmonex.Pitch.compare %{natural_name: :g, accidental: :sharp}, :a_flat
      :eq

      iex> Harmonex.Pitch.compare :c_flat, %{natural_name: :a, accidental: :double_sharp, octave: 2}
      :eq

      iex> Harmonex.Pitch.compare :a, :a_sharp
      :lt
#{ # TODO: Make this pass using `Interval.invert/1`
   # iex> Harmonex.Pitch.compare :a, :d_sharp
   # :lt

}
      iex> Harmonex.Pitch.compare :a, :d_double_sharp
      :gt

      iex> Harmonex.Pitch.compare :a, :a
      :eq
  """
  @spec compare(t, t) :: Harmonex.comparison | Harmonex.error
  def compare(pitch1, pitch2) do
    with pitch1_struct when is_map(pitch1_struct) <- new(pitch1),
         pitch2_struct when is_map(pitch2_struct) <- new(pitch2) do
      {comparison, _} = compare_with_semitones(pitch1, pitch2)
      comparison
    end
  end

  @doc """
  Determines whether the specified `pitch1` and `pitch2` are enharmonically
  equivalent.

  If either specified pitch is missing an octave (see `octave/1`) then octaves
  are ignored.

  ## Examples

      iex> Harmonex.Pitch.enharmonic? %{natural_name: :a, octave: 4}, %{natural_name: :a, octave: 4}
      true

      iex> Harmonex.Pitch.enharmonic? %{natural_name: :b, accidental: :sharp, octave: 5}, %{natural_name: :c, octave: 6}
      true

      iex> Harmonex.Pitch.enharmonic? %{natural_name: :b, accidental: :sharp, octave: 5}, %{natural_name: :c, octave: 5}
      false

      iex> Harmonex.Pitch.enharmonic? %{natural_name: :g, accidental: :sharp}, :a_flat
      true

      iex> Harmonex.Pitch.enharmonic? :c_flat, %{natural_name: :a, accidental: :double_sharp, octave: 2}
      true

      iex> Harmonex.Pitch.enharmonic? :a, :a_sharp
      false

      iex> Harmonex.Pitch.enharmonic? :a, :a
      true
  """
  @spec enharmonic?(t, t) :: boolean | Harmonex.error
  def enharmonic?(pitch1, pitch2) do
    with semitones when is_integer(semitones) <- semitones(pitch1, pitch2) do
      semitones == 0
    end
  end

  @doc """
  Computes the enharmonic equivalents of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.enharmonics %{natural_name: :g, accidental: :sharp, octave: 6}
      [%Harmonex.Pitch{natural_name: :a, accidental: :flat, octave: 6}]

      iex> Harmonex.Pitch.enharmonics %{natural_name: :a, accidental: :double_sharp, octave: 5}
      [%Harmonex.Pitch{natural_name: :b, accidental: :natural, octave: 5}, %Harmonex.Pitch{natural_name: :c, accidental: :flat, octave: 6}]

      iex> Harmonex.Pitch.enharmonics :f_double_sharp
      [:g_natural, :a_double_flat]

      iex> Harmonex.Pitch.enharmonics :c
      [:b_sharp, :d_double_flat]
  """
  @spec enharmonics(t_map) :: [pitch] | Harmonex.error
  def enharmonics(pitch) when is_map(pitch) do
    with pitch_name when is_atom(pitch_name) <- name(pitch) do
      pitch_octave  = octave(pitch)
      pitch_natural_name = natural_name(pitch)
      pitch_name |> position
                 |> Integer.mod(12)
                 |> names_at
                 |> Enum.reject(&(&1 == pitch_name))
                 |> Enum.map(fn enharmonic_name ->
                      if pitch_octave |> is_nil do
                        enharmonic_name |> new
                      else
                        octave = if (pitch_natural_name in [:a, :b]) &&
                                    (natural_name(enharmonic_name) in [:c, :d]) do
                                   pitch_octave + 1
                                 else
                                   pitch_octave
                                 end
                        enharmonic_name |> new(octave)
                      end
                    end)
    end
  end

  @spec enharmonics(t_atom) :: [t_atom] | Harmonex.error
  def enharmonics(pitch) do
    with pitch_struct when is_map(pitch_struct) <- new(pitch) do
      pitch_struct |> enharmonics |> Enum.map(&name/1)
    end
  end

  @doc """
  Computes the interval between the specified `pitch1` and `pitch2`. Equivalent
  to `Harmonex.Interval.from_pitches/2`.

  If either specified pitch is missing an octave (see `octave/1`) then octaves
  are ignored and the smaller of the two intervals between them is computed.

  ## Examples

      iex> Harmonex.Pitch.interval %{natural_name: :a, accidental: :sharp, octave: 4}, %{natural_name: :c, octave: 6}
      %Harmonex.Interval{quality: :diminished, size: 10}

      iex> Harmonex.Pitch.interval :a_sharp, :c
      %Harmonex.Interval{quality: :diminished, size: 3}

      iex> Harmonex.Pitch.interval :d_double_sharp, :a_double_sharp
      %Harmonex.Interval{quality: :perfect, size: 4}

      iex> Harmonex.Pitch.interval :c_flat, :c_natural
      %Harmonex.Interval{quality: :augmented, size: 1}

      iex> Harmonex.Pitch.interval :a_flat, :e_sharp
      %Harmonex.Interval{quality: :doubly_diminished, size: 4}

      iex> Harmonex.Pitch.interval :a_flat, :e_double_sharp
      {:error, "Invalid interval"}
  """
  @spec interval(t, t) :: Interval.interval | Harmonex.error
  defdelegate interval(pitch1, pitch2), to: Interval, as: :from_pitches

  @doc """
  Computes the full name of the specified `pitch`, combining its natural name and
  its accidental.

  ## Examples

      iex> Harmonex.Pitch.name %{natural_name: :a, accidental: :flat}
      :a_flat

      iex> Harmonex.Pitch.name %{natural_name: :a}
      :a_natural

      iex> Harmonex.Pitch.name :a_flat
      :a_flat

      iex> Harmonex.Pitch.name :a
      :a_natural
  """
  @spec name(t) :: t_atom | Harmonex.error
  def name(pitch) do
    with %{natural_name: pitch_natural_name,
           accidental: pitch_accidental} <- new(pitch) do
      :"#{pitch_natural_name}_#{pitch_accidental}"
    end
  end

  @doc """
  Computes the natural name of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.natural_name %{natural_name: :a, accidental: :flat}
      :a

      iex> Harmonex.Pitch.natural_name %{natural_name: :a}
      :a

      iex> Harmonex.Pitch.natural_name :a_flat
      :a

      iex> Harmonex.Pitch.natural_name :a
      :a
  """
  @spec natural_name(t) :: natural_name | Harmonex.error
  def natural_name(pitch) do
    with %{natural_name: pitch_natural_name} <- new(pitch) do
      pitch_natural_name
    end
  end

  @doc """
  Constructs a new pitch with the specified `name_or_definition`.

  ## Examples

      iex> Harmonex.Pitch.new %{natural_name: :a, accidental: :flat, octave: 6}
      %Harmonex.Pitch{natural_name: :a, accidental: :flat, octave: 6}

      iex> Harmonex.Pitch.new %{natural_name: :a, accidental: :flat}
      %Harmonex.Pitch{natural_name: :a, accidental: :flat}

      iex> Harmonex.Pitch.new %{natural_name: :a, octave: 6}
      %Harmonex.Pitch{natural_name: :a, accidental: :natural, octave: 6}

      iex> Harmonex.Pitch.new %{natural_name: :a}
      %Harmonex.Pitch{natural_name: :a, accidental: :natural}

      iex> Harmonex.Pitch.new :a_flat
      %Harmonex.Pitch{natural_name: :a, accidental: :flat}

      iex> Harmonex.Pitch.new :a
      %Harmonex.Pitch{natural_name: :a, accidental: :natural}

      iex> Harmonex.Pitch.new %{natural_name: :h}
      {:error, #{inspect @invalid_name}}

      iex> Harmonex.Pitch.new :h
      {:error, #{inspect @invalid_name}}

      iex> Harmonex.Pitch.new %{natural_name: :a, accidental: :out_of_tune}
      {:error, #{inspect @invalid_accidental}}

      iex> Harmonex.Pitch.new %{natural_name: :a, accidental: :flat, octave: :not_an_octave}
      {:error, #{inspect @invalid_octave}}
  """
  @spec new(t) :: pitch | Harmonex.error
  @spec new(natural_name, accidental, octave) :: pitch | Harmonex.error
  @spec new(natural_name, accidental | octave) :: pitch | Harmonex.error

  for natural_name <- @natural_names, accidental <- @accidentals do
    def new(%{natural_name: unquote(natural_name)=natural_name,
              accidental: unquote(accidental)=accidental,
              octave: octave}=_name_or_definition) when is_integer(octave) or
                                                        is_nil(octave) do
      __MODULE__ |> struct(natural_name: natural_name,
                           accidental: accidental,
                           octave: octave)
    end

    def new(%{natural_name: unquote(natural_name),
              accidental: unquote(accidental),
              octave: _}=_name_or_definition) do
      {:error, @invalid_octave}
    end

    def new(%{natural_name: unquote(natural_name)=natural_name,
              accidental: unquote(accidental)=accidental}=_name_or_definition) do
      __MODULE__ |> struct(natural_name: natural_name, accidental: accidental)
    end

    @doc """
    Constructs a new pitch with the specified `natural_name`, `accidental`, and
    `octave`.

    ## Examples

        iex> Harmonex.Pitch.new :a, :flat, 6
        %Harmonex.Pitch{natural_name: :a, accidental: :flat, octave: 6}

        iex> Harmonex.Pitch.new :h, :flat, 6
        {:error, #{inspect @invalid_name}}

        iex> Harmonex.Pitch.new :a, :out_of_tune, 6
        {:error, #{inspect @invalid_accidental}}

        iex> Harmonex.Pitch.new :a, :flat, :not_an_octave
        {:error, #{inspect @invalid_octave}}
    """
    def new(unquote(natural_name)=natural_name,
            unquote(accidental)=accidental,
            octave) when is_integer(octave) or is_nil(octave) do
      new %{natural_name: natural_name, accidental: accidental, octave: octave}
    end

    def new(unquote(natural_name)=_natural_name,
            unquote(accidental)=_accidental,
            _octave) do
      {:error, @invalid_octave}
    end

    @doc """
    Constructs a new pitch with the specified `name` and `accidental_or_octave`.

    ## Examples

        iex> Harmonex.Pitch.new :a, :flat
        %Harmonex.Pitch{natural_name: :a, accidental: :flat}

        iex> Harmonex.Pitch.new :a_flat, 6
        %Harmonex.Pitch{natural_name: :a, accidental: :flat, octave: 6}

        iex> Harmonex.Pitch.new :h, :flat
        {:error, #{inspect @invalid_name}}

        iex> Harmonex.Pitch.new :a, :out_of_tune
        {:error, #{inspect @invalid_accidental_or_octave}}
    """
    def new(unquote(natural_name)=name,
            unquote(accidental)=accidental_or_octave) do
      new %{natural_name: name, accidental: accidental_or_octave}
    end

    def new(unquote(natural_name)=name,
            accidental_or_octave) when is_integer(accidental_or_octave) or
                                       is_nil(accidental_or_octave) do
      new %{natural_name: name, octave: accidental_or_octave}
    end

    name = :"#{natural_name}_#{accidental}"

    def new(unquote(name)=_name, octave) do
      new %{natural_name: unquote(natural_name),
            accidental: unquote(accidental),
            octave: octave}
    end

    def new(unquote(name)=_name_or_definition) do
      new %{natural_name: unquote(natural_name), accidental: unquote(accidental)}
    end
  end

  for natural_name <- @natural_names do
    def new(unquote(natural_name)=name_or_definition) do
      new %{natural_name: name_or_definition, accidental: :natural}
    end

    def new(%{natural_name: unquote(natural_name),
              accidental: _}=_name_or_definition) do
      {:error, @invalid_accidental}
    end

    def new(%{natural_name: unquote(natural_name)=name, octave: octave}) do
      new %{natural_name: name, accidental: :natural, octave: octave}
    end

    def new(%{natural_name: unquote(natural_name)=name}) do
      new %{natural_name: name, accidental: :natural}
    end

    def new(unquote(natural_name)=_natural_name,
            _accidental,
            octave) when is_integer(octave) or is_nil(octave) do
      {:error, @invalid_accidental}
    end

    def new(unquote(natural_name)=_name, _accidental_or_octave) do
      {:error, @invalid_accidental_or_octave}
    end
  end

  def new(_name_or_definition), do: {:error, @invalid_name}

  def new(_name, _accidental_or_octave), do: {:error, @invalid_name}

  def new(_natural_name, _accidental, _octave), do: {:error, @invalid_name}

  @doc """
  Computes the octave of the specified `pitch`. Pitch values having an octave of
  `nil` represent pitch classes.

  ## Examples

      iex> Harmonex.Pitch.octave %{natural_name: :a, accidental: :flat, octave: 6}
      6

      iex> Harmonex.Pitch.octave %{natural_name: :a}
      nil

      iex> Harmonex.Pitch.octave :a_flat
      nil
  """
  @spec octave(t) :: octave | Harmonex.error
  def octave(pitch) do
    with %{octave: pitch_octave} <- new(pitch) do
      pitch_octave
    end
  end

  @doc """
  Computes the distance in half steps between the specified `pitch1` and
  `pitch2`.

  If either specified pitch is missing an octave (see `octave/1`) then octaves
  are ignored and the smaller of the two intervals between them is measured.

  ## Examples

      iex> Harmonex.Pitch.semitones %{natural_name: :a, accidental: :flat, octave: 4}, %{natural_name: :c, accidental: :sharp, octave: 6}
      17

      iex> Harmonex.Pitch.semitones %{natural_name: :a, octave: 5}, :d_sharp
      6

      iex> Harmonex.Pitch.semitones :a, :d_double_sharp
      5

      iex> Harmonex.Pitch.semitones :c, :c
      0
  """
  @spec semitones(t, t) :: Interval.semitones | Harmonex.error
  def semitones(pitch1, pitch2) do
    with pitch1_struct when is_map(pitch1_struct) <- new(pitch1),
         pitch2_struct when is_map(pitch2_struct) <- new(pitch2) do
      {_, semitones} = compare_with_semitones(pitch1, pitch2)
      semitones
    end
  end

  @doc false
  @spec staff_positions(t, t) :: 0..3
  def staff_positions(pitch1, pitch2) do
    pitch1_position = pitch1 |> natural_name |> staff_position
    pitch2_position = pitch2 |> natural_name |> staff_position
    diff_simple = abs(pitch1_position - pitch2_position) |> Integer.mod(@natural_names_count)
    diff_simple_inverse = @natural_names_count - diff_simple
    min diff_simple, diff_simple_inverse
  end

  @spec compare_with_semitones(t, t) :: {Harmonex.comparison, Interval.semitones} | Harmonex.error
  defp compare_with_semitones(pitch1, pitch2) do
    pitch1_position = position(pitch1)
    pitch2_position = position(pitch2)
    if is_nil(octave(pitch1)) || is_nil(octave(pitch2)) do
      pitch1_position_simple = pitch1_position |> Integer.mod(12)
      pitch2_position_simple = pitch2_position |> Integer.mod(12)
      positions_diff = abs(pitch1_position_simple - pitch2_position_simple)
      semitones = min(positions_diff, 12 - positions_diff)
      comparison = cond do
                     pitch1_position_simple < pitch2_position_simple -> :lt
                     pitch2_position_simple < pitch1_position_simple -> :gt
                     :else                                           -> :eq
                   end
      {comparison, semitones}
    else
      comparison = cond do
                     pitch1_position < pitch2_position -> :lt
                     pitch2_position < pitch1_position -> :gt
                     :else                             -> :eq
                   end
      semitones = abs(pitch1_position - pitch2_position)
      {comparison, semitones}
    end
  end

  @spec complexity_score(t_atom) :: 0..2
  for natural_name <- @natural_names do
    defp complexity_score(unquote(natural_name)),               do: 0
    defp complexity_score(unquote(:"#{natural_name}_natural")), do: 0

    defp complexity_score(unquote(:"#{natural_name}_flat")),  do: 1
    defp complexity_score(unquote(:"#{natural_name}_sharp")), do: 1

    defp complexity_score(unquote(:"#{natural_name}_double_flat")),  do: 2
    defp complexity_score(unquote(:"#{natural_name}_double_sharp")), do: 2
  end

  @spec names_at(0..11) :: [t_atom]
  name_list_by_position = @position_by_natural_name |> Enum.reduce(%{},
                                                                   fn({natural_name, position},
                                                                      acc) ->
    @accidental_by_offset |> Enum.reduce(acc,
                                         fn({accidental, offset}, inner_acc) ->
      name = :"#{natural_name}_#{accidental}"
      altered_position = Integer.mod(position + offset, 12)
      inner_acc |> Map.put_new(altered_position, [])
                |> Map.update!(altered_position, &([name | &1]))
    end)
  end)
  for {position, names} <- name_list_by_position do
    # Tweak the order of enharmonic groups that wrap around G-A.
    sorted_names = names |> Enum.sort(fn(name1, name2) ->
      natural_name1 = name1 |> Atom.to_string |> String.at(0)
      natural_name2 = name2 |> Atom.to_string |> String.at(0)
      cond do
        (natural_name1 == "f" && natural_name2 == "a") ||
        (natural_name1 == "g" && natural_name2 in ~w( a b )) ->
          true
        (natural_name2 == "f" && natural_name1 == "a") ||
        (natural_name2 == "g" && natural_name1 in ~w( a b )) ->
          false
        :else ->
          name1 <= name2
      end
    end)
    defp names_at(unquote(position)), do: unquote(sorted_names)
  end

  @spec position(t_atom) :: 0..11
  for {natural_name, position} <- @position_by_natural_name do
    defp position(unquote(natural_name)), do: unquote(position)
  end

  for {natural_name, position} <- @position_by_natural_name,
      {accidental, offset} <- @accidental_by_offset do
    name = :"#{natural_name}_#{accidental}"
    defp position(unquote(name)), do: unquote(position + offset)
  end

  @spec position(t_map) :: integer | Harmonex.error
  defp position(pitch) do
    pitch_position_simple = pitch |> name |> position
    case octave(pitch) do
      nil          -> pitch_position_simple
      pitch_octave -> pitch_position_simple + (pitch_octave * 12)
    end
  end

  @spec staff_position(natural_name) :: 0..6
  for {pitch_natural_name, index} <- @natural_names |> Stream.with_index do
    defp staff_position(unquote(pitch_natural_name)), do: unquote(index)
  end
end
