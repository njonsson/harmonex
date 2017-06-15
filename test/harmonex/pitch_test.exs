defmodule Harmonex.PitchTest do
  use ExUnit.Case, async: true

  alias Harmonex.Pitch

  doctest Pitch

  @natural_names ~w(a b c d e f g)a
  @accidentals ~w(double_flat flat natural sharp double_sharp)a

  @invalid_name "Invalid pitch name -- must be in #{inspect @natural_names}"
  @invalid_accidental "Invalid accidental -- must be in #{inspect @accidentals}"

  describe ".accidental/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        actual = Pitch.accidental(%{natural_name: natural_name,
                                    accidental: accidental})
        assert actual == accidental

        actual = Pitch.accidental(:"#{natural_name}_#{accidental}")
        assert actual == accidental
      end

      for natural_name <- @natural_names do
        actual = Pitch.accidental(%{natural_name: natural_name})
        assert actual == :natural

        actual = Pitch.accidental(natural_name)
        assert actual == :natural
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      for natural_name <- @natural_names do
        actual = Pitch.accidental(:"#{natural_name}_out_of_tune")
        assert actual == expected
      end

      for accidental <- @accidentals do
        actual = Pitch.accidental(%{natural_name: :h, accidental: accidental})
        assert actual == expected

        actual = Pitch.accidental(%{accidental: accidental})
        assert actual == expected

        actual = Pitch.accidental(:"h_#{accidental}")
        assert actual == expected
      end

      actual = Pitch.accidental(%{natural_name: :h})
      assert actual == expected

      actual = Pitch.accidental(:h)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      for natural_name <- @natural_names do
        actual = Pitch.accidental(%{natural_name: natural_name,
                                    accidental: :out_of_tune})
        assert actual == expected
      end
    end
  end

  describe ".adjust_by_semitones/2" do
    test "accepts valid arguments" do
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

      for natural_name <- @natural_names do
        actual = Pitch.adjust_by_semitones(%{natural_name: natural_name}, 1)
        assert is_map(actual)
        refute is_nil(actual.natural_name)
        refute is_nil(actual.accidental)

        actual = Pitch.adjust_by_semitones(natural_name, 1)
        assert is_atom(actual)
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      for natural_name <- @natural_names do
        actual = Pitch.adjust_by_semitones(:"#{natural_name}_out_of_tune", 1)
        assert actual == expected
      end

      for accidental <- @accidentals do
        actual = Pitch.adjust_by_semitones(%{natural_name: :h,
                                             accidental: accidental},
                                           1)
        assert actual == expected

        actual = Pitch.adjust_by_semitones(%{accidental: accidental}, 1)
        assert actual == expected

        actual = Pitch.adjust_by_semitones(:"h_#{accidental}", 1)
        assert actual == expected
      end

      actual = Pitch.adjust_by_semitones(%{natural_name: :h}, 1)
      assert actual == expected

      actual = Pitch.adjust_by_semitones(:h, 1)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      for natural_name <- @natural_names do
        actual = Pitch.adjust_by_semitones(%{natural_name: natural_name,
                                             accidental: :out_of_tune},
                                           1)
        assert actual == expected
      end
    end
  end

  describe ".enharmonic?/2" do
    test "accepts valid arguments" do
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

      for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1},
                                   %{natural_name: natural_name2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(natural_name1, %{natural_name: natural_name2})
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(%{natural_name: natural_name1}, natural_name2)
        assert is_boolean(actual)

        actual = Pitch.enharmonic?(natural_name1, natural_name2)
        assert is_boolean(actual)
      end
    end

    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      for accidental1 <- @accidentals,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.enharmonic?(%{natural_name: :h, accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2})
        assert actual == expected

        actual = Pitch.enharmonic?(:"h_#{accidental1}",
                                   %{natural_name: natural_name2,
                                     accidental: accidental2})
        assert actual == expected

        actual = Pitch.enharmonic?(%{natural_name: :h, accidental: accidental1},
                                   :"#{natural_name2}_#{accidental2}")
        assert actual == expected

        actual = Pitch.enharmonic?(:"h_#{accidental1}",
                                   :"#{natural_name2}_#{accidental2}")
        assert actual == expected
      end

      for accidental1 <- @accidentals, natural_name2 <- @natural_names do
        actual = Pitch.enharmonic?(%{natural_name: :h, accidental: accidental1},
                                   %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.enharmonic?(:"h_#{accidental1}",
                                   %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.enharmonic?(%{natural_name: :h, accidental: accidental1},
                                   natural_name2)
        assert actual == expected

        actual = Pitch.enharmonic?(:"h_#{accidental1}", natural_name2)
        assert actual == expected
      end

      for natural_name2 <- @natural_names do
        actual = Pitch.enharmonic?(%{natural_name: :h},
                                   %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.enharmonic?(:h, %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.enharmonic?(%{natural_name: :h}, natural_name2)
        assert actual == expected

        actual = Pitch.enharmonic?(:h, natural_name2)
        assert actual == expected
      end
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          accidental2 <- @accidentals do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   :"h_#{accidental2}")
        assert actual == expected

        actual = Pitch.enharmonic?(:"#{natural_name1}_#{accidental1}",
                                   %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.enharmonic?(:"#{natural_name1}_#{accidental1}",
                                   :"h_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1},
                                   %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.enharmonic?(%{natural_name: natural_name1},
                                   :"h_#{accidental2}")
        assert actual == expected

        actual = Pitch.enharmonic?(natural_name1,
                                   %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.enharmonic?(natural_name1, :"h_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @natural_names do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1},
                                   %{natural_name: :h})
        assert actual == expected

        actual = Pitch.enharmonic?(%{natural_name: natural_name1}, :h)
        assert actual == expected

        actual = Pitch.enharmonic?(natural_name1, %{natural_name: :h})
        assert actual == expected

        actual = Pitch.enharmonic?(natural_name1, :h)
        assert actual == expected
      end
    end

    test "rejects an invalid accidental in the first argument" do
      expected = {:error, @invalid_accidental}

      for natural_name1 <- @natural_names,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: :out_of_tune},
                                   %{natural_name: natural_name2,
                                     accidental: accidental2})
        assert actual == expected

        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: :out_of_tune},
                                   :"#{natural_name2}_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: :out_of_tune},
                                   %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: :out_of_tune},
                                   natural_name2)
        assert actual == expected
      end
    end

    test "rejects an invalid accidental in the second argument" do
      expected = {:error, @invalid_accidental}

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          natural_name2 <- @natural_names do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1,
                                     accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune})
        assert actual == expected
      end

      for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
        actual = Pitch.enharmonic?(%{natural_name: natural_name1},
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune})
        assert actual == expected

        actual = Pitch.enharmonic?(natural_name1,
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune})
        assert actual == expected
      end
    end
  end

  describe ".enharmonics/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        actual = Pitch.enharmonics(%{natural_name: natural_name,
                                     accidental: accidental})
        assert is_list(actual)
        assert actual |> Enum.all?(&is_map/1)

        actual = Pitch.enharmonics(:"#{natural_name}_#{accidental}")
        assert is_list(actual)
        assert actual |> Enum.all?(&is_atom/1)
      end

      for natural_name <- @natural_names do
        actual = Pitch.enharmonics(%{natural_name: natural_name})
        assert is_list(actual)
        assert actual |> Enum.all?(&is_map/1)
        refute actual |> Enum.any?(&(is_nil(&1.natural_name)))
        refute actual |> Enum.any?(&(is_nil(&1.accidental)))

        actual = Pitch.enharmonics(natural_name)
        assert is_list(actual)
        assert actual |> Enum.all?(&is_atom/1)
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      for natural_name <- @natural_names do
        actual = Pitch.enharmonics(:"#{natural_name}_out_of_tune")
        assert actual == expected
      end

      for accidental <- @accidentals do
        actual = Pitch.enharmonics(%{natural_name: :h, accidental: accidental})
        assert actual == expected

        actual = Pitch.enharmonics(%{accidental: accidental})
        assert actual == expected

        actual = Pitch.enharmonics(:"h_#{accidental}")
        assert actual == expected
      end

      actual = Pitch.enharmonics(%{natural_name: :h})
      assert actual == expected

      actual = Pitch.enharmonics(:h)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      for natural_name <- @natural_names do
        actual = Pitch.enharmonics(%{natural_name: natural_name,
                                     accidental: :out_of_tune})
        assert actual == expected
      end
    end
  end

  describe ".interval/2" do
    test "accepts valid arguments" do
      expected = %Harmonex.Interval{quality: :diminished, size: 3}

      actual = Pitch.interval(%{natural_name: :a, accidental: :sharp},
                              %{natural_name: :c})
      assert actual == expected

      actual = Pitch.interval(:a_sharp, %{natural_name: :c})
      assert actual == expected

      actual = Pitch.interval(%{natural_name: :a, accidental: :sharp}, :c)
      assert actual == expected

      actual = Pitch.interval(:a_sharp, :c)
      assert actual == expected
    end

    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      for accidental1 <- @accidentals,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.interval(%{natural_name: :h, accidental: accidental1},
                                %{natural_name: natural_name2,
                                  accidental: accidental2})
        assert actual == expected

        actual = Pitch.interval(:"h_#{accidental1}",
                                %{natural_name: natural_name2,
                                  accidental: accidental2})
        assert actual == expected

        actual = Pitch.interval(%{natural_name: :h, accidental: accidental1},
                                :"#{natural_name2}_#{accidental2}")
        assert actual == expected

        actual = Pitch.interval(:"h_#{accidental1}",
                                :"#{natural_name2}_#{accidental2}")
        assert actual == expected
      end

      for accidental1 <- @accidentals, natural_name2 <- @natural_names do
        actual = Pitch.interval(%{natural_name: :h, accidental: accidental1},
                                %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.interval(:"h_#{accidental1}",
                                %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.interval(%{natural_name: :h, accidental: accidental1},
                                natural_name2)
        assert actual == expected

        actual = Pitch.interval(:"h_#{accidental1}", natural_name2)
        assert actual == expected
      end

      for natural_name2 <- @natural_names do
        actual = Pitch.interval(%{natural_name: :h},
                                %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.interval(:h, %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.interval(%{natural_name: :h}, natural_name2)
        assert actual == expected

        actual = Pitch.interval(:h, natural_name2)
        assert actual == expected
      end
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          accidental2 <- @accidentals do
        actual = Pitch.interval(%{natural_name: natural_name1,
                                  accidental: accidental1},
                                %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.interval(%{natural_name: natural_name1,
                                  accidental: accidental1},
                                :"h_#{accidental2}")
        assert actual == expected

        actual = Pitch.interval(:"#{natural_name1}_#{accidental1}",
                                %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.interval(:"#{natural_name1}_#{accidental1}",
                                :"h_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.interval(%{natural_name: natural_name1},
                                %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.interval(%{natural_name: natural_name1},
                                :"h_#{accidental2}")
        assert actual == expected

        actual = Pitch.interval(natural_name1,
                                %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.interval(natural_name1, :"h_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @natural_names do
        actual = Pitch.interval(%{natural_name: natural_name1},
                                %{natural_name: :h})
        assert actual == expected

        actual = Pitch.interval(%{natural_name: natural_name1}, :h)
        assert actual == expected

        actual = Pitch.interval(natural_name1, %{natural_name: :h})
        assert actual == expected

        actual = Pitch.interval(natural_name1, :h)
        assert actual == expected
      end
    end

    test "rejects an invalid accidental in the first argument" do
      expected = {:error, @invalid_accidental}

      for natural_name1 <- @natural_names,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.interval(%{natural_name: natural_name1,
                                  accidental: :out_of_tune},
                                %{natural_name: natural_name2,
                                  accidental: accidental2})
        assert actual == expected

        actual = Pitch.interval(%{natural_name: natural_name1,
                                  accidental: :out_of_tune},
                                :"#{natural_name2}_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
        actual = Pitch.interval(%{natural_name: natural_name1,
                                  accidental: :out_of_tune},
                                %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.interval(%{natural_name: natural_name1,
                                  accidental: :out_of_tune},
                                natural_name2)
        assert actual == expected
      end
    end

    test "rejects an invalid accidental in the second argument" do
      expected = {:error, @invalid_accidental}

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          natural_name2 <- @natural_names do
        actual = Pitch.interval(%{natural_name: natural_name1,
                                  accidental: accidental1},
                                %{natural_name: natural_name2,
                                  accidental: :out_of_tune})
        assert actual == expected
      end

      for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
        actual = Pitch.interval(%{natural_name: natural_name1},
                                %{natural_name: natural_name2,
                                  accidental: :out_of_tune})
        assert actual == expected

        actual = Pitch.interval(natural_name1,
                                %{natural_name: natural_name2,
                                  accidental: :out_of_tune})
        assert actual == expected
      end
    end

    test "rejects an invalid interval" do
      expected = {:error, "Invalid interval"}
      actual = Pitch.interval(:a_flat, :e_double_sharp)
      assert actual == expected
    end
  end

  describe ".name/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = :"#{natural_name}_#{accidental}"

        actual = Pitch.name(%{natural_name: natural_name,
                              accidental: accidental})
        assert actual == expected

        actual = Pitch.name(expected)
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

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      for natural_name <- @natural_names do
        actual = Pitch.name(:"#{natural_name}_out_of_tune")
        assert actual == expected
      end

      for accidental <- @accidentals do
        actual = Pitch.name(%{natural_name: :h, accidental: accidental})
        assert actual == expected

        actual = Pitch.name(%{accidental: accidental})
        assert actual == expected

        actual = Pitch.name(:"h_#{accidental}")
        assert actual == expected
      end

      actual = Pitch.name(%{natural_name: :h})
      assert actual == expected

      actual = Pitch.name(:h)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      for natural_name <- @natural_names do
        actual = Pitch.name(%{natural_name: natural_name,
                              accidental: :out_of_tune})
        assert actual == expected
      end
    end
  end

  describe ".natural_name/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = natural_name

        actual = Pitch.natural_name(%{natural_name: natural_name,
                                      accidental: accidental})
        assert actual == expected

        actual = Pitch.natural_name(expected)
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

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      for natural_name <- @natural_names do
        actual = Pitch.natural_name(:"#{natural_name}_out_of_tune")
        assert actual == expected
      end

      for accidental <- @accidentals do
        actual = Pitch.natural_name(%{natural_name: :h, accidental: accidental})
        assert actual == expected

        actual = Pitch.natural_name(%{accidental: accidental})
        assert actual == expected

        actual = Pitch.natural_name(:"h_#{accidental}")
        assert actual == expected
      end

      actual = Pitch.natural_name(%{natural_name: :h})
      assert actual == expected

      actual = Pitch.natural_name(:h)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      for natural_name <- @natural_names do
        actual = Pitch.natural_name(%{natural_name: natural_name,
                                      accidental: :out_of_tune})
        assert actual == expected
      end
    end
  end

  describe ".new/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = %Pitch{natural_name: natural_name, accidental: accidental}

        actual = Pitch.new(%{natural_name: natural_name, accidental: accidental})
        assert actual == expected

        actual = Pitch.new(:"#{natural_name}_#{accidental}")
        assert actual == expected
      end

      for natural_name <- @natural_names do
        expected = %Pitch{natural_name: natural_name, accidental: :natural}

        actual = Pitch.new(%{natural_name: natural_name})
        assert actual == expected

        actual = Pitch.new(natural_name)
        assert actual == expected
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      for natural_name <- @natural_names do
        actual = Pitch.new(:"#{natural_name}_out_of_tune")
        assert actual == expected
      end

      for accidental <- @accidentals do
        actual = Pitch.new(%{natural_name: :h, accidental: accidental})
        assert actual == expected

        actual = Pitch.new(%{accidental: accidental})
        assert actual == expected

        actual = Pitch.new(:"h_#{accidental}")
        assert actual == expected
      end

      actual = Pitch.new(%{natural_name: :h})
      assert actual == expected

      actual = Pitch.new(:h)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      for natural_name <- @natural_names do
        actual = Pitch.new(%{natural_name: natural_name,
                             accidental: :out_of_tune})
        assert actual == expected
      end
    end
  end

  describe ".new/2" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = %Pitch{natural_name: natural_name, accidental: accidental}
        actual = Pitch.new(natural_name, accidental)
        assert actual == expected
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      for accidental <- @accidentals do
        actual = Pitch.new(:h, accidental)
        assert actual == expected
      end
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      for natural_name <- @natural_names do
        actual = Pitch.new(natural_name, :out_of_tune)
        assert actual == expected
      end
    end
  end

  describe ".semitones/2" do
    test "accepts valid arguments" do
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

    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      for accidental1 <- @accidentals,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.semitones(%{natural_name: :h, accidental: accidental1},
                                 %{natural_name: natural_name2,
                                   accidental: accidental2})
        assert actual == expected

        actual = Pitch.semitones(:"h_#{accidental1}",
                                 %{natural_name: natural_name2,
                                   accidental: accidental2})
        assert actual == expected

        actual = Pitch.semitones(%{natural_name: :h, accidental: accidental1},
                                 :"#{natural_name2}_#{accidental2}")
        assert actual == expected

        actual = Pitch.semitones(:"h_#{accidental1}",
                                 :"#{natural_name2}_#{accidental2}")
        assert actual == expected
      end

      for accidental1 <- @accidentals, natural_name2 <- @natural_names do
        actual = Pitch.semitones(%{natural_name: :h, accidental: accidental1},
                                 %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.semitones(:"h_#{accidental1}",
                                 %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.semitones(%{natural_name: :h, accidental: accidental1},
                                 natural_name2)
        assert actual == expected

        actual = Pitch.semitones(:"h_#{accidental1}", natural_name2)
        assert actual == expected
      end

      for natural_name2 <- @natural_names do
        actual = Pitch.semitones(%{natural_name: :h},
                                 %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.semitones(:h, %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.semitones(%{natural_name: :h}, natural_name2)
        assert actual == expected

        actual = Pitch.semitones(:h, natural_name2)
        assert actual == expected
      end
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          accidental2 <- @accidentals do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1},
                                 %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1},
                                 :"h_#{accidental2}")
        assert actual == expected

        actual = Pitch.semitones(:"#{natural_name1}_#{accidental1}",
                                 %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.semitones(:"#{natural_name1}_#{accidental1}",
                                 :"h_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.semitones(%{natural_name: natural_name1},
                                 %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.semitones(%{natural_name: natural_name1},
                                 :"h_#{accidental2}")
        assert actual == expected

        actual = Pitch.semitones(natural_name1,
                                 %{natural_name: :h, accidental: accidental2})
        assert actual == expected

        actual = Pitch.semitones(natural_name1, :"h_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @natural_names do
        actual = Pitch.semitones(%{natural_name: natural_name1},
                                 %{natural_name: :h})
        assert actual == expected

        actual = Pitch.semitones(%{natural_name: natural_name1}, :h)
        assert actual == expected

        actual = Pitch.semitones(natural_name1, %{natural_name: :h})
        assert actual == expected

        actual = Pitch.semitones(natural_name1, :h)
        assert actual == expected
      end
    end

    test "rejects an invalid accidental in the first argument" do
      expected = {:error, @invalid_accidental}

      for natural_name1 <- @natural_names,
          natural_name2 <- @natural_names, accidental2 <- @accidentals do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: :out_of_tune},
                                 %{natural_name: natural_name2,
                                   accidental: accidental2})
        assert actual == expected

        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: :out_of_tune},
                                 :"#{natural_name2}_#{accidental2}")
        assert actual == expected
      end

      for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: :out_of_tune},
                                 %{natural_name: natural_name2})
        assert actual == expected

        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: :out_of_tune},
                                 natural_name2)
        assert actual == expected
      end
    end

    test "rejects an invalid accidental in the second argument" do
      expected = {:error, @invalid_accidental}

      for natural_name1 <- @natural_names, accidental1 <- @accidentals,
          natural_name2 <- @natural_names do
        actual = Pitch.semitones(%{natural_name: natural_name1,
                                   accidental: accidental1},
                                   %{natural_name: natural_name2,
                                     accidental: :out_of_tune})
        assert actual == expected
      end

      for natural_name1 <- @natural_names, natural_name2 <- @natural_names do
        actual = Pitch.semitones(%{natural_name: natural_name1},
                                 %{natural_name: natural_name2,
                                   accidental: :out_of_tune})
        assert actual == expected

        actual = Pitch.semitones(natural_name1,
                                 %{natural_name: natural_name2,
                                   accidental: :out_of_tune})
        assert actual == expected
      end
    end
  end
end
