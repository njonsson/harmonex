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
  @type interval :: %Harmonex.Interval{quality: quality, size: integer}

  @typedoc """
  A literal expression describing an interval.
  """
  @type t :: %{quality: quality, size: integer}

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
  @quality_by_semitones_and_size %{{-2, 1} => :doubly_diminished,
                                   {-1, 1} => :diminished,
                                   { 0, 1} => :perfect,
                                   { 1, 1} => :augmented,
                                   { 2, 1} => :doubly_augmented,
                                   {-1, 2} => :doubly_diminished,
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
                                   { 0, 7} => :augmented,
                                   { 1, 7} => :doubly_augmented}
  unless MapSet.new(@qualities) ==
         MapSet.new(Map.values(@quality_by_semitones_and_size)) do
    raise "Qualities mismatch between @qualities and @quality_by_semitones_and_size"
  end

  @intervals @quality_by_semitones_and_size |> Enum.reduce([],
                                                           fn({{semitones, size}, quality},
                                                              acc) ->
                                                 new_acc = if semitones < 0 do
                                                             acc
                                                           else
                                                             [{quality, size} | acc]
                                                           end
                                                 [{quality, size + 7} | new_acc]
                                               end)
  unless MapSet.new(@qualities) == MapSet.new(Keyword.keys(@intervals)) do
    raise "Qualities mismatch between @qualities and @intervals"
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

  @intervals_invalid (@quality_list_by_size |> Enum.reduce([], fn({size, qualities}, acc) ->
                        for_quality = for q <- (@qualities -- qualities) do
                          {q, size}
                        end
                        acc ++ for_quality
                               # These are invalid, but also less than zero
                               # semitones in size.
                      end)) -- [doubly_diminished: 1,
                                diminished:        1,
                                doubly_diminished: 2]

  @invalid_quality "Invalid quality -- must be in #{inspect @qualities}"
  @invalid_size "Size cannot be zero"
  @invalid_interval "Invalid interval"

  @doc """
  Computes the interval between the specified `low_pitch` and `high_pitch`.

  ## Examples

      iex> Harmonex.Interval.from_pitches %{natural_name: :a, accidental: :sharp}, %{natural_name: :c}
      %Harmonex.Interval{quality: :diminished, size: 3}

      iex> Harmonex.Interval.from_pitches :b_flat, :c
      %Harmonex.Interval{quality: :major, size: 2}

      iex> Harmonex.Interval.from_pitches :d_double_sharp, :a_double_sharp
      %Harmonex.Interval{quality: :perfect, size: 5}

      iex> Harmonex.Interval.from_pitches :c_flat, :c_natural
      %Harmonex.Interval{quality: :augmented, size: 1}

      iex> Harmonex.Interval.from_pitches :a_flat, :e_sharp
      %Harmonex.Interval{quality: :doubly_augmented, size: 5}

      iex> Harmonex.Interval.from_pitches :a_flat, :e_double_sharp
      {:error, #{inspect @invalid_interval}}
  """
  @spec from_pitches(Pitch.t, Pitch.t) :: interval | Harmonex.error
  def from_pitches(low_pitch, high_pitch) do
    with semitones when is_integer(semitones) <- Pitch.semitones(low_pitch, high_pitch) do
      low  = low_pitch  |> Pitch.natural_name |> to_charlist |> List.first
      high = high_pitch |> Pitch.natural_name |> to_charlist |> List.first
      interval_size = Integer.mod(high - low, 7) + 1
      with interval_quality when is_atom(interval_quality) <- Map.get(@quality_by_semitones_and_size,
                                                                      {semitones, interval_size},
                                                                      {:error, @invalid_interval}) do
        new %{quality: interval_quality, size: interval_size}
      end
    end
  end

  @doc """
  Constructs a new interval with the specified `definition`.

  ## Examples

      iex> Harmonex.Interval.new %{quality: :perfect, size: 1}
      %Harmonex.Interval{quality: :perfect, size: 1}

      iex> Harmonex.Interval.new %{quality: :minor, size: -10}
      %Harmonex.Interval{quality: :minor, size: -10}

      iex> Harmonex.Interval.new %{quality: :perfect, size: 0}
      {:error, #{inspect @invalid_size}}

      iex> Harmonex.Interval.new %{quality: :minor, size: 1}
      {:error, "Quality of unison must be in [:perfect, :augmented, :doubly_augmented]"}

      iex> Harmonex.Interval.new %{quality: :major, size: 8}
      {:error, "Quality of octave must be in [:perfect, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}
  """
  @spec new(t) :: interval | Harmonex.error
  @spec new(quality, integer) :: interval | Harmonex.error
  for {quality, size} <- @intervals do
    def new(%{quality: unquote(quality), size: unquote(size)}=definition) do
      __MODULE__ |> struct(definition)
    end

    def new(%{quality: unquote(quality), size: unquote(-size)}=definition) do
      __MODULE__ |> struct(definition)
    end

    @doc """
    Constructs a new interval with the specified `quality` and `size`.

    ## Examples

        iex> Harmonex.Interval.new :perfect, 1
        %Harmonex.Interval{quality: :perfect, size: 1}

        iex> Harmonex.Interval.new :minor, -10
        %Harmonex.Interval{quality: :minor, size: -10}

        iex> Harmonex.Interval.new :perfect, 0
        {:error, #{inspect @invalid_size}}

        iex> Harmonex.Interval.new :minor, 1
        {:error, "Quality of unison must be in [:perfect, :augmented, :doubly_augmented]"}

        iex> Harmonex.Interval.new :major, 8
        {:error, "Quality of octave must be in [:perfect, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}
    """
    def new(unquote(quality)=quality, unquote(size)=size) do
      new %{quality: quality, size: size}
    end

    def new(unquote(quality)=quality, unquote(-size)=size) do
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
    def new(%{quality: unquote(quality), size: 0}=_definition) do
      {:error, @invalid_size}
    end

    def new(%{quality: unquote(quality), size: size}=definition) do
      %{size: reduced_size} = reduced = definition |> reduce_impl
      if reduced_size == size do
        error_quality reduced_size, size
      else
        case reduced |> new do
          {:error, _} ->
            %{size: expanded_size} = reduced |> expand_by(7)
            if expanded_size == size do
              error_quality reduced_size, size
            else
              case reduced |> expand_by(7) |> new do
                {:error, _} -> error_quality(reduced_size, size)
                _           -> __MODULE__ |> struct(definition)
              end
            end
          _ ->
            __MODULE__ |> struct(definition)
        end
      end
    end

    def new(%{quality: unquote(quality)}=_definition) do
      {:error, @invalid_size}
    end

    def new(unquote(quality)=quality, size) do
      %{quality: quality, size: size} |> new
    end
  end

  def new(_definition), do: {:error, @invalid_quality}

  def new(_quality, _size), do: {:error, @invalid_quality}

  @doc """
  Computes the simple-interval equivalent of the specified `interval`.

  ## Examples

      iex> Harmonex.Interval.reduce %{quality: :major, size: -10}
      %{quality: :major, size: -3}

      iex> Harmonex.Interval.reduce Harmonex.Interval.new(:major, 3)
      %Harmonex.Interval{quality: :major, size: 3}

      iex> Harmonex.Interval.reduce %{quality: :augmented, size: -8}
      %{quality: :augmented, size: -1}
  """
  @spec reduce(t) :: t | Harmonex.error
  def reduce(%{size: 0}=_interval), do: {:error, @invalid_size}

  def reduce(%{quality: :doubly_diminished, size: -8}=interval), do: interval

  def reduce(%{quality: :diminished, size: -8}=interval), do: interval

  def reduce(%{quality: :doubly_diminished, size: 8}=interval), do: interval

  def reduce(%{quality: :diminished, size: 8}=interval) do
    interval
  end

  def reduce(%{quality: :doubly_diminished, size: -9}=interval) do
    interval
  end

  def reduce(%{quality: :doubly_diminished, size: 9}=interval) do
    interval
  end

  for {quality, size} <- (@intervals -- [doubly_diminished: 8,
                                         diminished:        8,
                                         doubly_diminished: 9]) do
    def reduce(%{quality: unquote(quality), size: unquote(size)}=interval) do
      interval |> reduce_impl
    end

    def reduce(%{quality: unquote(quality), size: unquote(-size)}=interval) do
      interval |> reduce_impl
    end
  end

  for {quality, size} <- @intervals_invalid do
    def reduce(%{quality: unquote(quality),
                 size: unquote(size)=size}=_interval) do
      error_quality size, size
    end

    def reduce(%{quality: unquote(quality),
                 size: unquote(-size)=size}=_interval) do
      error_quality size, size
    end
  end

  for quality <- @qualities do
    def reduce(%{quality: unquote(quality),
                 size: size}=interval) when is_integer(size) do
      reduced_interval = interval |> reduce_impl
      case reduced_interval |> reduce do
        {:error, _} -> error_quality reduced_interval.size, size
        interval    -> interval
      end
    end

    def reduce(%{quality: unquote(quality), size: _}=_interval) do
      {:error, @invalid_size}
    end
  end

  def reduce(%{quality: _}=_interval), do: {:error, @invalid_quality}

  defp reduce_impl(%{size: size}=interval) do
    sign = if size < 0, do: -1, else: 1
    reduced_size = sign * (Integer.mod(abs(size) - 1, 7) + 1)
    %{interval | size: reduced_size}
  end

  @spec error_quality(integer, pos_integer) :: Harmonex.error
  for {size_in_lookup, qualities} <- @quality_list_by_size do
    defp error_quality(unquote(size_in_lookup), size) do
      {:error, "Quality of #{Ordinal.to_string size} must be in #{inspect unquote(qualities)}"}
    end

    defp error_quality(unquote(-size_in_lookup), size) do
      {:error, "Quality of #{Ordinal.to_string size} must be in #{inspect unquote(qualities)}"}
    end
  end

  @spec expand_by(%{size: integer}, integer) :: t
  defp expand_by(%{size: size}=interval, amount) do
    sign = if size < 0, do: -1, else: 1
    expanded_size = sign * (abs(size) + amount)
    %{interval | size: expanded_size}
  end
end
