defmodule Harmonex.Pitch do
  @moduledoc """
  Provides functions for working with pitches on the Western dodecaphonic scale.
  """

  defstruct bare_name: nil, alteration: :natural

  @type t :: %{bare_name: bare_name, alteration: alteration} |
             %{bare_name: bare_name}                         |
             atom

  @type       bare_name :: :a  | :b  | :c  | :d  | :e  | :f  | :g
  @indexes_by_bare_name    [a: 0, b: 2, c: 3, d: 5, e: 7, f: 8, g: 10]
  @bare_names @indexes_by_bare_name |> Keyword.keys

  @type alteration :: :natural | :flat | :sharp | :double_flat | :double_sharp
  @alteration_offsets [double_flat: -2,
                       flat:        -1,
                       natural:      0,
                       sharp:        1,
                       double_sharp: 2]
  @alterations @alteration_offsets |> Keyword.keys

  @type quality :: :perfect           |
                   :doubly_diminished |
                   :diminished        |
                   :augmented         |
                   :doubly_augmented  |
                   :minor             |
                   :major

  @type interval :: {quality, 1..7}

  @invalid_name "Invalid pitch name -- must be in #{inspect @bare_names}"
  @invalid_alteration "Invalid pitch alteration -- must be in #{inspect @alterations}"

  @doc """
  Computes a pitch that is the sum of the specified `pitch` and the specified
  `adjustment` in semitones.

  ## Examples

      iex> Harmonex.Pitch.adjust_by_semitones %{bare_name: :a, alteration: :sharp}, 14
      %Harmonex.Pitch{bare_name: :c, alteration: :natural}

      iex> Harmonex.Pitch.adjust_by_semitones :b_flat, -2
      :g_sharp

      iex> Harmonex.Pitch.adjust_by_semitones :c, 0
      :c_natural
  """
  @spec adjust_by_semitones(t, integer) :: t
  def adjust_by_semitones(%{bare_name: _}=pitch, adjustment) do
    with pitch_full_name when is_atom(pitch_full_name) <- full_name(pitch) do
      pitch_full_name |> adjust_by_semitones(adjustment) |> new
    end
  end

  def adjust_by_semitones(pitch, adjustment) do
    with pitch_full_name when is_atom(pitch_full_name) <- full_name(pitch) do
      (index_chromatic(pitch_full_name) + adjustment) |> Integer.mod(12)
                                                      |> full_names_at
                                                      |> Enum.sort_by(&complexity_score/1)
                                                      |> List.first
    end
  end

  @doc """
  Computes the alteration of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.alteration %{bare_name: :a, alteration: :flat}
      :flat

      iex> Harmonex.Pitch.alteration %{bare_name: :a}
      :natural

      iex> Harmonex.Pitch.alteration %{alteration: :flat}
      :flat

      iex> Harmonex.Pitch.alteration :a_flat
      :flat

      iex> Harmonex.Pitch.alteration :a
      :natural
  """
  @spec alteration(%{alteration: alteration} | atom) :: alteration

  for alteration <- @alterations do
    def alteration(%{alteration: unquote(alteration)=alteration}=_pitch) do
      alteration
    end
  end

  def alteration(%{alteration: _}=_pitch), do: {:error, @invalid_alteration}

  for bare_name <- @bare_names do
    for alteration <- @alterations do
      full_name = String.to_atom("#{to_string bare_name}_#{to_string alteration}")
      def alteration(unquote(full_name)=_pitch), do: unquote(alteration)
    end

    def alteration(%{bare_name: unquote(bare_name)}=_pitch), do: :natural

    def alteration(unquote(bare_name)=_pitch), do: :natural
  end

  def alteration(_pitch), do: {:error, @invalid_name}

  @doc """
  Computes the bare name of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.bare_name %{bare_name: :a, alteration: :flat}
      :a

      iex> Harmonex.Pitch.bare_name %{bare_name: :a}
      :a

      iex> Harmonex.Pitch.bare_name :a_flat
      :a

      iex> Harmonex.Pitch.bare_name :a
      :a
  """
  @spec bare_name(t) :: bare_name

  for bare_name <- @bare_names do
    def bare_name(%{bare_name: unquote(bare_name)=bare_name}), do: bare_name

    def bare_name(unquote(bare_name)=bare_name), do: bare_name
  end

  def bare_name(%{bare_name: _}), do: {:error, @invalid_name}

  for bare_name <- @bare_names do
    for alteration <- @alterations do
      full_name = String.to_atom("#{to_string bare_name}_#{to_string alteration}")
      def bare_name(unquote(full_name)=_pitch), do: unquote(bare_name)
    end
  end

  def bare_name(_pitch), do: {:error, @invalid_name}

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

      iex> Harmonex.Pitch.enharmonic? :a_sharp, :a
      false
  """
  @spec enharmonic?(t, t) :: boolean
  def enharmonic?(pitch1, pitch2) do
    with pitch1_full_name when is_atom(pitch1_full_name) <- full_name(pitch1),
         pitch2_full_name when is_atom(pitch2_full_name) <- full_name(pitch2) do
      index_chromatic(pitch1_full_name) == index_chromatic(pitch2_full_name)
    end
  end

  @doc """
  Computes the enharmonic equivalents of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.enharmonics %{bare_name: :g, alteration: :sharp}
      [%Harmonex.Pitch{bare_name: :a, alteration: :flat}]

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
  def enharmonics(%{bare_name: _}=pitch) do
    with pitch_full_name when is_atom(pitch_full_name) <- full_name(pitch) do
      pitch_full_name |> enharmonics |> Enum.map(&(new(&1)))
    end
  end

  def enharmonics(pitch) do
    with pitch_full_name when is_atom(pitch_full_name) <- full_name(pitch) do
      pitch_full_name |> index_chromatic
                      |> full_names_at
                      |> Enum.reject(&(&1 == pitch_full_name))
    end
  end

  @doc """
  Computes the full name of the specified `pitch`.

  ## Examples

      iex> Harmonex.Pitch.full_name %{bare_name: :a, alteration: :flat}
      :a_flat

      iex> Harmonex.Pitch.full_name %{bare_name: :a}
      :a_natural

      iex> Harmonex.Pitch.full_name :a_flat
      :a_flat

      iex> Harmonex.Pitch.full_name :a
      :a_natural
  """
  @spec full_name(t) :: atom

  for bare_name <- @bare_names do
    for alteration <- @alterations do
      full_name = :"#{to_string bare_name}_#{to_string alteration}"
      def full_name(%{bare_name: unquote(bare_name),
                      alteration: unquote(alteration)}=_pitch) do
        unquote full_name
      end

      def full_name(unquote(full_name)=pitch), do: pitch
    end

    def full_name(%{bare_name: unquote(bare_name), alteration: _}=_pitch) do
      {:error, @invalid_alteration}
    end

    def full_name(%{bare_name: unquote(bare_name)}=_pitch) do
      unquote :"#{to_string bare_name}_natural"
    end

    def full_name(unquote(bare_name)=_pitch) do
      unquote(:"#{to_string bare_name}_natural")
    end
  end

  def full_name(_pitch), do: {:error, @invalid_name}

  @doc """
  Computes the quality and number of the interval between the specified
  `low_pitch` and `high_pitch`.

  ## Examples

      iex> Harmonex.Pitch.interval %{bare_name: :a, alteration: :sharp}, %{bare_name: :c}
      {:diminished, 3}

      iex> Harmonex.Pitch.interval :b_flat, :c
      {:major, 2}

      iex> Harmonex.Pitch.interval :d_double_sharp, :a_double_sharp
      {:perfect, 5}

      iex> Harmonex.Pitch.interval :c_flat, :c_natural
      {:augmented, 1}

      iex> Harmonex.Pitch.interval :a_flat, :e_sharp
      {:doubly_augmented, 5}

      iex> Harmonex.Pitch.interval :a_flat, :e_double_sharp
      {:error, "Invalid interval"}
  """
  @spec interval(t, t) :: interval | {:error, binary}
  def interval(low_pitch, high_pitch) do
    with semitones when is_integer(semitones) <- semitones(low_pitch, high_pitch) do
      low_staff_position  = low_pitch  |> bare_name |> staff_position
      high_staff_position = high_pitch |> bare_name |> staff_position
      number = Integer.mod(high_staff_position - low_staff_position, 7) + 1
      semitones_and_number_to_interval semitones, number
    end
  end

  @doc """
  Constructs a new `Harmonex.Pitch` with the specified `name`.

  ## Examples

      iex> Harmonex.Pitch.new %{bare_name: :a, alteration: :flat}
      %Harmonex.Pitch{bare_name: :a, alteration: :flat}

      iex> Harmonex.Pitch.new %{bare_name: :a}
      %Harmonex.Pitch{bare_name: :a, alteration: :natural}

      iex> Harmonex.Pitch.new :a_flat
      %Harmonex.Pitch{bare_name: :a, alteration: :flat}

      iex> Harmonex.Pitch.new :a
      %Harmonex.Pitch{bare_name: :a, alteration: :natural}

      iex> Harmonex.Pitch.new %{bare_name: :h}
      {:error, #{inspect @invalid_name}}

      iex> Harmonex.Pitch.new :h
      {:error, #{inspect @invalid_name}}

      iex> Harmonex.Pitch.new %{bare_name: :a, alteration: :out_of_tune}
      {:error, #{inspect @invalid_alteration}}
  """
  @spec new(atom) :: t | {:error, binary}
  @spec new(bare_name, alteration) :: t | {:error, binary}
  for bare_name <- @bare_names do
    def new(unquote(bare_name)=bare_name), do: new(bare_name, :natural)

    for alteration <- @alterations do
      def new(%{bare_name: unquote(bare_name)=bare_name,
                alteration: unquote(alteration)=alteration}) do
        new bare_name, alteration
      end

      @doc """
      Constructs a new `Harmonex.Pitch` with the specified `bare_name` and
      `alteration`.

      ## Examples

          iex> Harmonex.Pitch.new :a, :flat
          %Harmonex.Pitch{bare_name: :a, alteration: :flat}

          iex> Harmonex.Pitch.new :h, :flat
          {:error, #{inspect @invalid_name}}

          iex> Harmonex.Pitch.new :a, :out_of_tune
          {:error, #{inspect @invalid_alteration}}
      """
      def new(unquote(bare_name)=bare_name, unquote(alteration)=alteration) do
        __MODULE__ |> struct(bare_name: bare_name, alteration: alteration)
      end

      full_name = :"#{to_string bare_name}_#{to_string alteration}"
      def new(unquote(full_name)=_full_name) do
        new unquote(bare_name), unquote(alteration)
      end
    end

    def new(%{bare_name: unquote(bare_name), alteration: _}) do
      {:error, @invalid_alteration}
    end

    def new(%{bare_name: unquote(bare_name)=bare_name}) do
      new bare_name, :natural
    end

    def new(unquote(bare_name)=_bare_name, _invalid_alteration) do
      {:error, @invalid_alteration}
    end
  end

  def new(_invalid_name, _alteration), do: {:error, @invalid_name}

  def new(_invalid_name), do: {:error, @invalid_name}

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
  @spec semitones(t, t) :: 0..11
  def semitones(low_pitch, high_pitch) do
    with low_full when is_atom(low_full)   <- full_name(low_pitch),
         low_index                         <- index_chromatic(low_full),
         high_full when is_atom(high_full) <- full_name(high_pitch),
         high_index                        <- index_chromatic(high_full) do
      (high_index - low_index) |> Integer.mod(12)
    end
  end

  @spec complexity_score(atom) :: 0..2
  for bare_name <- @bare_names do
    defp complexity_score(unquote(bare_name)),               do: 0
    defp complexity_score(unquote(:"#{bare_name}_natural")), do: 0

    defp complexity_score(unquote(:"#{bare_name}_flat")),  do: 1
    defp complexity_score(unquote(:"#{bare_name}_sharp")), do: 1

    defp complexity_score(unquote(:"#{bare_name}_double_flat")),  do: 2
    defp complexity_score(unquote(:"#{bare_name}_double_sharp")), do: 2
  end

  @spec index_chromatic(atom) :: 0..11
  for {bare_name, index} <- @indexes_by_bare_name do
    defp index_chromatic(unquote(bare_name)), do: unquote(index)

    for {alteration, offset} <- @alteration_offsets do
      full_name = :"#{to_string bare_name}_#{to_string alteration}"
      defp index_chromatic(unquote(full_name)) do
        unquote(index + offset) |> Integer.mod(12)
      end
    end
  end

  @spec full_names_at(0..11) :: [atom]
  full_name_lists_by_index = @indexes_by_bare_name |> Enum.reduce(%{},
                                                                  fn({bare_name,
                                                                      index},
                                                                     acc) ->
    @alteration_offsets |> Enum.reduce(acc,
                                       fn({alteration, offset}, inner_acc) ->
      full_name = :"#{to_string bare_name}_#{to_string alteration}"
      altered_index = Integer.mod(index + offset, 12)

      # Tweak the order of enharmonic groups that wrap around G-A.
      insert_at = case full_name do
                    :g_natural      ->  1
                    :g_sharp        -> -1
                    :f_double_sharp -> -1
                    :g_double_sharp -> -1
                    _               ->  0
                  end

      inner_acc |> Map.put_new(altered_index, [])
                |> Map.update!(altered_index,
                               &(&1 |> List.insert_at(insert_at, full_name)))
    end)
  end)
  for {index, full_names} <- full_name_lists_by_index do
    defp full_names_at(unquote(index)), do: unquote(Enum.reverse(full_names))
  end

  @spec semitones_and_number_to_interval(0..11, 1..7) :: interval |
                                                         {:error, binary}
  defp semitones_and_number_to_interval( 0, 1), do: {:perfect,           1}
  defp semitones_and_number_to_interval( 1, 1), do: {:augmented,         1}
  defp semitones_and_number_to_interval( 2, 1), do: {:doubly_augmented,  1}
  defp semitones_and_number_to_interval( 0, 2), do: {:diminished,        2}
  defp semitones_and_number_to_interval( 1, 2), do: {:minor,             2}
  defp semitones_and_number_to_interval( 2, 2), do: {:major,             2}
  defp semitones_and_number_to_interval( 3, 2), do: {:augmented,         2}
  defp semitones_and_number_to_interval( 4, 2), do: {:doubly_augmented,  2}
  defp semitones_and_number_to_interval( 1, 3), do: {:doubly_diminished, 3}
  defp semitones_and_number_to_interval( 2, 3), do: {:diminished,        3}
  defp semitones_and_number_to_interval( 3, 3), do: {:minor,             3}
  defp semitones_and_number_to_interval( 4, 3), do: {:major,             3}
  defp semitones_and_number_to_interval( 5, 3), do: {:augmented,         3}
  defp semitones_and_number_to_interval( 6, 3), do: {:doubly_augmented,  3}
  defp semitones_and_number_to_interval( 3, 4), do: {:doubly_diminished, 4}
  defp semitones_and_number_to_interval( 4, 4), do: {:diminished,        4}
  defp semitones_and_number_to_interval( 5, 4), do: {:perfect,           4}
  defp semitones_and_number_to_interval( 6, 4), do: {:augmented,         4}
  defp semitones_and_number_to_interval( 7, 4), do: {:doubly_augmented,  4}
  defp semitones_and_number_to_interval( 5, 5), do: {:doubly_diminished, 5}
  defp semitones_and_number_to_interval( 6, 5), do: {:diminished,        5}
  defp semitones_and_number_to_interval( 7, 5), do: {:perfect,           5}
  defp semitones_and_number_to_interval( 8, 5), do: {:augmented,         5}
  defp semitones_and_number_to_interval( 9, 5), do: {:doubly_augmented,  5}
  defp semitones_and_number_to_interval( 6, 6), do: {:doubly_diminished, 6}
  defp semitones_and_number_to_interval( 7, 6), do: {:diminished,        6}
  defp semitones_and_number_to_interval( 8, 6), do: {:minor,             6}
  defp semitones_and_number_to_interval( 9, 6), do: {:major,             6}
  defp semitones_and_number_to_interval(10, 6), do: {:augmented,         6}
  defp semitones_and_number_to_interval(11, 6), do: {:doubly_augmented,  6}
  defp semitones_and_number_to_interval( 8, 7), do: {:doubly_diminished, 7}
  defp semitones_and_number_to_interval( 9, 7), do: {:diminished,        7}
  defp semitones_and_number_to_interval(10, 7), do: {:minor,             7}
  defp semitones_and_number_to_interval(11, 7), do: {:major,             7}
  defp semitones_and_number_to_interval( 0, 7), do: {:augmented,         7}
  defp semitones_and_number_to_interval( 1, 7), do: {:doubly_augmented,  7}
  defp semitones_and_number_to_interval( _, _), do: {:error, "Invalid interval"}

  @spec staff_position(bare_name) :: 0..6
  for {bare_name, index} <- Enum.with_index(@bare_names) do
    defp staff_position(unquote(bare_name)), do: unquote(index)
  end
end
