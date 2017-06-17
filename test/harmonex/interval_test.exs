defmodule Harmonex.IntervalTest do
  use ExUnit.Case, async: true

  alias Harmonex.Interval

  doctest Interval

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

  @qualities ~w(perfect
                minor
                major
                diminished
                augmented
                doubly_diminished
                doubly_augmented)a

  @intervals_invalid [minor:   1,
                      major:   1,
                      perfect: 2,
                      perfect: 3,
                      minor:   4,
                      major:   4,
                      minor:   5,
                      major:   5,
                      perfect: 6,
                      perfect: 7]

  @pitch_natural_names ~w(a b c d e f g)a
  @pitch_accidentals ~w(double_flat flat natural sharp double_sharp)a

  @invalid_quality "Invalid quality -- must be in #{inspect @qualities}"
  @invalid_size "Size cannot be zero"
  @invalid_interval "Invalid interval"
  @invalid_pitch_name "Invalid pitch name -- must be in #{inspect @pitch_natural_names}"
  @invalid_pitch_accidental "Invalid accidental -- must be in #{inspect @pitch_accidentals}"

  describe ".from_pitches/2" do
    test "accepts valid arguments" do
      expected = %Interval{quality: :diminished, size: 3}

      actual = Interval.from_pitches(%{natural_name: :a, accidental: :sharp},
                                     %{natural_name: :c})
      assert actual == expected

      actual = Interval.from_pitches(:a_sharp, %{natural_name: :c})
      assert actual == expected

      actual = Interval.from_pitches(%{natural_name: :a, accidental: :sharp}, :c)
      assert actual == expected

      actual = Interval.from_pitches(:a_sharp, :c)
      assert actual == expected
    end

    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_pitch_name}

      for accidental1 <- @pitch_accidentals,
          natural_name2 <- @pitch_natural_names,
          accidental2 <- @pitch_accidentals do
        actual = Interval.from_pitches(%{natural_name: :h,
                                         accidental: accidental1},
                                       %{natural_name: natural_name2,
                                         accidental: accidental2})
        assert actual == expected

        actual = Interval.from_pitches(:"h_#{accidental1}",
                                       %{natural_name: natural_name2,
                                         accidental: accidental2})
        assert actual == expected

        actual = Interval.from_pitches(%{natural_name: :h,
                                         accidental: accidental1},
                                       :"#{natural_name2}_#{accidental2}")
        assert actual == expected

        actual = Interval.from_pitches(:"h_#{accidental1}",
                                       :"#{natural_name2}_#{accidental2}")
        assert actual == expected
      end

      for accidental1 <- @pitch_accidentals,
          natural_name2 <- @pitch_natural_names do
        actual = Interval.from_pitches(%{natural_name: :h,
                                         accidental: accidental1},
                                       %{natural_name: natural_name2})
        assert actual == expected

        actual = Interval.from_pitches(:"h_#{accidental1}",
                                       %{natural_name: natural_name2})
        assert actual == expected

        actual = Interval.from_pitches(%{natural_name: :h,
                                         accidental: accidental1},
                                       natural_name2)
        assert actual == expected

        actual = Interval.from_pitches(:"h_#{accidental1}", natural_name2)
        assert actual == expected
      end

      for natural_name2 <- @pitch_natural_names do
        actual = Interval.from_pitches(%{natural_name: :h},
                                       %{natural_name: natural_name2})
        assert actual == expected

        actual = Interval.from_pitches(:h, %{natural_name: natural_name2})
        assert actual == expected

        actual = Interval.from_pitches(%{natural_name: :h}, natural_name2)
        assert actual == expected

        actual = Interval.from_pitches(:h, natural_name2)
        assert actual == expected
      end
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_pitch_name}

      for natural_name1 <- @pitch_natural_names,
          accidental1 <- @pitch_accidentals,
          accidental2 <- @pitch_accidentals do
        actual = Interval.from_pitches(%{natural_name: natural_name1,
                                         accidental: accidental1},
                                       %{natural_name: :h,
                                         accidental: accidental2})
        assert actual == expected

        actual = Interval.from_pitches(%{natural_name: natural_name1,
                                         accidental: accidental1},
                                       :"h_#{accidental2}")
        assert actual == expected

        actual = Interval.from_pitches(:"#{natural_name1}_#{accidental1}",
                                       %{natural_name: :h,
                                         accidental: accidental2})
        assert actual == expected

        actual = Interval.from_pitches(:"#{natural_name1}_#{accidental1}",
                                       :"h_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @pitch_natural_names,
          accidental2 <- @pitch_accidentals do
        actual = Interval.from_pitches(%{natural_name: natural_name1},
                                       %{natural_name: :h,
                                         accidental: accidental2})
        assert actual == expected

        actual = Interval.from_pitches(%{natural_name: natural_name1},
                                :"h_#{accidental2}")
        assert actual == expected

        actual = Interval.from_pitches(natural_name1,
                                       %{natural_name: :h,
                                         accidental: accidental2})
        assert actual == expected

        actual = Interval.from_pitches(natural_name1, :"h_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @pitch_natural_names do
        actual = Interval.from_pitches(%{natural_name: natural_name1},
                                       %{natural_name: :h})
        assert actual == expected

        actual = Interval.from_pitches(%{natural_name: natural_name1}, :h)
        assert actual == expected

        actual = Interval.from_pitches(natural_name1, %{natural_name: :h})
        assert actual == expected

        actual = Interval.from_pitches(natural_name1, :h)
        assert actual == expected
      end
    end

    test "rejects an invalid accidental in the first argument" do
      expected = {:error, @invalid_pitch_accidental}

      for natural_name1 <- @pitch_natural_names,
          natural_name2 <- @pitch_natural_names,
          accidental2 <- @pitch_accidentals do
        actual = Interval.from_pitches(%{natural_name: natural_name1,
                                         accidental: :out_of_tune},
                                       %{natural_name: natural_name2,
                                         accidental: accidental2})
        assert actual == expected

        actual = Interval.from_pitches(%{natural_name: natural_name1,
                                         accidental: :out_of_tune},
                                       :"#{natural_name2}_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @pitch_natural_names,
          natural_name2 <- @pitch_natural_names do
        actual = Interval.from_pitches(%{natural_name: natural_name1,
                                         accidental: :out_of_tune},
                                       %{natural_name: natural_name2})
        assert actual == expected

        actual = Interval.from_pitches(%{natural_name: natural_name1,
                                         accidental: :out_of_tune},
                                       natural_name2)
        assert actual == expected
      end
    end

    test "rejects an invalid accidental in the second argument" do
      expected = {:error, @invalid_pitch_accidental}

      for natural_name1 <- @pitch_natural_names,
          accidental1 <- @pitch_accidentals,
          natural_name2 <- @pitch_natural_names do
        actual = Interval.from_pitches(%{natural_name: natural_name1,
                                         accidental: accidental1},
                                       %{natural_name: natural_name2,
                                         accidental: :out_of_tune})
        assert actual == expected
      end

      for natural_name1 <- @pitch_natural_names, natural_name2 <- @pitch_natural_names do
        actual = Interval.from_pitches(%{natural_name: natural_name1},
                                       %{natural_name: natural_name2,
                                         accidental: :out_of_tune})
        assert actual == expected

        actual = Interval.from_pitches(natural_name1,
                                       %{natural_name: natural_name2,
                                         accidental: :out_of_tune})
        assert actual == expected
      end
    end

    test "rejects an invalid interval" do
      expected = {:error, @invalid_interval}
      actual = Interval.from_pitches(:a_flat, :e_double_sharp)
      assert actual == expected
    end
  end

  describe ".new/1" do
    test "accepts valid arguments" do
      for {quality, size} <- @intervals do
        assert Interval.new(%{quality: quality, size: size})     == %Interval{quality: quality, size: size}
        assert Interval.new(%{quality: quality, size: size + 7}) == %Interval{quality: quality, size: size + 7}

        assert Interval.new(%{quality: quality, size: -size})       == %Interval{quality: quality, size: -size}
        assert Interval.new(%{quality: quality, size: -(size + 7)}) == %Interval{quality: quality, size: -(size + 7)}
      end

      assert Interval.new(%{quality: :minor, size:  300}) == %Interval{quality: :minor, size:  300}
      assert Interval.new(%{quality: :minor, size: -300}) == %Interval{quality: :minor, size: -300}
    end

    test "rejects an invalid quality" do
      expected = {:error, @invalid_quality}

      actual = Interval.new(%{quality: :foo, size: 1})
      assert actual == expected

      actual = Interval.new(%{size: 1})
      assert actual == expected
    end

    test "rejects an invalid size" do
      expected = {:error, @invalid_size}

      for quality <- @qualities do
        actual = Interval.new(%{quality: quality, size: 0})
        assert actual == expected

        actual = Interval.new(%{quality: quality})
        assert actual == expected
      end
    end

    test "rejects an invalid interval" do
      for {quality, size} <- @intervals_invalid do
        {:error, reason} = Interval.new(%{quality: quality, size: size})
        assert reason |> String.match?(~r/^Quality of \w+ must be in \[.+\]$/)

        {:error, reason} = Interval.new(%{quality: quality, size: -size})
        assert reason |> String.match?(~r/^Quality of negative \w+ must be in \[.+\]$/)
      end

      expected = {:error,
                  "Quality of 300th must be in [:minor, :major, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}
      actual = Interval.new(%{quality: :perfect, size: 300})
      assert actual == expected

      expected = {:error,
                  "Quality of negative 300th must be in [:minor, :major, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}
      actual = Interval.new(%{quality: :perfect, size: -300})
      assert actual == expected
    end
  end

  describe ".new/2" do
    test "accepts valid arguments" do
      for {quality, size} <- @intervals do
        assert Interval.new(quality, size)     == %Interval{quality: quality, size: size}
        assert Interval.new(quality, size + 7) == %Interval{quality: quality, size: size + 7}

        assert Interval.new(quality, -size)       == %Interval{quality: quality, size: -size}
        assert Interval.new(quality, -(size + 7)) == %Interval{quality: quality, size: -(size + 7)}
      end

      assert Interval.new(:minor,  300) == %Interval{quality: :minor, size:  300}
      assert Interval.new(:minor, -300) == %Interval{quality: :minor, size: -300}
    end

    test "rejects an invalid quality" do
      actual = Interval.new(:foo, 1)
      assert actual == {:error, @invalid_quality}
    end

    test "rejects an invalid size" do
      expected = {:error, @invalid_size}

      for quality <- @qualities do
        actual = Interval.new(quality, 0)
        assert actual == expected
      end
    end

    test "rejects an invalid interval" do
      for {quality, size} <- @intervals_invalid do
        {:error, reason} = Interval.new(quality, size)
        assert reason |> String.match?(~r/^Quality of \w+ must be in \[.+\]$/)

        {:error, reason} = Interval.new(quality, -size)
        assert reason |> String.match?(~r/^Quality of negative \w+ must be in \[.+\]$/)
      end

      expected = {:error,
                  "Quality of 300th must be in [:minor, :major, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}
      actual = Interval.new(:perfect, 300)
      assert actual == expected

      expected = {:error,
                  "Quality of negative 300th must be in [:minor, :major, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}
      actual = Interval.new(:perfect, -300)
      assert actual == expected
    end
  end

  describe ".semitones/1" do
    test "accepts valid arguments" do
      for {quality, size} <- @intervals do
        actual = Interval.semitones(%{quality: quality, size: size})
        assert actual |> is_integer
        assert 0 <= actual

        actual = Interval.semitones(%{quality: quality, size: -size})
        assert actual |> is_integer
        assert actual <= 0
      end

      actual = Interval.semitones(%{quality: :minor, size: 300})
      assert actual == 512

      actual = Interval.semitones(%{quality: :minor, size: -300})
      assert actual == -512
    end

    test "rejects an invalid quality" do
      actual = Interval.semitones(%{quality: :foo, size: 1})
      assert actual == {:error, @invalid_quality}

      actual = Interval.semitones(%{size: 1})
      assert actual == {:error, @invalid_quality}
    end

    test "rejects an invalid size" do
      expected = {:error, @invalid_size}

      for quality <- @qualities do
        actual = Interval.semitones(%{quality: quality, size: 0})
        assert actual == expected

        actual = Interval.semitones(%{quality: quality})
        assert actual == expected
      end
    end

    test "rejects an invalid interval" do
      for {quality, size} <- @intervals_invalid do
        if {quality, size} in [{:doubly_diminished, 1},
                               {:diminished,        1},
                               {:doubly_diminished, 2}] do
          expected = {:error, @invalid_interval}

          actual = Interval.semitones(%{quality: quality, size: size})
          assert actual == expected

          actual = Interval.semitones(%{quality: quality, size: -size})
          assert actual == expected
        else
          {:error, reason} = Interval.semitones(%{quality: quality, size: size})
          assert reason |> String.match?(~r/^Quality of \w+ must be in \[.+\]$/)

          {:error, reason} = Interval.semitones(%{quality: quality, size: -size})
          assert reason |> String.match?(~r/^Quality of negative \w+ must be in \[.+\]$/)
        end
      end

      expected = {:error,
                  "Quality of 300th must be in [:minor, :major, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}
      actual = Interval.semitones(%{quality: :perfect, size: 300})
      assert actual == expected

      expected = {:error,
                  "Quality of negative 300th must be in [:minor, :major, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}
      actual = Interval.semitones(%{quality: :perfect, size: -300})
      assert actual == expected
    end
  end

  describe ".simplify/1" do
    test "accepts valid arguments" do
      for {quality, size} when size < 8 <- @intervals do
        assert Interval.simplify(%{quality: quality, size:  size}) == %Interval{quality: quality, size:  size}
        assert Interval.simplify(%{quality: quality, size: -size}) == %Interval{quality: quality, size: -size}
      end

      for {quality, size} when 8 <= size <- @intervals do
        simplified_size = case {quality, size} do
          {:doubly_diminished, 8} -> size
          {:diminished,        8} -> size
          {:doubly_diminished, 9} -> size
          _                       -> size - 7
        end
        assert Interval.simplify(%{quality: quality, size:  size}) == %Interval{quality: quality, size:  simplified_size}
        assert Interval.simplify(%{quality: quality, size: -size}) == %Interval{quality: quality, size: -simplified_size}
      end

      assert Interval.simplify(%{quality: :minor, size:  300}) == %Interval{quality: :minor, size:  6}
      assert Interval.simplify(%{quality: :minor, size: -300}) == %Interval{quality: :minor, size: -6}
    end

    test "rejects an invalid quality" do
      actual = Interval.simplify(%{quality: :foo, size: 1})
      assert actual == {:error, @invalid_quality}

      actual = Interval.simplify(%{size: 1})
      assert actual == {:error, @invalid_quality}
    end

    test "rejects an invalid size" do
      expected = {:error, @invalid_size}

      for quality <- @qualities do
        actual = Interval.simplify(%{quality: quality, size: 0})
        assert actual == expected

        actual = Interval.simplify(%{quality: quality})
        assert actual == expected
      end
    end

    test "rejects an invalid interval" do
      for {quality, size} <- @intervals_invalid do
        if {quality, size} in [{:doubly_diminished, 1},
                               {:diminished,        1},
                               {:doubly_diminished, 2}] do
          expected = {:error, @invalid_interval}

          actual = Interval.simplify(%{quality: quality, size: size})
          assert actual == expected

          actual = Interval.simplify(%{quality: quality, size: -size})
          assert actual == expected
        else
          {:error, reason} = Interval.simplify(%{quality: quality, size: size})
          assert reason |> String.match?(~r/^Quality of \w+ must be in \[.+\]$/)

          {:error, reason} = Interval.simplify(%{quality: quality, size: -size})
          assert reason |> String.match?(~r/^Quality of negative \w+ must be in \[.+\]$/)
        end
      end

      expected = {:error,
                  "Quality of 300th must be in [:minor, :major, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}
      actual = Interval.simplify(%{quality: :perfect, size: 300})
      assert actual == expected

      expected = {:error,
                  "Quality of negative 300th must be in [:minor, :major, :diminished, :augmented, :doubly_diminished, :doubly_augmented]"}
      actual = Interval.simplify(%{quality: :perfect, size: -300})
      assert actual == expected
    end
  end
end
