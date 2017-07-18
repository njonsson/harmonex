defmodule Harmonex.Interval do
  @moduledoc """
  Provides functions for working with intervals between pitches on the Western
  dodecaphonic scale.
  """

  alias Harmonex.{Ordinal,Pitch}

  defstruct quality: nil, size: nil
  @typedoc """
  A `Harmonex.Interval` struct.
  """
  @type interval :: %Harmonex.Interval{quality: quality, size: pos_integer}

  @typedoc """
  An expression describing an interval.
  """
  @type t :: %{quality: quality, size: pos_integer} | interval

  @typedoc """
  The qualified variation of an interval’s size.
  """
  @type quality :: :perfect           |
                   :minor             |
                   :major             |
                   :diminished        |
                   :augmented         |
                   :doubly_diminished |
                   :doubly_augmented
  @qualities ~w(perfect
                minor
                major
                diminished
                augmented
                doubly_diminished
                doubly_augmented)a
  @quality_by_semitones_and_size %{{ 0, 1} => :perfect,
                                   { 1, 1} => :augmented,
                                   { 2, 1} => :doubly_augmented,
                                   { 0, 2} => :diminished,
                                   { 1, 2} => :minor,
                                   { 2, 2} => :major,
                                   { 3, 2} => :augmented,
                                   { 4, 2} => :doubly_augmented,
                                   { 1, 3} => :doubly_diminished,
                                   { 2, 3} => :diminished,
                                   { 3, 3} => :minor,
                                   { 4, 3} => :major,
                                   { 5, 3} => :augmented,
                                   { 6, 3} => :doubly_augmented,
                                   { 3, 4} => :doubly_diminished,
                                   { 4, 4} => :diminished,
                                   { 5, 4} => :perfect,
                                   { 6, 4} => :augmented,
                                   { 7, 4} => :doubly_augmented,
                                   { 5, 5} => :doubly_diminished,
                                   { 6, 5} => :diminished,
                                   { 7, 5} => :perfect,
                                   { 8, 5} => :augmented,
                                   { 9, 5} => :doubly_augmented,
                                   { 6, 6} => :doubly_diminished,
                                   { 7, 6} => :diminished,
                                   { 8, 6} => :minor,
                                   { 9, 6} => :major,
                                   {10, 6} => :augmented,
                                   {11, 6} => :doubly_augmented,
                                   { 8, 7} => :doubly_diminished,
                                   { 9, 7} => :diminished,
                                   {10, 7} => :minor,
                                   {11, 7} => :major,
                                   {12, 7} => :augmented,
                                   {13, 7} => :doubly_augmented,
                                   {10, 8} => :doubly_diminished,
                                   {11, 8} => :diminished,
                                   {12, 8} => :perfect,
                                   {13, 8} => :augmented,
                                   {14, 8} => :doubly_augmented,
                                   {11, 9} => :doubly_diminished,
                                   {12, 9} => :diminished,
                                   {13, 9} => :minor,
                                   {14, 9} => :major,
                                   {15, 9} => :augmented,
                                   {16, 9} => :doubly_augmented}
  unless MapSet.new(@qualities) ==
         MapSet.new(Map.values(@quality_by_semitones_and_size)) do
    raise "Qualities mismatch between @qualities and @quality_by_semitones_and_size"
  end

  @intervals @quality_by_semitones_and_size |> Enum.reduce([],
                                                           fn({{_, size},
                                                               quality},
                                                              acc) ->
                                                 [{quality, size} | acc]
                                               end)
  unless MapSet.new(@qualities) == MapSet.new(Keyword.keys(@intervals)) do
    raise "Qualities mismatch between @qualities and @intervals"
  end

  @semitones_by_quality_and_size @quality_by_semitones_and_size |> Enum.reduce(%{},
                                                                               fn({{semitones,
                                                                                    size},
                                                                                   quality},
                                                                                  acc) ->
                                                                     acc |> Map.put({quality,
                                                                                     size},
                                                                                    semitones)
                                                                   end)
  unless MapSet.new(@qualities) ==
         MapSet.new(Enum.map(Map.keys(@semitones_by_quality_and_size),
                             fn {quality, _} -> quality end)) do
    raise "Qualities mismatch between @qualities and @semitones_by_quality_and_size"
  end

  quality_score = fn(quality) ->
    @qualities |> Enum.find_index(&(&1 == quality))
  end
  @quality_list_by_size @intervals |> Enum.reduce(%{},
                                                  fn({quality, size}, acc) ->
                                        acc |> Map.put_new(size, [])
                                            |> Map.update!(size,
                                                           &([quality | &1] |> Enum.sort_by(fn(q) -> quality_score.(q) end)))
                                      end)
  unless MapSet.new(@qualities) ==
         MapSet.new(List.flatten(Map.values(@quality_list_by_size))) do
    raise "Qualities mismatch between @qualities and @quality_list_by_size"
  end

  @intervals_invalid @quality_list_by_size |> Enum.reduce([],
                                                          fn({size, qualities},
                                                             acc) ->
                       for_quality = for q <- (@qualities -- qualities) do
                         {q, size}
                       end
                       acc ++ for_quality
                     end)

  @invalid_quality "Invalid quality -- must be in #{inspect @qualities}"
  @invalid_size "Size must be a positive integer"
  @invalid_interval "Invalid interval"

  @doc """
  Computes the interval between the specified `pitch1` and `pitch2`.

  ## Examples

      iex> Harmonex.Interval.from_pitches %{natural_name: :a, accidental: :sharp, octave: 4}, %{natural_name: :c, octave: 6}
      %Harmonex.Interval{quality: :diminished, size: 10}

      iex> Harmonex.Interval.from_pitches :a_sharp, :c
      %Harmonex.Interval{quality: :diminished, size: 3}

      iex> Harmonex.Interval.from_pitches :d_double_sharp, :a_double_sharp
      %Harmonex.Interval{quality: :perfect, size: 4}

      iex> Harmonex.Interval.from_pitches :c_flat, :c_natural
      %Harmonex.Interval{quality: :augmented, size: 1}

      iex> Harmonex.Interval.from_pitches :a_flat, :e_sharp
      %Harmonex.Interval{quality: :doubly_diminished, size: 4}

      iex> Harmonex.Interval.from_pitches :a_flat, :e_double_sharp
      {:error, #{inspect @invalid_interval}}
  """
  @spec from_pitches(Pitch.t, Pitch.t) :: interval | Harmonex.error
  def from_pitches(pitch1, pitch2) do
    with semitones
           when is_integer(semitones)     <- Pitch.semitones(pitch1, pitch2),
         semitones_simple                 <- semitones |> Integer.mod(12),
         interval_size_simple             <- 1 +
                                             Pitch.staff_positions(pitch1,
                                                                   pitch2),
         interval_quality
           when is_atom(interval_quality) <- Map.get(@quality_by_semitones_and_size,
                                                     {semitones_simple,
                                                      interval_size_simple},
                                                     {:error,
                                                     @invalid_interval}),
         interval_size                    <- interval_size_simple +
                                             (7 * div(semitones, 12)) do
      new %{quality: interval_quality, size: interval_size}
    end
  end

  @doc """
  Constructs a new interval with the specified `definition`.

  ## Examples

      iex> Harmonex.Interval.new %{quality: :perfect, size: 1}
      %Harmonex.Interval{quality: :perfect, size: 1}

      iex> Harmonex.Interval.new %{quality: :augmented, size: 17}
      %Harmonex.Interval{quality: :augmented, size: 17}

      iex> Harmonex.Interval.new %{quality: :minor, size: 1}
      {:error, "Quality of unison must be in [:perfect, :augmented, :doubly_augmented]"}

      iex> Harmonex.Interval.new %{quality: :major, size: 8}
      {:error, "Quality of octave must be in [:perfect, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}

      iex> Harmonex.Interval.new %{quality: :perfect, size: 0}
      {:error, #{inspect @invalid_size}}

      iex> Harmonex.Interval.new %{quality: :minor, size: -3}
      {:error, #{inspect @invalid_size}}

      iex> Harmonex.Interval.new %{quality: :minor}
      {:error, #{inspect @invalid_size}}
  """
  @spec new(t) :: interval | Harmonex.error
  @spec new(quality, pos_integer) :: interval | Harmonex.error
  for {quality, size} <- @intervals do
    def new(%{quality: unquote(quality), size: unquote(size)}=definition) do
      __MODULE__ |> struct(Map.delete(definition, :__struct__))
    end

    @doc """
    Constructs a new interval with the specified `quality` and `size`.

    ## Examples

        iex> Harmonex.Interval.new :perfect, 1
        %Harmonex.Interval{quality: :perfect, size: 1}

        iex> Harmonex.Interval.new :augmented, 17
        %Harmonex.Interval{quality: :augmented, size: 17}

        iex> Harmonex.Interval.new :minor, 1
        {:error, "Quality of unison must be in [:perfect, :augmented, :doubly_augmented]"}

        iex> Harmonex.Interval.new :major, 8
        {:error, "Quality of octave must be in [:perfect, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}

        iex> Harmonex.Interval.new :imperfect, 1
        {:error, #{inspect @invalid_quality}}

        iex> Harmonex.Interval.new :perfect, 0
        {:error, #{inspect @invalid_size}}

        iex> Harmonex.Interval.new :minor, -3
        {:error, #{inspect @invalid_size}}

        iex> Harmonex.Interval.new :minor, nil
        {:error, #{inspect @invalid_size}}
    """
    def new(unquote(quality)=quality, unquote(size)=size) do
      new %{quality: quality, size: size}
    end
  end

  for {quality, size} <- @intervals_invalid do
    def new(%{quality: unquote(quality),
              size: unquote(size)=size}=_definition) do
      error_quality size, size
    end

    def new(unquote(quality), unquote(size)=size), do: error_quality(size, size)
  end

  for quality <- @qualities do
    def new(%{quality: unquote(quality),
              size: size}=_definition) when not is_integer(size) do
      {:error, @invalid_size}
    end

    def new(%{quality: unquote(quality),
              size: size}=_definition) when size <= 0 do
      {:error, @invalid_size}
    end

    def new(%{quality: unquote(quality), size: size}=definition) do
      next_size =  size - 7
      case new(%{definition | size: next_size}) do
        interval when is_map(interval) ->
          __MODULE__ |> struct(Map.delete(definition, :__struct__))
        {:error, _} ->
          error_quality next_size, size
      end
    end

    def new(%{quality: unquote(quality)}=_definition) do
      {:error, @invalid_size}
    end

    def new(unquote(quality)=quality, size) do
      new %{quality: quality, size: size}
    end
  end

  def new(_definition), do: {:error, @invalid_quality}

  def new(_quality, _size), do: {:error, @invalid_quality}

  @doc """
  Computes the distance in half steps across the specified `interval`.

  ## Examples

      iex> Harmonex.Interval.semitones %{quality: :major, size: 3}
      4

      iex> Harmonex.Interval.semitones %{quality: :doubly_diminished, size: 9}
      11

      iex> Harmonex.Interval.semitones %{quality: :doubly_diminished, size: 16}
      23

      iex> Harmonex.Interval.semitones %{quality: :augmented, size: 300}
      514
  """
  @spec semitones(t) :: non_neg_integer | Harmonex.error
  def semitones(interval) do
    with %{quality: interval_quality, size: interval_size} <- interval |> new do
      case @semitones_by_quality_and_size |> Map.get({interval_quality,
                                                      interval_size}) do
        semitones when is_integer(semitones) ->
          semitones
        _ ->
          simple_size = interval_size |> Integer.mod(7)
          case %{quality: interval_quality, size: simple_size} |> semitones do
            semitones when is_integer(semitones) ->
              semitones + (12 * div(interval_size, 7))
            _ ->
              semitones = %{quality: interval_quality,
                            size: simple_size + 7} |> semitones
              semitones + (12 * (div(interval_size, 7) - 1))
          end
      end
    end
  end

  @doc """
  Determines if the specified `interval` cannot be simplified (see `simplify/1`).

  Simple intervals are no more than 11 semitones across (see `semitones/1`).

  ## Examples

      iex> Harmonex.Interval.simple? %{quality: :major, size: 10}
      false

      iex> Harmonex.Interval.simple? %{quality: :major, size: 3}
      true

      iex> Harmonex.Interval.simple? %{quality: :augmented, size: 8}
      false

      iex> Harmonex.Interval.simple? %{quality: :diminished, size: 8}
      true
  """
  @spec simple?(t) :: boolean | Harmonex.error
  def simple?(interval) do
    with interval_struct when is_map(interval_struct) <- interval |> new,
         simplified                                   <- simplify(interval) do
      interval_struct == simplified
    end
  end

  @doc """
  Computes the simple interval that corresponds to the specified `interval`.

  Simple intervals are no more than 11 semitones across (see `semitones/1`).

  ## Examples

      iex> Harmonex.Interval.simplify %{quality: :major, size: 10}
      %Harmonex.Interval{quality: :major, size: 3}

      iex> Harmonex.Interval.simplify %{quality: :major, size: 3}
      %Harmonex.Interval{quality: :major, size: 3}

      iex> Harmonex.Interval.simplify %{quality: :augmented, size: 8}
      %Harmonex.Interval{quality: :augmented, size: 1}

      iex> Harmonex.Interval.simplify %{quality: :diminished, size: 8}
      %Harmonex.Interval{quality: :diminished, size: 8}
  """
  @spec simplify(t) :: interval | Harmonex.error
  def simplify(interval) do
    with interval_struct when is_map(interval_struct) <- new(interval),
         simplified <- simplify_impl(interval_struct) do
      if simplified |> new |> is_map, do: simplified, else: interval_struct
    end
  end

  @spec error_quality(pos_integer, pos_integer) :: Harmonex.error
  for {size_in_lookup, qualities} <- @quality_list_by_size do
    defp error_quality(unquote(size_in_lookup), size) do
      {:error,
       "Quality of #{Ordinal.to_string size} must be in #{inspect unquote(qualities)}"}
    end
  end

  defp error_quality(size_in_lookup, size) do
    error_quality size_in_lookup - 7, size
  end

  @spec simplify_impl(t) :: t
  defp simplify_impl(%{size: size}=interval) do
    %{interval | size: Integer.mod(size, 7)}
  end
end
