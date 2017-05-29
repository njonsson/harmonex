defmodule Harmonex.Pitch do
  @moduledoc """
  Provides functions for working with pitches on the Western dodecaphonic scale.
  """

  alias Harmonex.Interval

  defstruct natural_name: nil, accidental: :natural

  @type t :: %{natural_name: natural_name, accidental: accidental} |
             %{natural_name: natural_name}                         |
             atom

  @type     natural_name :: :a  | :b  | :c  | :d  | :e  | :f  | :g
  @position_by_natural_name [a: 0, b: 2, c: 3, d: 5, e: 7, f: 8, g: 10]
  @natural_names @position_by_natural_name |> Keyword.keys

  @type accidental :: :natural | :flat | :sharp | :double_flat | :double_sharp
  @accidental_by_offset [double_flat: -2,
                         flat:        -1,
                         natural:      0,
                         sharp:        1,
                         double_sharp: 2]
  @accidentals @accidental_by_offset |> Keyword.keys

  @invalid_name "Invalid pitch name -- must be in #{inspect @natural_names}"
  @invalid_accidental "Invalid accidental -- must be in #{inspect @accidentals}"

  @doc """
  Computes a pitch that is the sum of the specified `pitch` and the specified
  `adjustment` in semitones.

  ## Examples

      iex> Harmonex.Pitch.adjust_by_semitones %{natural_name: :a, accidental: :sharp}, 14
      %Harmonex.Pitch{natural_name: :c, accidental: :natural}

      iex> Harmonex.Pitch.adjust_by_semitones :b_flat, -2
      :g_sharp

      iex> Harmonex.Pitch.adjust_by_semitones :c, 0
      :c_natural
  """
  @spec adjust_by_semitones(t, integer) :: t
  def adjust_by_semitones(%{natural_name: _}=pitch, adjustment) do
    with pitch_name when is_atom(pitch_name) <- name(pitch) do
      pitch_name |> adjust_by_semitones(adjustment) |> new
    end
  end

  def adjust_by_semitones(pitch, adjustment) do
    with pitch_name when is_atom(pitch_name) <- name(pitch) do
      (position(pitch_name) + adjustment) |> Integer.mod(12)
                                          |> names_at
                                          |> Enum.sort_by(&complexity_score/1)
                                          |> List.first
    end
  end

  @doc """
  Computes the accidental of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.accidental %{natural_name: :a, accidental: :flat}
      :flat

      iex> Harmonex.Pitch.accidental %{natural_name: :a}
      :natural

      iex> Harmonex.Pitch.accidental %{accidental: :flat}
      :flat

      iex> Harmonex.Pitch.accidental :a_flat
      :flat

      iex> Harmonex.Pitch.accidental :a
      :natural
  """
  @spec accidental(%{accidental: accidental} | atom) :: accidental

  for accidental <- @accidentals do
    def accidental(%{accidental: unquote(accidental)=accidental}=_pitch) do
      accidental
    end
  end

  def accidental(%{accidental: _}=_pitch), do: {:error, @invalid_accidental}

  for natural_name <- @natural_names, accidental <- @accidentals do
    name = String.to_atom("#{to_string natural_name}_#{to_string accidental}")
    def accidental(unquote(name)=_pitch), do: unquote(accidental)
  end

  for natural_name <- @natural_names do
    def accidental(%{natural_name: unquote(natural_name)}=_pitch), do: :natural

    def accidental(unquote(natural_name)=_pitch), do: :natural
  end

  def accidental(_pitch), do: {:error, @invalid_name}

  @doc """
  Computes the bare name of the specified `pitch`.

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
  @spec natural_name(t) :: natural_name

  for natural_name <- @natural_names do
    def natural_name(%{natural_name: unquote(natural_name)=natural_name}=_pitch) do
      natural_name
    end

    def natural_name(unquote(natural_name)=pitch), do: pitch
  end

  def natural_name(%{natural_name: _}=_pitch), do: {:error, @invalid_name}

  for natural_name <- @natural_names, accidental <- @accidentals do
    name = String.to_atom("#{to_string natural_name}_#{to_string accidental}")
    def natural_name(unquote(name)=_pitch), do: unquote(natural_name)
  end

  def natural_name(_pitch), do: {:error, @invalid_name}

  @doc """
  Determines whether the specified `pitch1` and `pitch2` are enharmonically
  equivalent.

  ## Examples

      iex> Harmonex.Pitch.enharmonic? %{natural_name: :g, accidental: :sharp}, :a_flat
      true

      iex> Harmonex.Pitch.enharmonic? :c_flat, %{natural_name: :a, accidental: :double_sharp}
      true

      iex> Harmonex.Pitch.enharmonic? :b_sharp, :d_double_flat
      true

      iex> Harmonex.Pitch.enharmonic? :a_sharp, :a
      false
  """
  @spec enharmonic?(t, t) :: boolean
  def enharmonic?(pitch1, pitch2) do
    with pitch1_name when is_atom(pitch1_name) <- name(pitch1),
         pitch2_name when is_atom(pitch2_name) <- name(pitch2) do
      position(pitch1_name) == position(pitch2_name)
    end
  end

  @doc """
  Computes the enharmonic equivalents of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.enharmonics %{natural_name: :g, accidental: :sharp}
      [%Harmonex.Pitch{natural_name: :a, accidental: :flat}]

      iex> Harmonex.Pitch.enharmonics :f_double_sharp
      [:g_natural, :a_double_flat]

      iex> Harmonex.Pitch.enharmonics :g
      [:f_double_sharp, :a_double_flat]

      iex> Harmonex.Pitch.enharmonics :c_flat
      [:a_double_sharp, :b_natural]

      iex> Harmonex.Pitch.enharmonics :b_sharp
      [:c_natural, :d_double_flat]

      iex> Harmonex.Pitch.enharmonics :a_sharp
      [:b_flat, :c_double_flat]
  """
  @spec enharmonics(t) :: [t]
  def enharmonics(%{natural_name: _}=pitch) do
    with pitch_name when is_atom(pitch_name) <- name(pitch) do
      pitch_name |> enharmonics |> Enum.map(&(new(&1)))
    end
  end

  def enharmonics(pitch) do
    with pitch_name when is_atom(pitch_name) <- name(pitch) do
      pitch_name |> position |> names_at |> Enum.reject(&(&1 == pitch_name))
    end
  end

  @doc """
  Computes the `Harmonex.Interval` between the specified `low_pitch` and
  `high_pitch`. Equivalent to `Harmonex.Interval.from_pitches/2`.

  ## Examples

      iex> Harmonex.Pitch.interval %{natural_name: :a, accidental: :sharp}, %{natural_name: :c}
      %Harmonex.Interval{quality: :diminished, size: 3}

      iex> Harmonex.Pitch.interval :b_flat, :c
      %Harmonex.Interval{quality: :major, size: 2}

      iex> Harmonex.Pitch.interval :d_double_sharp, :a_double_sharp
      %Harmonex.Interval{quality: :perfect, size: 5}

      iex> Harmonex.Pitch.interval :c_flat, :c_natural
      %Harmonex.Interval{quality: :augmented, size: 1}

      iex> Harmonex.Pitch.interval :a_flat, :e_sharp
      %Harmonex.Interval{quality: :doubly_augmented, size: 5}

      iex> Harmonex.Pitch.interval :a_flat, :e_double_sharp
      {:error, "Invalid interval"}
  """
  @spec interval(t, t) :: Interval.t | {:error, binary}
  def interval(low_pitch, high_pitch) do
    Interval.from_pitches(low_pitch, high_pitch)
  end

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
  @spec name(t) :: atom

  for natural_name <- @natural_names, accidental <- @accidentals do
    name = :"#{to_string natural_name}_#{to_string accidental}"
    def name(%{natural_name: unquote(natural_name),
               accidental: unquote(accidental)}=_pitch) do
      unquote name
    end

    def name(unquote(name)=pitch), do: pitch
  end

  for natural_name <- @natural_names do
    def name(%{natural_name: unquote(natural_name), accidental: _}=_pitch) do
      {:error, @invalid_accidental}
    end

    def name(%{natural_name: unquote(natural_name)}=_pitch) do
      unquote :"#{to_string natural_name}_natural"
    end

    def name(unquote(natural_name)=_pitch) do
      unquote(:"#{to_string natural_name}_natural")
    end
  end

  def name(_pitch), do: {:error, @invalid_name}

  @doc """
  Constructs a new `Harmonex.Pitch` with the specified `name`.

  ## Examples

      iex> Harmonex.Pitch.new %{natural_name: :a, accidental: :flat}
      %Harmonex.Pitch{natural_name: :a, accidental: :flat}

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
  """
  @spec new(t) :: t | {:error, binary}
  @spec new(natural_name, accidental) :: t | {:error, binary}

  for natural_name <- @natural_names, accidental <- @accidentals do
    def new(%{natural_name: unquote(natural_name)=natural_name,
              accidental: unquote(accidental)=accidental}=_name) do
      new natural_name, accidental
    end

    @doc """
    Constructs a new `Harmonex.Pitch` with the specified `natural_name` and
    `accidental`.

    ## Examples

        iex> Harmonex.Pitch.new :a, :flat
        %Harmonex.Pitch{natural_name: :a, accidental: :flat}

        iex> Harmonex.Pitch.new :h, :flat
        {:error, #{inspect @invalid_name}}

        iex> Harmonex.Pitch.new :a, :out_of_tune
        {:error, #{inspect @invalid_accidental}}
    """
    def new(unquote(natural_name)=natural_name,
            unquote(accidental)=accidental) do
      __MODULE__ |> struct(natural_name: natural_name, accidental: accidental)
    end

    name = :"#{to_string natural_name}_#{to_string accidental}"
    def new(unquote(name)=_name) do
      new unquote(natural_name), unquote(accidental)
    end
  end

  for natural_name <- @natural_names do
    def new(unquote(natural_name)=name), do: new(name, :natural)

    def new(%{natural_name: unquote(natural_name), accidental: _}=_name) do
      {:error, @invalid_accidental}
    end

    def new(%{natural_name: unquote(natural_name)=natural_name}=_name) do
      new natural_name, :natural
    end

    def new(unquote(natural_name)=_natural_name, _invalid_accidental) do
      {:error, @invalid_accidental}
    end
  end

  def new(_name), do: {:error, @invalid_name}

  def new(_name, _accidental), do: {:error, @invalid_name}

  @doc """
  Computes the distance in half steps between the specified `low_pitch` and
  `high_pitch`.

  ## Examples

      iex> Harmonex.Pitch.semitones %{natural_name: :a, accidental: :flat}, %{natural_name: :c, accidental: :sharp}
      5

      iex> Harmonex.Pitch.semitones :a_flat, :b_flat
      2

      iex> Harmonex.Pitch.semitones :d_double_sharp, :b_double_sharp
      9
  """
  @spec semitones(t, t) :: 0..11
  def semitones(low_pitch, high_pitch) do
    with low_pitch_name when is_atom(low_pitch_name)   <- name(low_pitch),
         low_pitch_position                            <- position(low_pitch_name),
         high_pitch_name when is_atom(high_pitch_name) <- name(high_pitch),
         high_pitch_position                           <- position(high_pitch_name) do
      (high_pitch_position - low_pitch_position) |> Integer.mod(12)
    end
  end

  @spec complexity_score(atom) :: 0..2
  for natural_name <- @natural_names do
    defp complexity_score(unquote(natural_name)),               do: 0
    defp complexity_score(unquote(:"#{natural_name}_natural")), do: 0

    defp complexity_score(unquote(:"#{natural_name}_flat")),  do: 1
    defp complexity_score(unquote(:"#{natural_name}_sharp")), do: 1

    defp complexity_score(unquote(:"#{natural_name}_double_flat")),  do: 2
    defp complexity_score(unquote(:"#{natural_name}_double_sharp")), do: 2
  end

  @spec names_at(0..11) :: [atom]
  name_list_by_position = @position_by_natural_name |> Enum.reduce(%{},
                                                                   fn({natural_name, position},
                                                                      acc) ->
    @accidental_by_offset |> Enum.reduce(acc,
                                         fn({accidental, offset}, inner_acc) ->
      name = :"#{to_string natural_name}_#{to_string accidental}"
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

  @spec position(atom) :: 0..11
  for {natural_name, position} <- @position_by_natural_name do
    defp position(unquote(natural_name)), do: unquote(position)
  end

  for {natural_name, position} <- @position_by_natural_name,
      {accidental, offset} <- @accidental_by_offset do
    name = :"#{to_string natural_name}_#{to_string accidental}"
    defp position(unquote(name)) do
      unquote(position + offset) |> Integer.mod(12)
    end
  end
end
