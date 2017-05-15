defmodule Harmonex.PitchTest do
  use ExUnit.Case, async: true
  doctest Harmonex.Pitch

  @bare_names  ~w(a b c d e f g)a
  @alterations ~w(double_flat flat natural sharp double_sharp)a

  @invalid_name "Invalid pitch name -- must be in #{inspect @bare_names}"
  @invalid_alteration "Invalid pitch alteration -- must be in #{inspect @alterations}"

  describe ".alteration/1" do
    test "accepts valid arguments" do
      for bare_name <- @bare_names do
        for alteration <- @alterations do
          expected = alteration

          actual = Harmonex.Pitch.alteration(%{bare_name: bare_name,
                                               alteration: alteration})
          assert actual == expected

          full_name = :"#{to_string bare_name}_#{to_string alteration}"
          actual = Harmonex.Pitch.alteration(full_name)
          assert actual == expected
        end

        expected = :natural

        actual = Harmonex.Pitch.alteration(%{bare_name: bare_name})
        assert actual == expected

        actual = Harmonex.Pitch.alteration(bare_name)
        assert actual == expected
      end

      for alteration <- @alterations do
        expected = alteration
        actual = Harmonex.Pitch.alteration(%{alteration: alteration})
        assert actual == expected
      end
    end

    test "rejects an invalid alteration" do
      expected = {:error, @invalid_alteration}

      actual = Harmonex.Pitch.alteration(%Harmonex.Pitch{bare_name: :a,
                                                         alteration: :out_of_tune})
      assert actual == expected

      actual = Harmonex.Pitch.alteration(%Harmonex.Pitch{alteration: :out_of_tune})
      assert actual == expected
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}
      actual = Harmonex.Pitch.alteration(:a_out_of_tune)
      assert actual == expected
    end
  end

  describe ".bare_name/1" do
    test "accepts valid arguments" do
      for bare_name <- @bare_names do
        expected = bare_name

        for alteration <- @alterations do
          actual = Harmonex.Pitch.bare_name(%{bare_name: bare_name,
                                              alteration: alteration})
          assert actual == expected

          full_name = :"#{to_string bare_name}_#{to_string alteration}"
          actual = Harmonex.Pitch.bare_name(full_name)
          assert actual == expected
        end

        actual = Harmonex.Pitch.bare_name(%{bare_name: bare_name})
        assert actual == expected

        actual = Harmonex.Pitch.bare_name(bare_name)
        assert actual == expected
      end
    end

    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.bare_name(%Harmonex.Pitch{bare_name: :h,
                                                        alteration: :flat})
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
                                                          alteration: :flat},
                                          :a)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(%Harmonex.Pitch{bare_name: :h}, :a)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:h_flat, :a)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:h, :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.enharmonic?(:a,
                                          %Harmonex.Pitch{bare_name: :h,
                                                          alteration: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:a, %Harmonex.Pitch{bare_name: :h})
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:a, :h_flat)
      assert actual == expected

      actual = Harmonex.Pitch.enharmonic?(:a, :h)
      assert actual == expected
    end
  end

  describe ".enharmonics/1" do
    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.enharmonics(%Harmonex.Pitch{bare_name: :h,
                                                          alteration: :flat})
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

    test "rejects an invalid alteration" do
      expected = {:error, @invalid_alteration}

      actual = Harmonex.Pitch.enharmonics(%Harmonex.Pitch{bare_name: :a,
                                                          alteration: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".full_name/1" do
    test "rejects an invalid name" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.full_name(%Harmonex.Pitch{bare_name: :h,
                                                        alteration: :flat})
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

    test "rejects an invalid alteration" do
      expected = {:error, @invalid_alteration}

      actual = Harmonex.Pitch.full_name(%Harmonex.Pitch{bare_name: :a,
                                                        alteration: :out_of_tune})
      assert actual == expected
    end
  end

  describe ".interval_diatonic/2" do
    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.interval_diatonic(%Harmonex.Pitch{bare_name: :h,
                                                                alteration: :flat},
                                                :a)
      assert actual == expected

      actual = Harmonex.Pitch.interval_diatonic(%Harmonex.Pitch{bare_name: :h},
                                                :a)
      assert actual == expected

      actual = Harmonex.Pitch.interval_diatonic(:h_flat, :a)
      assert actual == expected

      actual = Harmonex.Pitch.interval_diatonic(:h, :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.interval_diatonic(:a,
                                                %Harmonex.Pitch{bare_name: :h,
                                                                alteration: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.interval_diatonic(:a,
                                                %Harmonex.Pitch{bare_name: :h})
      assert actual == expected

      actual = Harmonex.Pitch.interval_diatonic(:a, :h_flat)
      assert actual == expected

      actual = Harmonex.Pitch.interval_diatonic(:a, :h)
      assert actual == expected
    end
  end

  describe ".semitones/2" do
    test "rejects an invalid name in the first argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.semitones(%Harmonex.Pitch{bare_name: :h,
                                                        alteration: :flat},
                                        :a)
      assert actual == expected

      actual = Harmonex.Pitch.semitones(%Harmonex.Pitch{bare_name: :h}, :a)
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:h_flat, :a)
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:h, :a)
      assert actual == expected
    end

    test "rejects an invalid name in the second argument" do
      expected = {:error, @invalid_name}

      actual = Harmonex.Pitch.semitones(:a,
                                        %Harmonex.Pitch{bare_name: :h,
                                                        alteration: :flat})
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:a, %Harmonex.Pitch{bare_name: :h})
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:a, :h_flat)
      assert actual == expected

      actual = Harmonex.Pitch.semitones(:a, :h)
      assert actual == expected
    end
  end
end
