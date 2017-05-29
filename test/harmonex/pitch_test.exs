defmodule Harmonex.PitchTest do
  use ExUnit.Case, async: true
  doctest Harmonex.Pitch

  @natural_names ~w(a b c d e f g)a
  @accidentals ~w(double_flat flat natural sharp double_sharp)a

  @invalid_name "Invalid pitch name -- must be in #{inspect @natural_names}"
  @invalid_accidental "Invalid accidental -- must be in #{inspect @accidentals}"

  describe ".adjust_by_semitones/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        actual = Harmonex.Pitch.adjust_by_semitones(%{natural_name: natural_name,
                                                      accidental: accidental},
                                                    1)
        assert is_map(actual)

        name = :"#{to_string natural_name}_#{to_string accidental}"
        actual = Harmonex.Pitch.adjust_by_semitones(name, 1)
        assert is_atom(actual)
      end

      for natural_name <- @natural_names do
        actual = Harmonex.Pitch.adjust_by_semitones(%{natural_name: natural_name}, 1)
        assert is_map(actual)

        actual = Harmonex.Pitch.adjust_by_semitones(natural_name, 1)
        assert is_atom(actual)
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.adjust_by_semitones(%Harmonex.Pitch{natural_name: :h,
                                                                  accidental: :flat},
                                                  1)
      assert actual == expected

      actual = Harmonex.Pitch.adjust_by_semitones(%Harmonex.Pitch{natural_name: :h},
                                                  1)
      assert actual == expected

      actual = Harmonex.Pitch.adjust_by_semitones(:h_flat, 1)
      assert actual == expected

      actual = Harmonex.Pitch.adjust_by_semitones(:h, 1)
      assert actual == expected

      actual = Harmonex.Pitch.adjust_by_semitones(:a_out_of_tune, 1)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      actual = Harmonex.Pitch.adjust_by_semitones(%Harmonex.Pitch{natural_name: :a,
                                                                  accidental: :out_of_tune},
                                                  1)
      assert actual == expected
    end
  end

  describe ".accidental/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = accidental

        actual = Harmonex.Pitch.accidental(%{natural_name: natural_name,
                                             accidental: accidental})
        assert actual == expected

        name = :"#{to_string natural_name}_#{to_string accidental}"
        actual = Harmonex.Pitch.accidental(name)
        assert actual == expected
      end

      for natural_name <- @natural_names do
        expected = :natural

        actual = Harmonex.Pitch.accidental(%{natural_name: natural_name})
        assert actual == expected

        actual = Harmonex.Pitch.accidental(natural_name)
        assert actual == expected
      end

      for accidental <- @accidentals do
        expected = accidental
        actual = Harmonex.Pitch.accidental(%{accidental: accidental})
        assert actual == expected
      end
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      actual = Harmonex.Pitch.accidental(%Harmonex.Pitch{natural_name: :a,
                                                         accidental: :out_of_tune})
      assert actual == expected

      actual = Harmonex.Pitch.accidental(%Harmonex.Pitch{accidental: :out_of_tune})
      assert actual == expected
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}
      actual = Harmonex.Pitch.accidental(:a_out_of_tune)
      assert actual == expected
    end
  end

  describe ".natural_name/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = natural_name

        actual = Harmonex.Pitch.natural_name(%{natural_name: natural_name,
                                               accidental: accidental})
        assert actual == expected

        name = :"#{to_string natural_name}_#{to_string accidental}"
        actual = Harmonex.Pitch.natural_name(name)
        assert actual == expected
      end

      for natural_name <- @natural_names do
        expected = natural_name

        actual = Harmonex.Pitch.natural_name(%{natural_name: natural_name})
        assert actual == expected

        actual = Harmonex.Pitch.natural_name(natural_name)
        assert actual == expected
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.natural_name(%Harmonex.Pitch{natural_name: :h,
                                                           accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.natural_name(%Harmonex.Pitch{natural_name: :h})
      assert actual == expected

      actual = Harmonex.Pitch.natural_name(:h_flat)
      assert actual == expected

      actual = Harmonex.Pitch.natural_name(:h)
      assert actual == expected
    end
  end

  describe ".enharmonic?/2" do
    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.enharmonic?(%Harmonex.Pitch{natural_name: :h,
                                                          accidental: :flat},
                                          :a)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(%Harmonex.Pitch{natural_name: :h}, :a)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:h_flat, :a)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:h, :a)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:a_out_of_tune, :a)
      assert actual == expected
    end

    test "rejects an invalid accidental in the first argument" do
      expected = {:error, @invalid_accidental}

      actual = Harmonex.Pitch.enharmonic?(%Harmonex.Pitch{natural_name: :a,
                                                          accidental: :out_of_tune},
                                          :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.enharmonic?(:a,
                                          %Harmonex.Pitch{natural_name: :h,
                                                          accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:a, %Harmonex.Pitch{natural_name: :h})
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:a, :h_flat)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:a, :h)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:a, :a_out_of_tune)
      assert actual == expected
    end

    test "rejects an invalid accidental in the second argument" do
      expected = {:error, @invalid_accidental}

      actual = Harmonex.Pitch.enharmonic?(:a,
                                          %Harmonex.Pitch{natural_name: :a,
                                                          accidental: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".enharmonics/1" do
    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.enharmonics(%Harmonex.Pitch{natural_name: :h,
                                                          accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.enharmonics(%Harmonex.Pitch{natural_name: :h})
      assert actual == expected

      actual = Harmonex.Pitch.enharmonics(:h_flat)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonics(:h)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonics(:a_out_of_tune)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      actual = Harmonex.Pitch.enharmonics(%Harmonex.Pitch{natural_name: :a,
                                                          accidental: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".interval/2" do
    test "accepts valid arguments" do
      expected = %Harmonex.Interval{quality: :diminished, size: 3}

      actual = Harmonex.Pitch.interval(%{natural_name: :a,
                                         accidental: :sharp}, :c)
      assert actual == expected

      actual = Harmonex.Pitch.interval(:a_sharp, %{natural_name: :c})
      assert actual == expected
    end

    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.interval(%Harmonex.Pitch{natural_name: :h,
                                                       accidental: :flat},
                                       :a)
      assert actual == expected

      actual = Harmonex.Pitch.interval(%Harmonex.Pitch{natural_name: :h}, :a)
      assert actual == expected

      actual = Harmonex.Pitch.interval(:h_flat, :a)
      assert actual == expected

      actual = Harmonex.Pitch.interval(:h, :a)
      assert actual == expected

      actual = Harmonex.Pitch.interval(:a_out_of_tune, :a)
      assert actual == expected
    end

    test "rejects an invalid accidental in the first argument" do
      expected = {:error, @invalid_accidental}

      actual = Harmonex.Pitch.interval(%Harmonex.Pitch{natural_name: :a,
                                                       accidental: :out_of_tune},
                                       :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.interval(:a,
                                       %Harmonex.Pitch{natural_name: :h,
                                                       accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.interval(:a, %Harmonex.Pitch{natural_name: :h})
      assert actual == expected

      actual = Harmonex.Pitch.interval(:a, :h_flat)
      assert actual == expected

      actual = Harmonex.Pitch.interval(:a, :h)
      assert actual == expected

      actual = Harmonex.Pitch.interval(:a, :a_out_of_tune)
      assert actual == expected
    end

    test "rejects an invalid accidental in the second argument" do
      expected = {:error, @invalid_accidental}

      actual = Harmonex.Pitch.interval(:a,
                                        %Harmonex.Pitch{natural_name: :a,
                                                        accidental: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".name/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = :"#{to_string natural_name}_#{to_string accidental}"

        actual = Harmonex.Pitch.name(%{natural_name: natural_name,
                                       accidental: accidental})
        assert actual == expected

        actual = Harmonex.Pitch.name(expected)
        assert actual == expected
      end

      for natural_name <- @natural_names do
        expected = :"#{to_string natural_name}_natural"

        actual = Harmonex.Pitch.name(%{natural_name: natural_name})
        assert actual == expected

        actual = Harmonex.Pitch.name(natural_name)
        assert actual == expected
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.name(%Harmonex.Pitch{natural_name: :h,
                                                   accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.name(%Harmonex.Pitch{natural_name: :h})
      assert actual == expected

      actual = Harmonex.Pitch.name(:h_flat)
      assert actual == expected

      actual = Harmonex.Pitch.name(:h)
      assert actual == expected

      actual = Harmonex.Pitch.name(:a_out_of_tune)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      actual = Harmonex.Pitch.name(%Harmonex.Pitch{natural_name: :a,
                                                   accidental: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".new/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = %Harmonex.Pitch{natural_name: natural_name,
                                   accidental: accidental}

        actual = Harmonex.Pitch.new(%{natural_name: natural_name,
                                      accidental: accidental})
        assert actual == expected

        name = :"#{to_string natural_name}_#{to_string accidental}"
        actual = Harmonex.Pitch.new(name)
        assert actual == expected
      end

      for natural_name <- @natural_names do
        expected = %Harmonex.Pitch{natural_name: natural_name,
                                   accidental: :natural}

        actual = Harmonex.Pitch.new(%{natural_name: natural_name})
        assert actual == expected

        actual = Harmonex.Pitch.new(natural_name)
        assert actual == expected
      end
    end
  end

  describe ".new/2" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = %Harmonex.Pitch{natural_name: natural_name,
                                   accidental: accidental}
        actual = Harmonex.Pitch.new(natural_name, accidental)
        assert actual == expected
      end
    end
  end

  describe ".semitones/2" do
    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.semitones(%Harmonex.Pitch{natural_name: :h,
                                                        accidental: :flat},
                                        :a)
      assert actual == expected

      actual = Harmonex.Pitch.semitones(%Harmonex.Pitch{natural_name: :h}, :a)
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:h_flat, :a)
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:h, :a)
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:a_out_of_tune, :a)
      assert actual == expected
    end

    test "rejects an invalid accidental in the first argument" do
      expected = {:error, @invalid_accidental}

      actual = Harmonex.Pitch.semitones(%Harmonex.Pitch{natural_name: :a,
                                                        accidental: :out_of_tune},
                                        :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.semitones(:a,
                                        %Harmonex.Pitch{natural_name: :h,
                                                        accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:a, %Harmonex.Pitch{natural_name: :h})
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:a, :h_flat)
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:a, :h)
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:a, :a_out_of_tune)
      assert actual == expected
    end

    test "rejects an invalid accidental in the second argument" do
      expected = {:error, @invalid_accidental}

      actual = Harmonex.Pitch.semitones(:a,
                                        %Harmonex.Pitch{natural_name: :a,
                                                        accidental: :out_of_tune})
      assert actual == expected
    end
  end
end
