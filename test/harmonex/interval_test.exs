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
              doubly_augmented:  7,
              doubly_diminished: 8,
              diminished:        8,
              perfect:           8,
              augmented:         8,
              doubly_augmented:  8,
              doubly_diminished: 9,
              diminished:        9,
              minor:             9,
              major:             9,
              augmented:         9,
              doubly_augmented:  9]

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
                      perfect:           7,
                      minor:             8,
                      major:             8,
                      perfect:           9]

  @invalid_pitch_name "Invalid pitch name -- must be in [:a, :b, :c, :d, :e, :f, :g]"

  describe ".from_pitches/2" do
    test "accepts valid arguments" do
      expected = %Harmonex.Interval{quality: :diminished, size: 3}

      actual = Harmonex.Interval.from_pitches(%{natural_name: :a,
                                                accidental: :sharp},
                                              :c)
      assert actual == expected

      actual = Harmonex.Interval.from_pitches(:a_sharp, %{natural_name: :c})
      assert actual == expected
    end

    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_pitch_name}

      actual = Harmonex.Interval.from_pitches(%{natural_name: :h,
                                                accidental: :flat},
                                              :a)
      assert actual == expected

      actual = Harmonex.Interval.from_pitches(%{natural_name: :h}, :a)
      assert actual == expected

      actual = Harmonex.Interval.from_pitches(:h_flat, :a)
      assert actual == expected

      actual = Harmonex.Interval.from_pitches(:h, :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_pitch_name}

      actual = Harmonex.Interval.from_pitches(:a,
                                              %{natural_name: :h,
                                                accidental: :flat})
      assert actual == expected

      actual = Harmonex.Interval.from_pitches(:a, %{natural_name: :h})
      assert actual == expected

      actual = Harmonex.Interval.from_pitches(:a, :h_flat)
      assert actual == expected

      actual = Harmonex.Interval.from_pitches(:a, :h)
      assert actual == expected
    end

    test "recognizes an invalid interval" do
      expected = {:error, "Invalid interval"}
      actual = Harmonex.Interval.from_pitches(:a_flat, :e_double_sharp)
      assert actual == expected
    end
  end

  describe ".new/1" do
    test "accepts valid arguments" do
      for {quality, size} <- @intervals do
        assert Harmonex.Interval.new(%{quality: quality, size: size})     == %Harmonex.Interval{quality: quality, size: size}
        assert Harmonex.Interval.new(%{quality: quality, size: size + 7}) == %Harmonex.Interval{quality: quality, size: size + 7}

        assert Harmonex.Interval.new(%{quality: quality, size: -size})       == %Harmonex.Interval{quality: quality, size: -size}
        assert Harmonex.Interval.new(%{quality: quality, size: -(size + 7)}) == %Harmonex.Interval{quality: quality, size: -(size + 7)}
      end

      assert Harmonex.Interval.new(%{quality: :minor, size:  300}) == %Harmonex.Interval{quality: :minor, size:  300}
      assert Harmonex.Interval.new(%{quality: :minor, size: -300}) == %Harmonex.Interval{quality: :minor, size: -300}
    end

    test "rejects invalid arguments" do
      for {quality, size} <- @intervals_invalid do
        {:error, reason} = Harmonex.Interval.new(%{quality: quality, size: size})
        assert reason |> String.match?(~r/^Quality of \w+ must be in \[.+\]$/)

        {:error, reason} = Harmonex.Interval.new(%{quality: quality, size: -size})
        assert reason |> String.match?(~r/^Quality of negative \w+ must be in \[.+\]$/)
      end

      {:error, reason} = Harmonex.Interval.new(%{quality: :perfect, size: 300})
      assert reason == "Quality of 300th must be in [:doubly_diminished, :diminished, :minor, :major, :augmented, :doubly_augmented]"

      {:error, reason} = Harmonex.Interval.new(%{quality: :perfect, size: -300})
      assert reason == "Quality of negative 300th must be in [:doubly_diminished, :diminished, :minor, :major, :augmented, :doubly_augmented]"
    end
  end

  describe ".new/2" do
    test "accepts valid arguments" do
      for {quality, size} <- @intervals do
        assert Harmonex.Interval.new(quality, size)     == %Harmonex.Interval{quality: quality, size: size}
        assert Harmonex.Interval.new(quality, size + 7) == %Harmonex.Interval{quality: quality, size: size + 7}

        assert Harmonex.Interval.new(quality, -size)       == %Harmonex.Interval{quality: quality, size: -size}
        assert Harmonex.Interval.new(quality, -(size + 7)) == %Harmonex.Interval{quality: quality, size: -(size + 7)}
      end

      assert Harmonex.Interval.new(:minor,  300) == %Harmonex.Interval{quality: :minor, size:  300}
      assert Harmonex.Interval.new(:minor, -300) == %Harmonex.Interval{quality: :minor, size: -300}
    end

    test "rejects invalid arguments" do
      for {quality, size} <- @intervals_invalid do
        {:error, reason} = Harmonex.Interval.new(quality, size)
        assert reason |> String.match?(~r/^Quality of \w+ must be in \[.+\]$/)

        {:error, reason} = Harmonex.Interval.new(quality, -size)
        assert reason |> String.match?(~r/^Quality of negative \w+ must be in \[.+\]$/)
      end

      {:error, reason} = Harmonex.Interval.new(:perfect, 300)
      assert reason == "Quality of 300th must be in [:doubly_diminished, :diminished, :minor, :major, :augmented, :doubly_augmented]"

      {:error, reason} = Harmonex.Interval.new(:perfect, -300)
      assert reason == "Quality of negative 300th must be in [:doubly_diminished, :diminished, :minor, :major, :augmented, :doubly_augmented]"
    end
  end
end
