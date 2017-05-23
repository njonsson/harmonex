defmodule Harmonex.Interval do
  @moduledoc """
  Provides functions for working with intervals between pitches on the Western
  dodecaphonic scale.
  """

  alias Harmonex.{Ordinal,Pitch}

  defstruct quality: nil, size: nil

  @type t :: %{quality: quality, size: integer}

  @type quality :: :perfect           |
                   :doubly_diminished |
                   :diminished        |
                   :augmented         |
                   :doubly_augmented  |
                   :minor             |
                   :major
  @intervals_by_semitones_and_number %{{ 0, 1} => {:perfect,           1},
                                       { 1, 1} => {:augmented,         1},
                                       { 2, 1} => {:doubly_augmented,  1},
                                       { 0, 2} => {:diminished,        2},
                                       { 1, 2} => {:minor,             2},
                                       { 2, 2} => {:major,             2},
                                       { 3, 2} => {:augmented,         2},
                                       { 4, 2} => {:doubly_augmented,  2},
                                       { 1, 3} => {:doubly_diminished, 3},
                                       { 2, 3} => {:diminished,        3},
                                       { 3, 3} => {:minor,             3},
                                       { 4, 3} => {:major,             3},
                                       { 5, 3} => {:augmented,         3},
                                       { 6, 3} => {:doubly_augmented,  3},
                                       { 3, 4} => {:doubly_diminished, 4},
                                       { 4, 4} => {:diminished,        4},
                                       { 5, 4} => {:perfect,           4},
                                       { 6, 4} => {:augmented,         4},
                                       { 7, 4} => {:doubly_augmented,  4},
                                       { 5, 5} => {:doubly_diminished, 5},
                                       { 6, 5} => {:diminished,        5},
                                       { 7, 5} => {:perfect,           5},
                                       { 8, 5} => {:augmented,         5},
                                       { 9, 5} => {:doubly_augmented,  5},
                                       { 6, 6} => {:doubly_diminished, 6},
                                       { 7, 6} => {:diminished,        6},
                                       { 8, 6} => {:minor,             6},
                                       { 9, 6} => {:major,             6},
                                       {10, 6} => {:augmented,         6},
                                       {11, 6} => {:doubly_augmented,  6},
                                       { 8, 7} => {:doubly_diminished, 7},
                                       { 9, 7} => {:diminished,        7},
                                       {10, 7} => {:minor,             7},
                                       {11, 7} => {:major,             7},
                                       { 0, 7} => {:augmented,         7},
                                       { 1, 7} => {:doubly_augmented,  7}}
  @intervals @intervals_by_semitones_and_number |> Map.values
  @qualities @intervals |> Stream.map(&(elem(&1, 0))) |> Enum.uniq
  @intervals_invalid @qualities |> Enum.reduce([], fn(quality, acc) ->
                                     acc ++ Enum.filter_map(1..7,
                                                            &(! Enum.member?(@intervals,
                                                                             {quality,
                                                                              &1})),
                                                            &({quality, &1}))
                                   end)

  @pitch_indexes_by_bare_name ~w(a b c d e f g)a |> Stream.with_index |> Map.new

  @doc """
  Computes the `Interval` between the specified `low_pitch` and `high_pitch`.

  ## Examples

      iex> Harmonex.Interval.between_pitches %{bare_name: :a, alteration: :sharp}, %{bare_name: :c}
      %Harmonex.Interval{quality: :diminished, size: 3}

      iex> Harmonex.Interval.between_pitches :b_flat, :c
      %Harmonex.Interval{quality: :major, size: 2}

      iex> Harmonex.Interval.between_pitches :d_double_sharp, :a_double_sharp
      %Harmonex.Interval{quality: :perfect, size: 5}

      iex> Harmonex.Interval.between_pitches :c_flat, :c_natural
      %Harmonex.Interval{quality: :augmented, size: 1}

      iex> Harmonex.Interval.between_pitches :a_flat, :e_sharp
      %Harmonex.Interval{quality: :doubly_augmented, size: 5}

      iex> Harmonex.Interval.between_pitches :a_flat, :e_double_sharp
      {:error, "Invalid interval"}
  """
  @spec between_pitches(Pitch.t, Pitch.t) :: t | {:error, binary}
  def between_pitches(low_pitch, high_pitch) do
    with semitones when is_integer(semitones) <- Pitch.semitones(low_pitch, high_pitch) do
      low_staff_pos  = @pitch_indexes_by_bare_name |> Map.fetch!(Pitch.bare_name(low_pitch))
      high_staff_pos = @pitch_indexes_by_bare_name |> Map.fetch!(Pitch.bare_name(high_pitch))
      number = Integer.mod(high_staff_pos - low_staff_pos, 7) + 1
      case @intervals_by_semitones_and_number |> Map.get({semitones, number},
                                                         {:error, "Invalid interval"}) do
        {:error, _}=error -> error
        {quality, size}   -> new(%{quality: quality, size: size})
      end
    end
  end

  @doc """
  Constructs a new `Harmonex.Interval` with the specified `definition`.

  ## Examples

      iex> Harmonex.Interval.new %{quality: :perfect, size: 1}
      %Harmonex.Interval{quality: :perfect, size: 1}

      iex> Harmonex.Interval.new %{quality: :minor, size: -10}
      %Harmonex.Interval{quality: :minor, size: -10}

      iex> Harmonex.Interval.new %{quality: :perfect, size: 0}
      {:error, "Size cannot be zero"}

      iex> Harmonex.Interval.new %{quality: :minor, size: 1}
      {:error, "Quality of unison cannot be :minor"}

      iex> Harmonex.Interval.new %{quality: :major, size: 8}
      {:error, "Quality of octave cannot be :major"}
  """
  @spec new(t) :: t | {:error, binary}
  @spec new(quality, integer) :: t | {:error, binary}
  for {quality, size} <- @intervals do
    def new(%{quality: unquote(quality), size: unquote(size)}=definition) do
      __MODULE__ |> struct(definition)
    end

    @doc """
    Constructs a new `Harmonex.Interval` with the specified `quality` and `size`.

    ## Examples

        iex> Harmonex.Interval.new :perfect, 1
        %Harmonex.Interval{quality: :perfect, size: 1}

        iex> Harmonex.Interval.new :minor, -10
        %Harmonex.Interval{quality: :minor, size: -10}

        iex> Harmonex.Interval.new :perfect, 0
        {:error, "Size cannot be zero"}

        iex> Harmonex.Interval.new :minor, 1
        {:error, "Quality of unison cannot be :minor"}

        iex> Harmonex.Interval.new :major, 8
        {:error, "Quality of octave cannot be :major"}
    """
    def new(unquote(quality)=quality, unquote(size)=size) do
      new %{quality: quality, size: size}
    end
  end

  for {quality, size} <- @intervals_invalid do
    def new(%{quality: unquote(quality)=quality,
              size: unquote(size)=size}=_definition) do
      error_quality quality, size
    end

    def new(unquote(quality)=quality, unquote(size)=size) do
      %{quality: quality, size: size} |> new
    end
  end

  for quality <- @qualities do
    def new(%{quality: unquote(quality), size: 0}=_definition) do
      {:error, "Size cannot be zero"}
    end

    def new(%{quality: unquote(quality)=quality, size: size}=definition) do
      basic_size = Integer.mod(abs(size) - 1, 7) + 1
      case definition |> Map.put(:size, basic_size) |> new do
        {:error, _} -> error_quality(quality, size)
        _           -> __MODULE__ |> struct(definition)
      end
    end

    def new(unquote(quality)=quality, size) do
      %{quality: quality, size: size} |> new
    end
  end

  @spec error_quality(quality, integer) :: {:error, binary}
  defp error_quality(quality, size) do
    size_ordinal = case Ordinal.to_string(size) do
                     :error  -> "#{to_string size}th"
                     ordinal -> ordinal
                   end
    {:error, "Quality of #{size_ordinal} cannot be #{inspect quality}"}
  end
end
