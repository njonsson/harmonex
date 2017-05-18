defmodule Harmonex.IntervalTest do
  use ExUnit.Case, async: true
  doctest Harmonex.Interval

  @intervals [perfect:           1,
              augmented:         1,
              doubly_augmented:  1,
              diminished:        2,
              minor:             2,
              major:             2,
              augmented:         2,
              doubly_augmented:  2,
              doubly_diminished: 3,
              diminished:        3,
              minor:             3,
              major:             3,
              augmented:         3,
              doubly_augmented:  3,
              doubly_diminished: 4,
              diminished:        4,
              perfect:           4,
              augmented:         4,
              doubly_augmented:  4,
              doubly_diminished: 5,
              diminished:        5,
              perfect:           5,
              augmented:         5,
              doubly_augmented:  5,
              doubly_diminished: 6,
              diminished:        6,
              minor:             6,
              major:             6,
              augmented:         6,
              doubly_augmented:  6,
              doubly_diminished: 7,
              diminished:        7,
              minor:             7,
              major:             7,
              augmented:         7,
              doubly_augmented:  7]

  @intervals_invalid [doubly_diminished: 1,
                      diminished:        1,
                      minor:             1,
                      major:             1,
                      doubly_diminished: 2,
                      perfect:           2,
                      perfect:           3,
                      minor:             4,
                      major:             4,
                      minor:             5,
                      major:             5,
                      perfect:           6,
                      perfect:           7]

  describe ".new/1" do
    test "accepts valid arguments" do
      for {quality, size} <- @intervals do
        assert Harmonex.Interval.new(%{quality: quality, size: size})     == %Harmonex.Interval{quality: quality, size: size}
        assert Harmonex.Interval.new(%{quality: quality, size: size + 7}) == %Harmonex.Interval{quality: quality, size: size + 7}
      end
    end

    test "rejects invalid arguments" do
      for {quality, size} <- @intervals_invalid do
        {:error, reason} = Harmonex.Interval.new(%{quality: quality, size: size})
        assert reason |> String.match?(~r/^Quality of \w+ cannot be #{inspect quality}$/)

        {:error, reason} = Harmonex.Interval.new(%{quality: quality, size: size + 7})
        assert reason |> String.match?(~r/^Quality of \w+ cannot be #{inspect quality}$/)
      end

      {:error, reason} = Harmonex.Interval.new(%{quality: :perfect, size: 300})
      assert reason == "Quality of 300th cannot be :perfect"
    end
  end

  describe ".new/2" do
    test "accepts valid arguments" do
      for {quality, size} <- @intervals do
        assert Harmonex.Interval.new(quality, size)     == %Harmonex.Interval{quality: quality, size: size}
        assert Harmonex.Interval.new(quality, size + 7) == %Harmonex.Interval{quality: quality, size: size + 7}
      end
    end

    test "rejects invalid arguments" do
      for {quality, size} <- @intervals_invalid do
        {:error, reason} = Harmonex.Interval.new(quality, size)
        assert reason |> String.match?(~r/^Quality of \w+ cannot be #{inspect quality}$/)

        {:error, reason} = Harmonex.Interval.new(quality, size + 7)
        assert reason |> String.match?(~r/^Quality of \w+ cannot be #{inspect quality}$/)
      end

      {:error, reason} = Harmonex.Interval.new(:perfect, 300)
      assert reason == "Quality of 300th cannot be :perfect"
    end
  end
end
