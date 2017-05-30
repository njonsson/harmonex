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
  @qualities @quality_by_semitones_and_size |> Map.values |> Enum.uniq

  quality_score = fn(quality) ->
    ~w(doubly_diminished
       diminished
       minor
       perfect
       major
       augmented
       doubly_augmented)a |> Enum.find_index(&(&1 == quality))
  end
  @quality_list_by_size @intervals |> Enum.reduce(%{},
                                                  fn({quality, size}, acc) ->
                                        acc |> Map.put_new(size, [])
                                            |> Map.update!(size,
                                                           &([quality | &1] |> Enum.sort_by(fn(q) -> quality_score.(q) end)))
                                      end)
  @intervals_invalid @quality_list_by_size |> Enum.reduce([], fn({size, qualities}, acc) ->
                        for_quality = for q <- (@qualities -- qualities) do
                          {q, size}
                        end
                        acc ++ for_quality
                      end)

  @doc """
  Computes the `Harmonex.Interval` between the specified `low_pitch` and
  `high_pitch`.

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
      {:error, "Invalid interval"}
  """
  @spec from_pitches(Pitch.t, Pitch.t) :: t | {:error, binary}
  def from_pitches(low_pitch, high_pitch) do
    with semitones when is_integer(semitones) <- Pitch.semitones(low_pitch, high_pitch) do
      low  = low_pitch  |> Pitch.natural_name |> to_charlist |> List.first
      high = high_pitch |> Pitch.natural_name |> to_charlist |> List.first
      interval_size = Integer.mod(high - low, 7) + 1
      with interval_quality when is_atom(interval_quality) <- Map.get(@quality_by_semitones_and_size,
                                                                      {semitones, interval_size},
                                                                      {:error, "Invalid interval"}) do
        new %{quality: interval_quality, size: interval_size}
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
      {:error, "Quality of unison must be in [:perfect, :augmented, :doubly_augmented]"}

      iex> Harmonex.Interval.new %{quality: :major, size: 8}
      {:error, "Quality of octave must be in [:doubly_diminished, :diminished, :perfect, :augmented, :doubly_augmented]"}
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
        {:error, "Quality of unison must be in [:perfect, :augmented, :doubly_augmented]"}

        iex> Harmonex.Interval.new :major, 8
        {:error, "Quality of octave must be in [:doubly_diminished, :diminished, :perfect, :augmented, :doubly_augmented]"}
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
    def new(%{quality: unquote(quality), size: 0}=_definition) do
      {:error, "Size cannot be zero"}
    end

    def new(%{quality: unquote(quality), size: size}=definition) do
      reduced_size = Integer.mod(abs(size) - 1, 7) + 1
      case definition |> Map.put(:size, reduced_size) |> new do
        {:error, _} ->
          case definition |> Map.put(:size, reduced_size + 7) |> new do
            {:error, _} ->
                error_quality(reduced_size, size)
            _ ->
              __MODULE__ |> struct(definition)
          end
        _ ->
          __MODULE__ |> struct(definition)
      end
    end

    def new(unquote(quality)=quality, size) do
      %{quality: quality, size: size} |> new
    end
  end

  @spec error_quality(integer, pos_integer) :: {:error, binary}
  for {size_in_lookup, qualities} <- @quality_list_by_size do
    defp error_quality(unquote(size_in_lookup), size) do
      {:error, "Quality of #{Ordinal.to_string size} must be in #{inspect unquote(qualities)}"}
    end
  end
end
