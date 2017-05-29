defmodule Harmonex.PitchTest do
  use ExUnit.Case, async: true
  doctest Harmonex.Pitch

  @bare_names  ~w(a b c d e f g)a
  @accidentals ~w(double_flat flat natural sharp double_sharp)a

  @invalid_name "Invalid pitch name -- must be in #{inspect @bare_names}"
  @invalid_accidental "Invalid accidental -- must be in #{inspect @accidentals}"

  describe ".adjust_by_semitones/1" do
    test "accepts valid arguments" do
      for bare_name <- @bare_names, accidental <- @accidentals do
        actual = Harmonex.Pitch.adjust_by_semitones(%{bare_name: bare_name,
                                                      accidental: accidental},
                                                    1)
        assert is_map(actual)

        full_name = :"#{to_string bare_name}_#{to_string accidental}"
        actual = Harmonex.Pitch.adjust_by_semitones(full_name, 1)
        assert is_atom(actual)
      end

      for bare_name <- @bare_names do
        actual = Harmonex.Pitch.adjust_by_semitones(%{bare_name: bare_name}, 1)
        assert is_map(actual)

        actual = Harmonex.Pitch.adjust_by_semitones(bare_name, 1)
        assert is_atom(actual)
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.adjust_by_semitones(%Harmonex.Pitch{bare_name: :h,
                                                                  accidental: :flat},
                                                  1)
      assert actual == expected

      actual = Harmonex.Pitch.adjust_by_semitones(%Harmonex.Pitch{bare_name: :h},
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

      actual = Harmonex.Pitch.adjust_by_semitones(%Harmonex.Pitch{bare_name: :a,
                                                                  accidental: :out_of_tune},
                                                  1)
      assert actual == expected
    end
  end

  describe ".accidental/1" do
    test "accepts valid arguments" do
      for bare_name <- @bare_names, accidental <- @accidentals do
        expected = accidental

        actual = Harmonex.Pitch.accidental(%{bare_name: bare_name,
                                             accidental: accidental})
        assert actual == expected

        full_name = :"#{to_string bare_name}_#{to_string accidental}"
        actual = Harmonex.Pitch.accidental(full_name)
        assert actual == expected
      end

      for bare_name <- @bare_names do
        expected = :natural

        actual = Harmonex.Pitch.accidental(%{bare_name: bare_name})
        assert actual == expected

        actual = Harmonex.Pitch.accidental(bare_name)
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

      actual = Harmonex.Pitch.accidental(%Harmonex.Pitch{bare_name: :a,
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

  describe ".bare_name/1" do
    test "accepts valid arguments" do
      for bare_name <- @bare_names, accidental <- @accidentals do
        expected = bare_name

        actual = Harmonex.Pitch.bare_name(%{bare_name: bare_name,
                                            accidental: accidental})
        assert actual == expected

        full_name = :"#{to_string bare_name}_#{to_string accidental}"
        actual = Harmonex.Pitch.bare_name(full_name)
        assert actual == expected
      end

      for bare_name <- @bare_names do
        expected = bare_name

        actual = Harmonex.Pitch.bare_name(%{bare_name: bare_name})
        assert actual == expected

        actual = Harmonex.Pitch.bare_name(bare_name)
        assert actual == expected
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.bare_name(%Harmonex.Pitch{bare_name: :h,
                                                        accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.bare_name(%Harmonex.Pitch{bare_name: :h})
      assert actual == expected

      actual = Harmonex.Pitch.bare_name(:h_flat)
      assert actual == expected

      actual = Harmonex.Pitch.bare_name(:h)
      assert actual == expected
    end
  end

  describe ".enharmonic?/2" do
    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.enharmonic?(%Harmonex.Pitch{bare_name: :h,
                                                          accidental: :flat},
                                          :a)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(%Harmonex.Pitch{bare_name: :h}, :a)
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

      actual = Harmonex.Pitch.enharmonic?(%Harmonex.Pitch{bare_name: :a,
                                                          accidental: :out_of_tune},
                                          :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.enharmonic?(:a,
                                          %Harmonex.Pitch{bare_name: :h,
                                                          accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:a, %Harmonex.Pitch{bare_name: :h})
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
                                          %Harmonex.Pitch{bare_name: :a,
                                                          accidental: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".enharmonics/1" do
    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.enharmonics(%Harmonex.Pitch{bare_name: :h,
                                                          accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.enharmonics(%Harmonex.Pitch{bare_name: :h})
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

      actual = Harmonex.Pitch.enharmonics(%Harmonex.Pitch{bare_name: :a,
                                                          accidental: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".full_name/1" do
    test "accepts valid arguments" do
      for bare_name <- @bare_names, accidental <- @accidentals do
        expected = :"#{to_string bare_name}_#{to_string accidental}"

        actual = Harmonex.Pitch.full_name(%{bare_name: bare_name,
                                            accidental: accidental})
        assert actual == expected

        actual = Harmonex.Pitch.full_name(expected)
        assert actual == expected
      end

      for bare_name <- @bare_names do
        expected = :"#{to_string bare_name}_natural"

        actual = Harmonex.Pitch.full_name(%{bare_name: bare_name})
        assert actual == expected

        actual = Harmonex.Pitch.full_name(bare_name)
        assert actual == expected
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.full_name(%Harmonex.Pitch{bare_name: :h,
                                                        accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.full_name(%Harmonex.Pitch{bare_name: :h})
      assert actual == expected

      actual = Harmonex.Pitch.full_name(:h_flat)
      assert actual == expected

      actual = Harmonex.Pitch.full_name(:h)
      assert actual == expected

      actual = Harmonex.Pitch.full_name(:a_out_of_tune)
      assert actual == expected
    end

    test "rejects an invalid accidental" do
      expected = {:error, @invalid_accidental}

      actual = Harmonex.Pitch.full_name(%Harmonex.Pitch{bare_name: :a,
                                                        accidental: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".interval/2" do
    test "accepts valid arguments" do
      expected = %Harmonex.Interval{quality: :diminished, size: 3}

      actual = Harmonex.Pitch.interval(%{bare_name: :a, accidental: :sharp}, :c)
      assert actual == expected

      actual = Harmonex.Pitch.interval(:a_sharp, %{bare_name: :c})
      assert actual == expected
    end

    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.interval(%Harmonex.Pitch{bare_name: :h,
                                                       accidental: :flat},
                                       :a)
      assert actual == expected

      actual = Harmonex.Pitch.interval(%Harmonex.Pitch{bare_name: :h}, :a)
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

      actual = Harmonex.Pitch.interval(%Harmonex.Pitch{bare_name: :a,
                                                       accidental: :out_of_tune},
                                       :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.interval(:a,
                                       %Harmonex.Pitch{bare_name: :h,
                                                       accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.interval(:a, %Harmonex.Pitch{bare_name: :h})
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
                                        %Harmonex.Pitch{bare_name: :a,
                                                        accidental: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".new/1" do
    test "accepts valid arguments" do
      for bare_name <- @bare_names, accidental <- @accidentals do
        expected = %Harmonex.Pitch{bare_name: bare_name,
                                   accidental: accidental}

        actual = Harmonex.Pitch.new(%{bare_name: bare_name,
                                      accidental: accidental})
        assert actual == expected

        full_name = :"#{to_string bare_name}_#{to_string accidental}"
        actual = Harmonex.Pitch.new(full_name)
        assert actual == expected
      end

      for bare_name <- @bare_names do
        expected = %Harmonex.Pitch{bare_name: bare_name, accidental: :natural}

        actual = Harmonex.Pitch.new(%{bare_name: bare_name})
        assert actual == expected

        actual = Harmonex.Pitch.new(bare_name)
        assert actual == expected
      end
    end
  end

  describe ".new/2" do
    test "accepts valid arguments" do
      for bare_name <- @bare_names, accidental <- @accidentals do
        expected = %Harmonex.Pitch{bare_name: bare_name,
                                   accidental: accidental}
        actual = Harmonex.Pitch.new(bare_name, accidental)
        assert actual == expected
      end
    end
  end

  describe ".semitones/2" do
    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.semitones(%Harmonex.Pitch{bare_name: :h,
                                                        accidental: :flat},
                                        :a)
      assert actual == expected

      actual = Harmonex.Pitch.semitones(%Harmonex.Pitch{bare_name: :h}, :a)
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

      actual = Harmonex.Pitch.semitones(%Harmonex.Pitch{bare_name: :a,
                                                        accidental: :out_of_tune},
                                        :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.semitones(:a,
                                        %Harmonex.Pitch{bare_name: :h,
                                                        accidental: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:a, %Harmonex.Pitch{bare_name: :h})
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
                                        %Harmonex.Pitch{bare_name: :a,
                                                        accidental: :out_of_tune})
      assert actual == expected
    end
  end
end
