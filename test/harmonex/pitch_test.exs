defmodule Harmonex.PitchTest do
  use ExUnit.Case, async: true

  alias Harmonex.{Interval,Pitch}

  doctest Pitch

  @natural_names ~w(a b c d e f g)a
  @accidentals ~w(double_flat flat natural sharp double_sharp)a

  @invalid_name "Invalid pitch name -- must be in #{inspect @natural_names}"
  @invalid_accidental "Invalid accidental -- must be in #{inspect @accidentals}"

  describe ".accidental/1" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = accidental

        actual = Pitch.accidental(%{natural_name: natural_name,
                                    accidental: accidental})
        assert actual == expected

        actual = Pitch.accidental(:"#{natural_name}_#{accidental}")
        assert actual == expected
      end

      for natural_name <- @natural_names do
        expected = :natural

        actual = Pitch.accidental(%{natural_name: natural_name})
        assert actual == expected

        actual = Pitch.accidental(natural_name)
        assert actual == expected
      end

      for accidental <- @accidentals do
        expected = accidental
        actual = Pitch.accidental(%{accidental: accidental})
        assert actual == expected
      end
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      actual = Pitch.accidental(%{natural_name: :a, accidental: :out_of_tune})
      assert actual == expected

      actual = Pitch.accidental(%{accidental: :out_of_tune})
      assert actual == expected
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}
      actual = Pitch.accidental(:a_out_of_tune)
      assert actual == expected
    end
  end

  describe ".adjust_by_semitones/2" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        actual = Pitch.adjust_by_semitones(%{natural_name: natural_name,
                                             accidental: accidental},
                                           1)
        assert is_map(actual)

        actual = Pitch.adjust_by_semitones(:"#{natural_name}_#{accidental}", 1)
        assert is_atom(actual)
      end

      for natural_name <- @natural_names do
        actual = Pitch.adjust_by_semitones(%{natural_name: natural_name}, 1)
        assert is_map(actual)

        actual = Pitch.adjust_by_semitones(natural_name, 1)
        assert is_atom(actual)
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Pitch.adjust_by_semitones(%{natural_name: :h, accidental: :flat},
                                         1)
      assert actual == expected

      actual = Pitch.adjust_by_semitones(%{natural_name: :h}, 1)
      assert actual == expected

      actual = Pitch.adjust_by_semitones(:h_flat, 1)
      assert actual == expected

      actual = Pitch.adjust_by_semitones(:h, 1)
      assert actual == expected

      actual = Pitch.adjust_by_semitones(:a_out_of_tune, 1)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      actual = Pitch.adjust_by_semitones(%{natural_name: :a,
                                           accidental: :out_of_tune},
                                         1)
      assert actual == expected
    end
  end

  describe ".enharmonic?/2" do
    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      actual = Pitch.enharmonic?(%{natural_name: :h, accidental: :flat}, :a)
      assert actual == expected

      actual = Pitch.enharmonic?(%{natural_name: :h}, :a)
      assert actual == expected

      actual = Pitch.enharmonic?(:h_flat, :a)
      assert actual == expected

      actual = Pitch.enharmonic?(:h, :a)
      assert actual == expected

      actual = Pitch.enharmonic?(:a_out_of_tune, :a)
      assert actual == expected
    end

    test "rejects an invalid accidental in the first argument" do
      expected = {:error, @invalid_accidental}

      actual = Pitch.enharmonic?(%{natural_name: :a, accidental: :out_of_tune},
                                 :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Pitch.enharmonic?(:a, %{natural_name: :h, accidental: :flat})
      assert actual == expected

      actual = Pitch.enharmonic?(:a, %{natural_name: :h})
      assert actual == expected

      actual = Pitch.enharmonic?(:a, :h_flat)
      assert actual == expected

      actual = Pitch.enharmonic?(:a, :h)
      assert actual == expected

      actual = Pitch.enharmonic?(:a, :a_out_of_tune)
      assert actual == expected
    end

    test "rejects an invalid accidental in the second argument" do
      expected = {:error, @invalid_accidental}

      actual = Pitch.enharmonic?(:a,
                                 %{natural_name: :a, accidental: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".enharmonics/1" do
    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Pitch.enharmonics(%{natural_name: :h, accidental: :flat})
      assert actual == expected

      actual = Pitch.enharmonics(%{natural_name: :h})
      assert actual == expected

      actual = Pitch.enharmonics(:h_flat)
      assert actual == expected

      actual = Pitch.enharmonics(:h)
      assert actual == expected

      actual = Pitch.enharmonics(:a_out_of_tune)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      actual = Pitch.enharmonics(%{natural_name: :a, accidental: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".interval/2" do
    test "accepts valid arguments" do
      expected = %Interval{quality: :diminished, size: 3}

      actual = Pitch.interval(%{natural_name: :a, accidental: :sharp}, :c)
      assert actual == expected

      actual = Pitch.interval(:a_sharp, %{natural_name: :c})
      assert actual == expected
    end

    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      actual = Pitch.interval(%{natural_name: :h, accidental: :flat}, :a)
      assert actual == expected

      actual = Pitch.interval(%{natural_name: :h}, :a)
      assert actual == expected

      actual = Pitch.interval(:h_flat, :a)
      assert actual == expected

      actual = Pitch.interval(:h, :a)
      assert actual == expected

      actual = Pitch.interval(:a_out_of_tune, :a)
      assert actual == expected
    end

    test "rejects an invalid accidental in the first argument" do
      expected = {:error, @invalid_accidental}

      actual = Pitch.interval(%{natural_name: :a, accidental: :out_of_tune}, :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Pitch.interval(:a, %{natural_name: :h, accidental: :flat})
      assert actual == expected

      actual = Pitch.interval(:a, %{natural_name: :h})
      assert actual == expected

      actual = Pitch.interval(:a, :h_flat)
      assert actual == expected

      actual = Pitch.interval(:a, :h)
      assert actual == expected

      actual = Pitch.interval(:a, :a_out_of_tune)
      assert actual == expected
    end

    test "rejects an invalid accidental in the second argument" do
      expected = {:error, @invalid_accidental}

      actual = Pitch.interval(:a, %{natural_name: :a, accidental: :out_of_tune})
      assert actual == expected
    end

    test "recognizes an invalid interval" do
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

      actual = Pitch.name(%{natural_name: :h, accidental: :flat})
      assert actual == expected

      actual = Pitch.name(%{natural_name: :h})
      assert actual == expected

      actual = Pitch.name(:h_flat)
      assert actual == expected

      actual = Pitch.name(:h)
      assert actual == expected

      actual = Pitch.name(:a_out_of_tune)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      actual = Pitch.name(%{natural_name: :a, accidental: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".natural_name/1" do
    test "accepts valid arguments" do
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

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Pitch.natural_name(%{natural_name: :h, accidental: :flat})
      assert actual == expected

      actual = Pitch.natural_name(%{natural_name: :h})
      assert actual == expected

      actual = Pitch.natural_name(:h_flat)
      assert actual == expected

      actual = Pitch.natural_name(:h)
      assert actual == expected
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
  end

  describe ".new/2" do
    test "accepts valid arguments" do
      for natural_name <- @natural_names, accidental <- @accidentals do
        expected = %Pitch{natural_name: natural_name, accidental: accidental}
        actual = Pitch.new(natural_name, accidental)
        assert actual == expected
      end
    end
  end

  describe ".semitones/2" do
    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      actual = Pitch.semitones(%{natural_name: :h, accidental: :flat}, :a)
      assert actual == expected

      actual = Pitch.semitones(%{natural_name: :h}, :a)
      assert actual == expected

      actual = Pitch.semitones(:h_flat, :a)
      assert actual == expected

      actual = Pitch.semitones(:h, :a)
      assert actual == expected

      actual = Pitch.semitones(:a_out_of_tune, :a)
      assert actual == expected
    end

    test "rejects an invalid accidental in the first argument" do
      expected = {:error, @invalid_accidental}

      actual = Pitch.semitones(%{natural_name: :a, accidental: :out_of_tune}, :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Pitch.semitones(:a, %{natural_name: :h, accidental: :flat})
      assert actual == expected

      actual = Pitch.semitones(:a, %{natural_name: :h})
      assert actual == expected

      actual = Pitch.semitones(:a, :h_flat)
      assert actual == expected

      actual = Pitch.semitones(:a, :h)
      assert actual == expected

      actual = Pitch.semitones(:a, :a_out_of_tune)
      assert actual == expected
    end

    test "rejects an invalid accidental in the second argument" do
      expected = {:error, @invalid_accidental}

      actual = Pitch.semitones(:a, %{natural_name: :a, accidental: :out_of_tune})
      assert actual == expected
    end
  end
end
