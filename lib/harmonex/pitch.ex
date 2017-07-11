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
                 %{natural_name: natural_name}

  @typedoc """
  An atom expression describing a pitch. Can be a `t:natural_name/0`, or a
  `t:natural_name/0` joined by underscore with an `t:accidental/0` (e.g.,
  `:a_flat`).
  """
  @type t_atom :: natural_name | atom

  @typedoc """
  The name of a pitch whose accidental is ♮ (natural).
  """
  @type     natural_name :: :a  | :b  | :c  | :d  | :e  | :f  | :g
  @position_by_natural_name [a: 0, b: 2, c: 3, d: 5, e: 7, f: 8, g: 10]
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

  @invalid_name "Invalid pitch name -- must be in #{inspect @natural_names}"
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
  **DEPRECATED** Computes a pitch that is the sum of the specified `pitch` and
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
  Determines whether the specified `pitch1` and `pitch2` are enharmonically
  equivalent.

  ## Examples

      iex> Harmonex.Pitch.enharmonic? %{natural_name: :a, octave: 4}, %{natural_name: :a, octave: 4}
      true

      iex> Harmonex.Pitch.enharmonic? %{natural_name: :b, accidental: :sharp, octave: 5}, %{natural_name: :c, octave: 6}
      true

      iex> Harmonex.Pitch.enharmonic? %{natural_name: :b, accidental: :sharp, octave: 5}, %{natural_name: :c, octave: 5}
      false

      iex> Harmonex.Pitch.enharmonic? %{natural_name: :g, accidental: :sharp}, :a_flat
      true

      iex> Harmonex.Pitch.enharmonic? :c_flat, %{natural_name: :a, accidental: :double_sharp, octave: 3}
      true

      iex> Harmonex.Pitch.enharmonic? :a_sharp, :a
      false
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
      pitch_name |> position
                 |> names_at
                 |> Enum.reject(&(&1 == pitch_name))
                 |> Enum.map(fn enharmonic_name ->
                      pitch_octave = pitch |> octave
                      if pitch_octave |> is_nil do
                        enharmonic_name |> new
                      else
                        octave = if (natural_name(pitch) < :c) &&
                                    (:c <= natural_name(enharmonic_name)) do
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
      pitch_struct |> enharmonics |> Enum.map(&(name(&1)))
    end
  end

  @doc """
  Computes the interval between the specified `pitch1` and `pitch2`. Equivalent
  to `Harmonex.Interval.from_pitches/2`.

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

  ## Examples

      iex> Harmonex.Pitch.semitones %{natural_name: :a, accidental: :flat, octave: 4}, %{natural_name: :c, accidental: :sharp, octave: 6}
      17

      iex> Harmonex.Pitch.semitones :b_flat, :a_flat
      2

      iex> Harmonex.Pitch.semitones :c, :c
      0
  """
  @spec semitones(t, t) :: non_neg_integer | Harmonex.error
  def semitones(pitch1, pitch2) do
    with pitch1_name when is_atom(pitch1_name) <- name(pitch1),
         pitch2_name when is_atom(pitch2_name) <- name(pitch2),
         pitch1_position                       <- position(pitch1_name),
         pitch1_octave                         <- octave(pitch1),
         pitch2_position                       <- position(pitch2_name),
         pitch2_octave                         <- octave(pitch2),
         positions_diff                        <- pitch1_position -
                                                  pitch2_position,
         positions_diff_inverse                <- 12 - positions_diff,
         semitones_simple                      <- min(abs(positions_diff),
                                                      abs(positions_diff_inverse)) do
      if is_nil(pitch1_octave) || is_nil(pitch2_octave) do
        min semitones_simple, (12 - semitones_simple)
      else
        octaves_diff_naive = pitch2_octave - pitch1_octave
        octaves_diff = if (natural_name(pitch1) < :c) &&
                          (:c <= natural_name(pitch2)) do
                         octaves_diff_naive - 1
                       else
                         octaves_diff_naive
                       end
        (semitones_simple + (octaves_diff * 12)) |> abs
      end
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

      # Tweak the order of enharmonic groups that wrap around G-A.
      insert_at = case name do
                    :g_natural      ->  1
                    :g_sharp        -> -1
                    :f_double_sharp -> -1
                    :g_double_sharp -> -1
                    _               ->  0
                  end

      inner_acc |> Map.put_new(altered_position, [])
                |> Map.update!(altered_position,
                               &(&1 |> List.insert_at(insert_at, name)))
    end)
  end)
  for {position, names} <- name_list_by_position do
    defp names_at(unquote(position)), do: unquote(Enum.reverse(names))
  end

  @spec position(t_atom) :: 0..11
  for {natural_name, position} <- @position_by_natural_name do
    defp position(unquote(natural_name)), do: unquote(position)
  end

  for {natural_name, position} <- @position_by_natural_name,
      {accidental, offset} <- @accidental_by_offset do
    name = :"#{natural_name}_#{accidental}"
    defp position(unquote(name)) do
      unquote(position + offset) |> Integer.mod(12)
    end
  end

  @spec staff_position(natural_name) :: 0..6
  for {pitch_natural_name, index} <- @natural_names |> Stream.with_index do
    defp staff_position(unquote(pitch_natural_name)), do: unquote(index)
  end
end
