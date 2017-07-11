defmodule Harmonex.PitchTest do
  use ExUnit.Case, async: true

  alias Harmonex.{Pitch,Interval}

  doctest Pitch

  @natural_names ~w(a b c d e f g)a
  @accidentals ~w(double_flat flat natural sharp double_sharp)a
  @octaves [-100, -1, 0, 1, 100]

  @invalid_name "Invalid pitch name -- must be in #{inspect @natural_names}"
  @invalid_accidental_or_octave "Invalid accidental or octave -- must be in #{inspect @accidentals} or be an integer"
  @invalid_accidental "Invalid accidental -- must be in #{inspect @accidentals}"
  @invalid_octave "Invalid octave -- must be an integer"

  describe ".accidental/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names,
          accidental <- @accidentals,
          octave <- @octaves do
        expected = accidental
        actual = Pitch.accidental(%{natural_name: natural_name,
                                    accidental: accidental,
                                    octave: octave})
        assert actual == expected
      end

      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = accidental

        actual = Pitch.accidental(%{natural_name: natural_name,
                                    accidental: accidental})
        assert actual == expected

        actual = Pitch.accidental(:"#{natural_name}_#{accidental}")
        assert actual == expected
      end

      expected = :natural

      for natural_name <- @natural_names, octave <- @octaves do
        actual = Pitch.accidental(%{natural_name: natural_name, octave: octave})
        assert actual == expected
      end

      for natural_name <- @natural_names do
        actual = Pitch.accidental(%{natural_name: natural_name})
        assert actual == expected

        actual = Pitch.accidental(natural_name)
        assert actual == expected
      end
    end
  end

  describe ".adjust_by_semitones/2" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names,
          accidental <- @accidentals,
          octave <- @octaves do
        actual = Pitch.adjust_by_semitones(%{natural_name: natural_name,
                                             accidental: accidental,
                                             octave: octave},
                                           1)
        assert is_map(actual)
        refute is_nil(actual.natural_name)
        refute is_nil(actual.accidental)

        actual = Pitch.adjust_by_semitones(:"#{natural_name}_#{accidental}", 1)
        assert is_atom(actual)
      end

      for natural_name <- @natural_names, accidental <- @accidentals do
        actual = Pitch.adjust_by_semitones(%{natural_name: natural_name,
                                             accidental: accidental},
                                           1)
        assert is_map(actual)
        refute is_nil(actual.natural_name)
        refute is_nil(actual.accidental)

        actual = Pitch.adjust_by_semitones(:"#{natural_name}_#{accidental}", 1)
        assert is_atom(actual)
      end

      for natural_name <- @natural_names, octave <- @octaves do
        actual = Pitch.adjust_by_semitones(%{natural_name: natural_name,
                                             octave: octave},
                                           1)
        assert is_map(actual)
        refute is_nil(actual.natural_name)
        refute is_nil(actual.accidental)
      end

      for natural_name <- @natural_names do
        actual = Pitch.adjust_by_semitones(%{natural_name: natural_name}, 1)
        assert is_map(actual)
        refute is_nil(actual.natural_name)
        refute is_nil(actual.accidental)

        actual = Pitch.adjust_by_semitones(natural_name, 1)
        assert is_atom(actual)
      end
    end
  end

  describe ".enharmonic?/2" do
    test "accepts valid arguments" do
      for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
          natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2})
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   :"#{natural_name2}_#{accidental2}")
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
          natural_name2 <- @natural_names,                              octave2 <- @octaves do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     octave: octave2})
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
          natural_name2 <- @natural_names do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   natural_name2)
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2})
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names,                              octave1 <- @octaves,
          natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2})
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names,
          natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(natural_name1,
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2})
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     accidental: accidental2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   :"#{natural_name2}_#{accidental2}")
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(:"#{natural_name1}_#{accidental1}",
                                   :"#{natural_name2}_#{accidental2}")
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          natural_name2 <- @natural_names,                              octave2 <- @octaves do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     octave: octave2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     octave: octave2})
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          natural_name2 <- @natural_names do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: natural_name2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: natural_name2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   natural_name2)
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(:"#{natural_name1}_#{accidental1}",
                                   natural_name2)
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names,                              octave1 <- @octaves,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     octave: octave1},
                                   :"#{natural_name2}_#{accidental2}")
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names, octave1 <- @octaves,
          natural_name2 <- @natural_names, octave2 <- @octaves do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     octave: octave2})
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names, octave1 <- @octaves,
          natural_name2 <- @natural_names do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: natural_name2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     octave: octave1},
                                   natural_name2)
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(natural_name1,
                                   %{natural_name: natural_name2,
                                     accidental: accidental2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(%{natural_name: natural_name1},
                                   :"#{natural_name2}_#{accidental2}")
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(natural_name1,
                                   :"#{natural_name2}_#{accidental2}")
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names,
          natural_name2 <- @natural_names, octave2 <- @octaves do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1},
                                   %{natural_name: natural_name2,
                                     octave: octave2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(natural_name1,
                                   %{natural_name: natural_name2,
                                     octave: octave2})
        assert is_boolean(actual)
      end

      for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1},
                                   %{natural_name: natural_name2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(%{natural_name: natural_name1}, natural_name2)
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(natural_name1, %{natural_name: natural_name2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(natural_name1, natural_name2)
        assert is_boolean(actual)
      end
    end

    test "correctly handles A-sharp and C-double-flat" do
      assert Pitch.enharmonic?(%{natural_name: :a, accidental: :sharp,       octave: -2},
                               %{natural_name: :c, accidental: :double_flat, octave: -1})
      assert Pitch.enharmonic?(:a_sharp, :c_double_flat)

      refute Pitch.enharmonic?(%{natural_name: :a, accidental: :sharp,       octave: -1},
                               %{natural_name: :c, accidental: :double_flat, octave: -1})
    end

    test "correctly handles B-flat and C-double-flat" do
      assert Pitch.enharmonic?(%{natural_name: :b, accidental: :flat,        octave: -1},
                               %{natural_name: :c, accidental: :double_flat, octave:  0})
      assert Pitch.enharmonic?(:b_flat, :c_double_flat)

      refute Pitch.enharmonic?(%{natural_name: :b, accidental: :flat,        octave: 0},
                               %{natural_name: :c, accidental: :double_flat, octave: 0})
    end

    test "correctly handles A-double-sharp and C-flat" do
      assert Pitch.enharmonic?(%{natural_name: :a, accidental: :double_sharp, octave: 0},
                               %{natural_name: :c, accidental: :flat,         octave: 1})
      assert Pitch.enharmonic?(:a_double_sharp, :c_flat)

      refute Pitch.enharmonic?(%{natural_name: :a, accidental: :double_sharp, octave: 1},
                               %{natural_name: :c, accidental: :flat,         octave: 1})
    end

    test "correctly handles B-natural and C-flat" do
      assert Pitch.enharmonic?(%{natural_name: :b,                    octave: 1},
                               %{natural_name: :c, accidental: :flat, octave: 2})
      assert Pitch.enharmonic?(:b, :c_flat)

      refute Pitch.enharmonic?(%{natural_name: :b,                    octave: 2},
                               %{natural_name: :c, accidental: :flat, octave: 2})
    end

    test "correctly handles B-sharp and C-natural" do
      assert Pitch.enharmonic?(%{natural_name: :b, accidental: :sharp, octave: 2},
                               %{natural_name: :c,                     octave: 3})
      assert Pitch.enharmonic?(:b_sharp, :c)

      refute Pitch.enharmonic?(%{natural_name: :b, accidental: :sharp, octave: 3},
                               %{natural_name: :c,                     octave: 3})
    end

    test "correctly handles B-sharp and D-double-flat" do
      assert Pitch.enharmonic?(%{natural_name: :b, accidental: :sharp,       octave: 3},
                               %{natural_name: :d, accidental: :double_flat, octave: 4})
      assert Pitch.enharmonic?(:b_sharp, :d_double_flat)

      refute Pitch.enharmonic?(%{natural_name: :b, accidental: :sharp,       octave: 4},
                               %{natural_name: :d, accidental: :double_flat, octave: 4})
    end

    test "correctly handles B-double-sharp and D-flat" do
      assert Pitch.enharmonic?(%{natural_name: :b, accidental: :double_sharp, octave: 4},
                               %{natural_name: :d, accidental: :flat,         octave: 5})
      assert Pitch.enharmonic?(:b_double_sharp, :d_flat)

      refute Pitch.enharmonic?(%{natural_name: :b, accidental: :double_sharp, octave: 5},
                               %{natural_name: :d, accidental: :flat,         octave: 5})
    end

    test "correctly handles G-sharp and A-flat" do
      assert Pitch.enharmonic?(%{natural_name: :g, accidental: :sharp, octave: 5},
                               %{natural_name: :a, accidental: :flat,  octave: 5})
      assert Pitch.enharmonic?(:g_sharp, :a_flat)

      refute Pitch.enharmonic?(%{natural_name: :g, accidental: :sharp, octave: 5},
                               %{natural_name: :a, accidental: :flat,  octave: 6})
    end
  end

  describe ".enharmonics/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names,
          accidental <- @accidentals,
          octave <- @octaves do
        actual = Pitch.enharmonics(%{natural_name: natural_name,
                                     accidental: accidental,
                                     octave: octave})
        assert is_list(actual)
        assert actual |> Enum.all?(&is_map/1)
        refute actual |> Enum.any?(&(is_nil(&1.natural_name)))
        refute actual |> Enum.any?(&(is_nil(&1.accidental)))
        refute actual |> Enum.any?(&(is_nil(&1.octave)))
      end

      for natural_name <- @natural_names, accidental <- @accidentals do
        actual = Pitch.enharmonics(%{natural_name: natural_name,
                                     accidental: accidental})
        assert is_list(actual)
        assert actual |> Enum.all?(&is_map/1)
        refute actual |> Enum.any?(&(is_nil(&1.natural_name)))
        refute actual |> Enum.any?(&(is_nil(&1.accidental)))
        assert actual |> Enum.all?(&(is_nil(&1.octave)))

        actual = Pitch.enharmonics(:"#{natural_name}_#{accidental}")
        assert is_list(actual)
        assert actual |> Enum.all?(&is_atom/1)
      end

      for natural_name <- @natural_names, octave <- @octaves do
        actual = Pitch.enharmonics(%{natural_name: natural_name, octave: octave})
        assert is_list(actual)
        assert actual |> Enum.all?(&is_map/1)
        refute actual |> Enum.any?(&(is_nil(&1.natural_name)))
        refute actual |> Enum.any?(&(is_nil(&1.accidental)))
        refute actual |> Enum.any?(&(is_nil(&1.octave)))
      end

      for natural_name <- @natural_names do
        actual = Pitch.enharmonics(%{natural_name: natural_name})
        assert is_list(actual)
        assert actual |> Enum.all?(&is_map/1)
        refute actual |> Enum.any?(&(is_nil(&1.natural_name)))
        refute actual |> Enum.any?(&(is_nil(&1.accidental)))
        assert actual |> Enum.all?(&(is_nil(&1.octave)))

        actual = Pitch.enharmonics(natural_name)
        assert is_list(actual)
        assert actual |> Enum.all?(&is_atom/1)
      end
    end

    test "correctly handles A-sharp" do
      expected = [%Pitch{          natural_name: :b, accidental: :flat,        octave: -2},
                  %Pitch{          natural_name: :c, accidental: :double_flat, octave: -1}]
      actual = Pitch.enharmonics(%{natural_name: :a, accidental: :sharp,       octave: -2})
      assert actual == expected

      expected = [:b_flat, :c_double_flat]
      actual = Pitch.enharmonics(:a_sharp)
      assert actual == expected
    end

    test "correctly handles B-flat" do
      expected = [%Pitch{          natural_name: :a, accidental: :sharp,       octave: 0},
                  %Pitch{          natural_name: :c, accidental: :double_flat, octave: 1}]
      actual = Pitch.enharmonics(%{natural_name: :b, accidental: :flat,        octave: 0})
      assert actual == expected

      expected = [:a_sharp, :c_double_flat]
      actual = Pitch.enharmonics(:b_flat)
      assert actual == expected
    end

    test "correctly handles A-double-sharp" do
      expected = [%Pitch{          natural_name: :b, accidental: :natural,      octave: 1},
                  %Pitch{          natural_name: :c, accidental: :flat,         octave: 2}]
      actual = Pitch.enharmonics(%{natural_name: :a, accidental: :double_sharp, octave: 1})
      assert actual == expected

      expected = [:b_natural, :c_flat]
      actual = Pitch.enharmonics(:a_double_sharp)
      assert actual == expected
    end

    test "correctly handles B-natural" do
      expected = [%Pitch{          natural_name: :a, accidental: :double_sharp, octave: 2},
                  %Pitch{          natural_name: :c, accidental: :flat,         octave: 3}]
      actual = Pitch.enharmonics(%{natural_name: :b,                            octave: 2})
      assert actual == expected

      expected = [:a_double_sharp, :c_flat]
      actual = Pitch.enharmonics(:b)
      assert actual == expected
    end

    test "correctly handles B-sharp" do
      expected = [%Pitch{          natural_name: :c, accidental: :natural,     octave: 4},
                  %Pitch{          natural_name: :d, accidental: :double_flat, octave: 4}]
      actual = Pitch.enharmonics(%{natural_name: :b, accidental: :sharp,       octave: 3})
      assert actual == expected

      expected = [:c_natural, :d_double_flat]
      actual = Pitch.enharmonics(:b_sharp)
      assert actual == expected
    end

    test "correctly handles B-double-sharp" do
      expected = [%Pitch{          natural_name: :c, accidental: :sharp,        octave: 5},
                  %Pitch{          natural_name: :d, accidental: :flat,         octave: 5}]
      actual = Pitch.enharmonics(%{natural_name: :b, accidental: :double_sharp, octave: 4})
      assert actual == expected

      expected = [:c_sharp, :d_flat]
      actual = Pitch.enharmonics(:b_double_sharp)
      assert actual == expected
    end

    test "correctly handles G-sharp" do
      expected = [%Pitch{          natural_name: :a, accidental: :flat,  octave: 5}]
      actual = Pitch.enharmonics(%{natural_name: :g, accidental: :sharp, octave: 5})
      assert actual == expected

      expected = [:a_flat]
      actual = Pitch.enharmonics(:g_sharp)
      assert actual == expected
    end
  end

  describe ".interval/2" do
    test "correctly handles pitches" do
      expected = %Interval{quality: :diminished, size: 10}
      actual = Pitch.interval(%{natural_name: :a, accidental: :sharp, octave: 4},
                              %{natural_name: :c,                     octave: 6})
      assert actual == expected

      expected = %Interval{quality: :diminished, size: 3}

      actual = Pitch.interval(%{natural_name: :a, accidental: :sharp},
                              %{natural_name: :c})
      assert actual == expected

      actual = Pitch.interval(:a_sharp, %{natural_name: :c})
      assert actual == expected

      actual = Pitch.interval(%{natural_name: :a, accidental: :sharp}, :c)
      assert actual == expected

      actual = Pitch.interval(:a_sharp, :c)
      assert actual == expected

      expected = %Interval{quality: :doubly_diminished, size: 4}
      actual = Pitch.interval(:a_flat, :e_sharp)
      assert actual == expected

      expected = %Interval{quality: :perfect, size: 1}
      actual = Pitch.interval(:a, :a)
      assert actual == expected
    end

    test "rejects an invalid interval" do
      expected = {:error, "Invalid interval"}

      for octave1 <- @octaves, octave2 <- @octaves do
        actual = Pitch.interval(%{natural_name: :a,
                                  accidental: :flat,
                                  octave: octave1},
                                %{natural_name: :e,
                                  accidental: :double_sharp,
                                  octave: octave2})
        assert actual == expected
      end

      for octave <- @octaves do
        actual = Pitch.interval(%{natural_name: :a,
                                  accidental: :flat,
                                  octave: octave},
                                %{natural_name: :e, accidental: :double_sharp})
        assert actual == expected

        actual = Pitch.interval(%{natural_name: :a,
                                  accidental: :flat,
                                  octave: octave},
                                :e_double_sharp)
        assert actual == expected

        actual = Pitch.interval(%{natural_name: :a, accidental: :flat},
                                %{natural_name: :e,
                                  accidental: :double_sharp,
                                  octave: octave})
        assert actual == expected

        actual = Pitch.interval(:a_flat,
                                %{natural_name: :e,
                                  accidental: :double_sharp,
                                  octave: octave})
        assert actual == expected
      end

      actual = Pitch.interval(%{natural_name: :a, accidental: :flat},
                              %{natural_name: :e, accidental: :double_sharp})
      assert actual == expected

      actual = Pitch.interval(%{natural_name: :a, accidental: :flat},
                              :e_double_sharp)
      assert actual == expected

      actual = Pitch.interval(:a_flat,
                              %{natural_name: :e, accidental: :double_sharp})
      assert actual == expected

      actual = Pitch.interval(:a_flat, :e_double_sharp)
      assert actual == expected
    end
  end

  describe ".name/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names,
          accidental <- @accidentals,
          octave <- @octaves do
        expected = :"#{natural_name}_#{accidental}"
        actual = Pitch.name(%{natural_name: natural_name,
                              accidental: accidental,
                              octave: octave})
        assert actual == expected
      end

      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = :"#{natural_name}_#{accidental}"

        actual = Pitch.name(%{natural_name: natural_name,
                              accidental: accidental})
        assert actual == expected

        actual = Pitch.name(expected)
        assert actual == expected
      end

      for natural_name <- @natural_names, octave <- @octaves do
        expected = :"#{natural_name}_natural"
        actual = Pitch.name(%{natural_name: natural_name, octave: octave})
        assert actual == expected
      end

      for natural_name <- @natural_names do
        expected = :"#{natural_name}_natural"

        actual = Pitch.name(%{natural_name: natural_name})
        assert actual == expected

        actual = Pitch.name(natural_name)
        assert actual == expected
      end
    end
  end

  describe ".natural_name/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names,
          accidental <- @accidentals,
          octave <- @octaves do
        expected = natural_name
        actual = Pitch.natural_name(%{natural_name: natural_name,
                                      accidental: accidental,
                                      octave: octave})
        assert actual == expected
      end

      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = natural_name

        actual = Pitch.natural_name(%{natural_name: natural_name,
                                      accidental: accidental})
        assert actual == expected

        actual = Pitch.natural_name(:"#{natural_name}_#{accidental}")
        assert actual == expected
      end

      for natural_name <- @natural_names do
        expected = natural_name

        actual = Pitch.natural_name(%{natural_name: natural_name})
        assert actual == expected

        actual = Pitch.natural_name(natural_name)
        assert actual == expected
      end
    end
  end

  describe ".new/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names,
          accidental <- @accidentals,
          octave <- @octaves do
        expected = %Pitch{natural_name: natural_name,
                          accidental: accidental,
                          octave: octave}

        actual = Pitch.new(%{natural_name: natural_name,
                             accidental: accidental,
                             octave: octave})
        assert actual == expected
      end

      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = %Pitch{natural_name: natural_name, accidental: accidental}

        actual = Pitch.new(%{natural_name: natural_name, accidental: accidental})
        assert actual == expected

        actual = Pitch.new(:"#{natural_name}_#{accidental}")
        assert actual == expected
      end

      for natural_name <- @natural_names, octave <- @octaves do
        expected = %Pitch{natural_name: natural_name, octave: octave}

        actual = Pitch.new(%{natural_name: natural_name, octave: octave})
        assert actual == expected
      end

      for natural_name <- @natural_names do
        expected = %Pitch{natural_name: natural_name}

        actual = Pitch.new(%{natural_name: natural_name})
        assert actual == expected

        actual = Pitch.new(natural_name)
        assert actual == expected
      end
    end
  end

  describe ".new/2" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names,
          accidental <- @accidentals,
          octave <- @octaves do
        expected = %Pitch{natural_name: natural_name,
                          accidental: accidental,
                          octave: octave}
        actual = Pitch.new(:"#{natural_name}_#{accidental}", octave)
        assert actual == expected
      end

      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = %Pitch{natural_name: natural_name, accidental: accidental}
        actual = Pitch.new(natural_name, accidental)
        assert actual == expected
      end

      for natural_name <- @natural_names, octave <- @octaves do
        expected = %Pitch{natural_name: natural_name, octave: octave}
        actual = Pitch.new(natural_name, octave)
        assert actual == expected
      end

      for natural_name <- @natural_names do
        expected = %Pitch{natural_name: natural_name}
        actual = Pitch.new(natural_name, nil)
        assert actual == expected
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      for accidental <- @accidentals, octave <- @octaves do
        actual = Pitch.new(:"h_#{accidental}", octave)
        assert actual == expected
      end

      for accidental <- @accidentals do
        actual = Pitch.new(:h, accidental)
        assert actual == expected
      end
    end

    test "rejects an invalid accidental/octave" do
      expected = {:error, @invalid_accidental_or_octave}

      for natural_name <- @natural_names do
        actual = Pitch.new(natural_name, :out_of_tune)
        assert actual == expected
      end
    end

    test "rejects an invalid octave" do
      expected = {:error, @invalid_octave}

      for natural_name <- @natural_names, accidental <- @accidentals do
        actual = Pitch.new(:"#{natural_name}_#{accidental}", :not_an_octave)
        assert actual == expected
      end
    end
  end

  describe ".new/3" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names,
          accidental <- @accidentals,
          octave <- @octaves do
        expected = %Pitch{natural_name: natural_name,
                          accidental: accidental,
                          octave: octave}
        actual = Pitch.new(natural_name, accidental, octave)
        assert actual == expected
      end

      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = %Pitch{natural_name: natural_name, accidental: accidental}
        actual = Pitch.new(natural_name, accidental, nil)
        assert actual == expected
      end
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      for natural_name <- @natural_names, octave <- @octaves do
        actual = Pitch.new(natural_name, :out_of_tune, octave)
        assert actual == expected

        actual = Pitch.new(natural_name, nil, octave)
        assert actual == expected
      end
    end

    test "rejects an invalid octave" do
      expected = {:error, @invalid_octave}

      for natural_name <- @natural_names, accidental <- @accidentals do
        actual = Pitch.new(natural_name, accidental, :not_an_octave)
        assert actual == expected
      end
    end
  end

  describe ".octave/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names,
          accidental <- @accidentals,
          octave <- @octaves do
        expected = octave
        actual = Pitch.octave(%{natural_name: natural_name,
                                accidental: accidental,
                                octave: octave})
        assert actual == expected
      end

      for natural_name <- @natural_names, accidental <- @accidentals do
        actual = Pitch.octave(%{natural_name: natural_name,
                                accidental: accidental})
        assert actual |> is_nil
      end

      for natural_name <- @natural_names do
        actual = Pitch.octave(%{natural_name: natural_name})
        assert actual |> is_nil

        actual = Pitch.octave(natural_name)
        assert actual |> is_nil
      end
    end
  end

  describe ".semitones/2" do
    test "accepts valid arguments" do
      for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
          natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1,
                                   octave: octave1},
                                 %{natural_name: natural_name2,
                                   accidental: accidental2,
                                   octave: octave2})
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1,
                                   octave: octave1},
                                 %{natural_name: natural_name2,
                                   accidental: accidental2})
        assert is_integer(actual)

        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1,
                                   octave: octave1},
                                 :"#{natural_name2}_#{accidental2}")
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
          natural_name2 <- @natural_names,                              octave2 <- @octaves do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1,
                                   octave: octave1},
                                 %{natural_name: natural_name2, octave: octave2})
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
          natural_name2 <- @natural_names do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1,
                                   octave: octave1},
                                 %{natural_name: natural_name2})
        assert is_integer(actual)

        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1,
                                   octave: octave1},
                                 natural_name2)
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1},
                                 %{natural_name: natural_name2,
                                   accidental: accidental2,
                                   octave: octave2})
        assert is_integer(actual)

        actual = Pitch.semitones(:"#{natural_name1}_#{accidental1}",
                                 %{natural_name: natural_name2,
                                   accidental: accidental2,
                                   octave: octave2})
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1},
                                 %{natural_name: natural_name2,
                                   accidental: accidental2})
        assert is_integer(actual)

        actual = Pitch.semitones(:"#{natural_name1}_#{accidental1}",
                                 %{natural_name: natural_name2,
                                   accidental: accidental2})
        assert is_integer(actual)

        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1},
                                 :"#{natural_name2}_#{accidental2}")
        assert is_integer(actual)

        actual = Pitch.semitones(:"#{natural_name1}_#{accidental1}",
                                 :"#{natural_name2}_#{accidental2}")
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          natural_name2 <- @natural_names,                              octave2 <- @octaves do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1},
                                 %{natural_name: natural_name2, octave: octave2})
        assert is_integer(actual)

        actual = Pitch.semitones(:"#{natural_name1}_#{accidental1}",
                                 %{natural_name: natural_name2, octave: octave2})
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          natural_name2 <- @natural_names do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1},
                                 %{natural_name: natural_name2})
        assert is_integer(actual)

        actual = Pitch.semitones(:"#{natural_name1}_#{accidental1}",
                                 %{natural_name: natural_name2})
        assert is_integer(actual)

        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1},
                                 natural_name2)
        assert is_integer(actual)

        actual = Pitch.semitones(:"#{natural_name1}_#{accidental1}",
                                 natural_name2)
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names,                              octave1 <- @octaves,
          natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
        actual = Pitch.semitones(%{natural_name: natural_name1, octave: octave1},
                                 %{natural_name: natural_name2,
                                   accidental: accidental2,
                                   octave: octave2})
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names,                              octave1 <- @octaves,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.semitones(%{natural_name: natural_name1, octave: octave1},
                                 %{natural_name: natural_name2,
                                   accidental: accidental2})
        assert is_integer(actual)

        actual = Pitch.semitones(%{natural_name: natural_name1, octave: octave1},
                                 :"#{natural_name2}_#{accidental2}")
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names, octave1 <- @octaves,
          natural_name2 <- @natural_names, octave2 <- @octaves do
        actual = Pitch.semitones(%{natural_name: natural_name1, octave: octave1},
                                 %{natural_name: natural_name2, octave: octave2})
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names, octave1 <- @octaves,
          natural_name2 <- @natural_names do
        actual = Pitch.semitones(%{natural_name: natural_name1, octave: octave1},
                                 %{natural_name: natural_name2})
        assert is_integer(actual)

        actual = Pitch.semitones(%{natural_name: natural_name1, octave: octave1},
                                 natural_name2)
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names,
          natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
        actual = Pitch.semitones(%{natural_name: natural_name1},
                                 %{natural_name: natural_name2,
                                   accidental: accidental2,
                                   octave: octave2})
        assert is_integer(actual)

        actual = Pitch.semitones(natural_name1,
                                 %{natural_name: natural_name2,
                                   accidental: accidental2,
                                   octave: octave2})
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.semitones(%{natural_name: natural_name1},
                                 %{natural_name: natural_name2,
                                   accidental: accidental2})
        assert is_integer(actual)

        actual = Pitch.semitones(natural_name1,
                                 %{natural_name: natural_name2,
                                   accidental: accidental2})
        assert is_integer(actual)

        actual = Pitch.semitones(%{natural_name: natural_name1},
                                 :"#{natural_name2}_#{accidental2}")
        assert is_integer(actual)

        actual = Pitch.semitones(natural_name1,
                                 :"#{natural_name2}_#{accidental2}")
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names,
          natural_name2 <- @natural_names, octave2 <- @octaves do
        actual = Pitch.semitones(%{natural_name: natural_name1},
                                 %{natural_name: natural_name2, octave: octave2})
        assert is_integer(actual)

        actual = Pitch.semitones(natural_name1,
                                 %{natural_name: natural_name2, octave: octave2})
        assert is_integer(actual)
      end

      for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
        actual = Pitch.semitones(%{natural_name: natural_name1},
                                 %{natural_name: natural_name2})
        assert is_integer(actual)

        actual = Pitch.semitones(natural_name1, %{natural_name: natural_name2})
        assert is_integer(actual)

        actual = Pitch.semitones(%{natural_name: natural_name1}, natural_name2)
        assert is_integer(actual)

        actual = Pitch.semitones(natural_name1, natural_name2)
        assert is_integer(actual)
      end
    end

    test "correctly handles pitches" do
      expected = 17
      actual = Harmonex.Pitch.semitones(%{natural_name: :a, accidental: :flat,  octave: 4},
                                        %{natural_name: :c, accidental: :sharp, octave: 6})
      assert actual == expected
      actual = Harmonex.Pitch.semitones(%{natural_name: :c, accidental: :sharp, octave: 6},
                                        %{natural_name: :a, accidental: :flat,  octave: 4})
      assert actual == expected

      expected = 14
      actual = Harmonex.Pitch.semitones(%{natural_name: :g, octave: 4},
                                        %{natural_name: :a, octave: 5})
      assert actual == expected
      actual = Harmonex.Pitch.semitones(%{natural_name: :a, octave: 5},
                                        %{natural_name: :g, octave: 4})
      assert actual == expected

      expected = 2
      actual = Harmonex.Pitch.semitones(:b_flat, :a_flat)
      assert actual == expected

      expected = 3
      actual = Harmonex.Pitch.semitones(:d_double_sharp, :b_double_sharp)
      assert actual == expected

      expected = 0
      actual = Harmonex.Pitch.semitones(:c, :c)
      assert actual == expected
    end
  end

  # Functions that accept one pitch argument
  for {fun, other_arguments} <- [accidental: [],
                                 adjust_by_semitones: [1],
                                 enharmonics: [],
                                 name: [],
                                 natural_name: [],
                                 new: [],
                                 octave: []] do
    describe ".#{fun}/#{1 + length(other_arguments)}" do
      test "rejects an invalid name" do
        expected = {:error, @invalid_name}

        for natural_name <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name}_out_of_tune" |
                                   unquote(other_arguments)])
          assert actual == expected
        end

        for accidental <- @accidentals, octave <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h,
                                     accidental: accidental,
                                     octave: octave} |
                                   unquote(other_arguments)])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental, octave: octave} |
                                   unquote(other_arguments)])
          assert actual == expected
        end

        for accidental <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, accidental: accidental} |
                                   unquote(other_arguments)])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental} |
                                   unquote(other_arguments)])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"h_#{accidental}" |
                                   unquote(other_arguments)])
          assert actual == expected
        end

        for octave <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, octave: octave} |
                                   unquote(other_arguments)])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{octave: octave} | unquote(other_arguments)])
          assert actual == expected
        end

        actual = Pitch |> apply(unquote(fun),
                                [%{natural_name: :h} | unquote(other_arguments)])
        assert actual == expected

        actual = Pitch |> apply(unquote(fun), [:h | unquote(other_arguments)])
        assert actual == expected
      end

      test "rejects an invalid accidental" do
        expected = {:error, @invalid_accidental}

        for natural_name <- @natural_names, octave <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name,
                                     accidental: :out_of_tune,
                                     octave: octave} |
                                   unquote(other_arguments)])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name,
                                     accidental: nil,
                                     octave: octave} |
                                   unquote(other_arguments)])
          assert actual == expected
        end

        for natural_name <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name,
                                     accidental: :out_of_tune} |
                                   unquote(other_arguments)])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name,
                                     accidental: nil} |
                                   unquote(other_arguments)])
          assert actual == expected
        end
      end

      test "rejects an invalid octave" do
        expected = {:error, @invalid_octave}

        for natural_name <- @natural_names, accidental <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name,
                                     accidental: accidental,
                                     octave: :not_an_octave} |
                                   unquote(other_arguments)])
          assert actual == expected
        end

        for natural_name <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name,
                                     octave: :not_an_octave} |
                                   unquote(other_arguments)])
          assert actual == expected
        end
      end
    end
  end

  # Functions that accept two pitch arguments
  for fun <- ~w( enharmonic? interval semitones )a do
    describe ".#{fun}/2" do
      test "rejects an invalid name in the first argument" do
        expected = {:error, @invalid_name}

        for natural_name1 <- @natural_names,
            natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_out_of_tune",
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected
        end

        for                                  accidental1 <- @accidentals, octave1 <- @octaves,
            natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1, octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected
        end

        for                                  accidental1 <- @accidentals, octave1 <- @octaves,
            natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1, octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h,
                                     accidental: accidental1,
                                     octave: octave1},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1, octave: octave1},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected
        end

        for                                  accidental1 <- @accidentals, octave1 <- @octaves,
            natural_name2 <- @natural_names,                              octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1, octave: octave1},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected
        end

        for                                  accidental1 <- @accidentals, octave1 <- @octaves,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1, octave: octave1},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h,
                                     accidental: accidental1,
                                     octave: octave1},
                                   natural_name2])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1, octave: octave1},
                                   natural_name2])
          assert actual == expected
        end

        for                                  accidental1 <- @accidentals,
            natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"h_#{accidental1}",
                                  %{natural_name: natural_name2,
                                    accidental: accidental2,
                                    octave: octave2}])
          assert actual == expected
        end

        for                                  accidental1 <- @accidentals,
            natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, accidental: accidental1},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"h_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"h_#{accidental1}",
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected
        end

        for                                  accidental1 <- @accidentals,
            natural_name2 <- @natural_names,                              octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"h_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected
        end

        for                                  accidental1 <- @accidentals,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, accidental: accidental1},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, accidental: accidental1},
                                   natural_name2])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{accidental: accidental1}, natural_name2])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"h_#{accidental1}",
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"h_#{accidental1}", natural_name2])
          assert actual == expected
        end

        for                                                               octave1 <- @octaves,
            natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected
        end

        for                                                               octave1 <- @octaves,
            natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, octave: octave1},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{octave: octave1},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected
        end

        for                                  octave1 <- @octaves,
            natural_name2 <- @natural_names, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, octave: octave1},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{octave: octave1},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected
        end

        for                                  octave1 <- @octaves,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, octave: octave1},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{octave: octave1},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h, octave: octave1},
                                   natural_name2])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{octave: octave1}, natural_name2])
          assert actual == expected
        end

        for natural_name2 <- @natural_names,
            accidental2 <- @accidentals,
            octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:h,
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{}, :"#{natural_name2}_#{accidental2}"])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:h,
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:h, :"#{natural_name2}_#{accidental2}"])
          assert actual == expected
        end

        for natural_name2 <- @natural_names, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:h,
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{}, %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: :h}, natural_name2])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun), [%{}, natural_name2])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:h, %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun), [:h, natural_name2])
          assert actual == expected
        end
      end

      test "rejects an invalid name in the second argument" do
        expected = {:error, @invalid_name}

        for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   :"#{natural_name2}_out_of_tune"])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
                                             accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: :h,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{accidental: accidental2, octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals,
                                             accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: :h,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{accidental: accidental2, octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: :h,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                     %{accidental: accidental2, octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,                              octave1 <- @octaves,
                                             accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: :h,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{accidental: accidental2, octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
                                             accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{natural_name: :h,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{accidental: accidental2, octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1,
                                   %{natural_name: :h,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1,
                                   %{accidental: accidental2, octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
                                             accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: :h, accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   :"h_#{accidental2}"])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals,
                                             accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: :h, accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   :"h_#{accidental2}"])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: :h, accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   :"h_#{accidental2}"])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,                              octave1 <- @octaves,
                                             accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: :h, accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   :"h_#{accidental2}"])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
                                             accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{natural_name: :h, accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   :"h_#{accidental2}"])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1,
                                   %{natural_name: :h, accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1, %{accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1, :"h_#{accidental2}"])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
                                                                          octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: :h, octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals,
                                                                          octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: :h, octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: :h, octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, octave1 <- @octaves,
                                             octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: :h, octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
                                             octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{natural_name: :h, octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1,
                                   %{natural_name: :h, octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1, %{octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
            accidental1 <- @accidentals,
            octave1 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: :h}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   :h])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: :h}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: :h}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}", %{}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   :h])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}", :h])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, octave1 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: :h}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   :h])
          assert actual == expected
        end

        for natural_name1 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{natural_name: :h}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1}, %{}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1, %{natural_name: :h}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun), [natural_name1, %{}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1}, :h])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun), [natural_name1, :h])
          assert actual == expected
        end
      end

      test "rejects an invalid accidental in the first argument" do
        expected = {:error, @invalid_accidental}

        for natural_name1 <- @natural_names,                              octave1 <- @octaves,
            natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,                              octave1 <- @octaves,
            natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune,
                                     octave: octave1},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil,
                                     octave: octave1},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, octave1 <- @octaves,
            natural_name2 <- @natural_names, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, octave1 <- @octaves,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune,
                                     octave: octave1},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil,
                                     octave: octave1},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune,
                                     octave: octave1},
                                   natural_name2])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil,
                                     octave: octave1},
                                   natural_name2])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
            natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
            natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
            natural_name2 <- @natural_names, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: :out_of_tune},
                                   natural_name2])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: nil},
                                   natural_name2])
          assert actual == expected
        end
      end

      test "rejects an invalid accidental in the second argument" do
        expected = {:error, @invalid_accidental}

        for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
            natural_name2 <- @natural_names,                              octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: nil,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals,
            natural_name2 <- @natural_names,                              octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: nil,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     accidental: nil,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, octave1 <- @octaves,
            natural_name2 <- @natural_names, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: nil,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
            natural_name2 <- @natural_names, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{natural_name: natural_name2,
                                     accidental: nil,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1,
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune,
                                     octave: octave2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1,
                                   %{natural_name: natural_name2,
                                     accidental: nil,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: nil}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: nil}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     accidental: nil}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, octave1 <- @octaves,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: nil}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{natural_name: natural_name2,
                                     accidental: nil}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1,
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1,
                                   %{natural_name: natural_name2,
                                     accidental: nil}])
          assert actual == expected
        end
      end

      test "rejects an invalid octave in the first argument" do
        expected = {:error, @invalid_octave}

        for natural_name1 <- @natural_names, accidental1 <- @accidentals,
            natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: :not_an_octave},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals,
            natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: :not_an_octave},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: :not_an_octave},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals,
            natural_name2 <- @natural_names,                              octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: :not_an_octave},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: :not_an_octave},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: :not_an_octave},
                                   natural_name2])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
            natural_name2 <- @natural_names, accidental2 <- @accidentals, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: :not_an_octave},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
            natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: :not_an_octave},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: :not_an_octave},
                                   :"#{natural_name2}_#{accidental2}"])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
            natural_name2 <- @natural_names, octave2 <- @octaves do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: :not_an_octave},
                                   %{natural_name: natural_name2,
                                     octave: octave2}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: :not_an_octave},
                                   %{natural_name: natural_name2}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: :not_an_octave},
                                   natural_name2])
          assert actual == expected
        end
      end

      test "rejects an invalid octave in the second argument" do
        expected = {:error, @invalid_octave}

        for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
            natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: :not_an_octave}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals,
            natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: :not_an_octave}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: :not_an_octave}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,                              octave1 <- @octaves,
            natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: :not_an_octave}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names,
            natural_name2 <- @natural_names, accidental2 <- @accidentals do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: :not_an_octave}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1,
                                   %{natural_name: natural_name2,
                                     accidental: accidental2,
                                     octave: :not_an_octave}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals, octave1 <- @octaves,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     octave: :not_an_octave}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     octave: :not_an_octave}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, accidental1 <- @accidentals,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     octave: :not_an_octave}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     octave: :not_an_octave}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, octave1 <- @octaves,
            natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1,
                                     octave: octave1},
                                   %{natural_name: natural_name2,
                                     octave: :not_an_octave}])
          assert actual == expected
        end

        for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
          actual = Pitch |> apply(unquote(fun),
                                  [%{natural_name: natural_name1},
                                   %{natural_name: natural_name2,
                                     octave: :not_an_octave}])
          assert actual == expected

          actual = Pitch |> apply(unquote(fun),
                                  [natural_name1,
                                   %{natural_name: natural_name2, octave: :not_an_octave}])
          assert actual == expected
        end
      end
    end
  end
end
