defmodule Harmonex.OrdinalTest do
  use ExUnit.Case, async: true
  doctest Harmonex.Ordinal

  describe ".to_integer/1" do
    test "accepts valid arguments" do
      assert Harmonex.Ordinal.to_integer("zeroth") == :error
      for sign <- [-1, 1] do
        negative = if sign < 0, do: "negative ", else: nil
        assert Harmonex.Ordinal.to_integer("#{negative}unison")         == sign *  1
        assert Harmonex.Ordinal.to_integer("#{negative}second")         == sign *  2
        assert Harmonex.Ordinal.to_integer("#{negative}third")          == sign *  3
        assert Harmonex.Ordinal.to_integer("#{negative}fourth")         == sign *  4
        assert Harmonex.Ordinal.to_integer("#{negative}fifth")          == sign *  5
        assert Harmonex.Ordinal.to_integer("#{negative}sixth")          == sign *  6
        assert Harmonex.Ordinal.to_integer("#{negative}seventh")        == sign *  7
        assert Harmonex.Ordinal.to_integer("#{negative}octave")         == sign *  8
        assert Harmonex.Ordinal.to_integer("#{negative}ninth")          == sign *  9
        assert Harmonex.Ordinal.to_integer("#{negative}tenth")          == sign * 10
        assert Harmonex.Ordinal.to_integer("#{negative}eleventh")       == sign * 11
        assert Harmonex.Ordinal.to_integer("#{negative}twelfth")        == sign * 12
        assert Harmonex.Ordinal.to_integer("#{negative}thirteenth")     == sign * 13
        assert Harmonex.Ordinal.to_integer("#{negative}fourteenth")     == sign * 14
        assert Harmonex.Ordinal.to_integer("#{negative}fifteenth")      == sign * 15
        assert Harmonex.Ordinal.to_integer("#{negative}sixteenth")      == sign * 16
        assert Harmonex.Ordinal.to_integer("#{negative}seventeenth")    == sign * 17
        assert Harmonex.Ordinal.to_integer("#{negative}eighteenth")     == sign * 18
        assert Harmonex.Ordinal.to_integer("#{negative}nineteenth")     == sign * 19
        assert Harmonex.Ordinal.to_integer("#{negative}twentieth")      == sign * 20
        assert Harmonex.Ordinal.to_integer("#{negative}twenty-first")   == sign * 21
        assert Harmonex.Ordinal.to_integer("#{negative}twenty-second")  == sign * 22
        assert Harmonex.Ordinal.to_integer("#{negative}twenty-third")   == sign * 23
        assert Harmonex.Ordinal.to_integer("#{negative}twenty-fourth")  == sign * 24
        assert Harmonex.Ordinal.to_integer("#{negative}twenty-fifth")   == sign * 25
        assert Harmonex.Ordinal.to_integer("#{negative}twenty-sixth")   == sign * 26
        assert Harmonex.Ordinal.to_integer("#{negative}twenty-seventh") == sign * 27
        assert Harmonex.Ordinal.to_integer("#{negative}twenty-eighth")  == sign * 28
        assert Harmonex.Ordinal.to_integer("#{negative}twenty-ninth")   == sign * 29
        assert Harmonex.Ordinal.to_integer("#{negative}thirtieth")      == sign * 30
        assert Harmonex.Ordinal.to_integer("#{negative}thirty-first")   == sign * 31
        assert Harmonex.Ordinal.to_integer("#{negative}thirty-second")  == sign * 32
        assert Harmonex.Ordinal.to_integer("#{negative}thirty-third")   == sign * 33
        assert Harmonex.Ordinal.to_integer("#{negative}thirty-fourth")  == sign * 34
        assert Harmonex.Ordinal.to_integer("#{negative}thirty-fifth")   == sign * 35
        assert Harmonex.Ordinal.to_integer("#{negative}thirty-sixth")   == sign * 36
        assert Harmonex.Ordinal.to_integer("#{negative}thirty-seventh") == sign * 37
        assert Harmonex.Ordinal.to_integer("#{negative}thirty-eighth")  == sign * 38
        assert Harmonex.Ordinal.to_integer("#{negative}thirty-ninth")   == sign * 39
        assert Harmonex.Ordinal.to_integer("#{negative}fortieth")       == sign * 40
        assert Harmonex.Ordinal.to_integer("#{negative}forty-first")    == sign * 41
        assert Harmonex.Ordinal.to_integer("#{negative}forty-second")   == sign * 42
        assert Harmonex.Ordinal.to_integer("#{negative}forty-third")    == sign * 43
        assert Harmonex.Ordinal.to_integer("#{negative}forty-fourth")   == sign * 44
        assert Harmonex.Ordinal.to_integer("#{negative}forty-fifth")    == sign * 45
        assert Harmonex.Ordinal.to_integer("#{negative}forty-sixth")    == sign * 46
        assert Harmonex.Ordinal.to_integer("#{negative}forty-seventh")  == sign * 47
        assert Harmonex.Ordinal.to_integer("#{negative}forty-eighth")   == sign * 48
        assert Harmonex.Ordinal.to_integer("#{negative}forty-ninth")    == sign * 49
        assert Harmonex.Ordinal.to_integer("#{negative}fiftieth")       == sign * 50
        assert Harmonex.Ordinal.to_integer("#{negative}fifty-first")    == sign * 51
        assert Harmonex.Ordinal.to_integer("#{negative}fifty-second")   == sign * 52
        assert Harmonex.Ordinal.to_integer("#{negative}fifty-third")    == sign * 53
        assert Harmonex.Ordinal.to_integer("#{negative}fifty-fourth")   == sign * 54
        assert Harmonex.Ordinal.to_integer("#{negative}fifty-fifth")    == sign * 55
        assert Harmonex.Ordinal.to_integer("#{negative}fifty-sixth")    == sign * 56
        assert Harmonex.Ordinal.to_integer("#{negative}fifty-seventh")  == sign * 57
        assert Harmonex.Ordinal.to_integer("#{negative}fifty-eighth")   == sign * 58
        assert Harmonex.Ordinal.to_integer("#{negative}fifty-ninth")    == sign * 59
        assert Harmonex.Ordinal.to_integer("#{negative}sixtieth")       == sign * 60
        assert Harmonex.Ordinal.to_integer("#{negative}sixty-first")    == sign * 61
        assert Harmonex.Ordinal.to_integer("#{negative}sixty-second")   == sign * 62
        assert Harmonex.Ordinal.to_integer("#{negative}sixty-third")    == sign * 63
        assert Harmonex.Ordinal.to_integer("#{negative}sixty-fourth")   == sign * 64
        assert Harmonex.Ordinal.to_integer("#{negative}sixty-fifth")    == sign * 65
        assert Harmonex.Ordinal.to_integer("#{negative}sixty-sixth")    == sign * 66
        assert Harmonex.Ordinal.to_integer("#{negative}sixty-seventh")  == sign * 67
        assert Harmonex.Ordinal.to_integer("#{negative}sixty-eighth")   == sign * 68
        assert Harmonex.Ordinal.to_integer("#{negative}sixty-ninth")    == sign * 69
        assert Harmonex.Ordinal.to_integer("#{negative}seventieth")     == sign * 70
        assert Harmonex.Ordinal.to_integer("#{negative}seventy-first")  == sign * 71
        assert Harmonex.Ordinal.to_integer("#{negative}seventy-second") == sign * 72
        assert Harmonex.Ordinal.to_integer("#{negative}seventy-third")  == sign * 73
        assert Harmonex.Ordinal.to_integer("#{negative}seventy-fourth") == sign * 74
        assert Harmonex.Ordinal.to_integer("#{negative}seventy-fifth")  == sign * 75
      end
    end
  end

  describe ".to_string/1" do
    test "accepts valid arguments" do
      assert Harmonex.Ordinal.to_string(0) == :error
      for sign <- [-1, 1] do
        negative = if sign < 0, do: "negative ", else: nil
        assert Harmonex.Ordinal.to_string(sign *  1) == "#{negative}unison"
        assert Harmonex.Ordinal.to_string(sign *  2) == "#{negative}second"
        assert Harmonex.Ordinal.to_string(sign *  3) == "#{negative}third"
        assert Harmonex.Ordinal.to_string(sign *  4) == "#{negative}fourth"
        assert Harmonex.Ordinal.to_string(sign *  5) == "#{negative}fifth"
        assert Harmonex.Ordinal.to_string(sign *  6) == "#{negative}sixth"
        assert Harmonex.Ordinal.to_string(sign *  7) == "#{negative}seventh"
        assert Harmonex.Ordinal.to_string(sign *  8) == "#{negative}octave"
        assert Harmonex.Ordinal.to_string(sign *  9) == "#{negative}ninth"
        assert Harmonex.Ordinal.to_string(sign * 10) == "#{negative}tenth"
        assert Harmonex.Ordinal.to_string(sign * 11) == "#{negative}eleventh"
        assert Harmonex.Ordinal.to_string(sign * 12) == "#{negative}twelfth"
        assert Harmonex.Ordinal.to_string(sign * 13) == "#{negative}thirteenth"
        assert Harmonex.Ordinal.to_string(sign * 14) == "#{negative}fourteenth"
        assert Harmonex.Ordinal.to_string(sign * 15) == "#{negative}fifteenth"
        assert Harmonex.Ordinal.to_string(sign * 16) == "#{negative}sixteenth"
        assert Harmonex.Ordinal.to_string(sign * 17) == "#{negative}seventeenth"
        assert Harmonex.Ordinal.to_string(sign * 18) == "#{negative}eighteenth"
        assert Harmonex.Ordinal.to_string(sign * 19) == "#{negative}nineteenth"
        assert Harmonex.Ordinal.to_string(sign * 20) == "#{negative}twentieth"
        assert Harmonex.Ordinal.to_string(sign * 21) == "#{negative}twenty-first"
        assert Harmonex.Ordinal.to_string(sign * 22) == "#{negative}twenty-second"
        assert Harmonex.Ordinal.to_string(sign * 23) == "#{negative}twenty-third"
        assert Harmonex.Ordinal.to_string(sign * 24) == "#{negative}twenty-fourth"
        assert Harmonex.Ordinal.to_string(sign * 25) == "#{negative}twenty-fifth"
        assert Harmonex.Ordinal.to_string(sign * 26) == "#{negative}twenty-sixth"
        assert Harmonex.Ordinal.to_string(sign * 27) == "#{negative}twenty-seventh"
        assert Harmonex.Ordinal.to_string(sign * 28) == "#{negative}twenty-eighth"
        assert Harmonex.Ordinal.to_string(sign * 29) == "#{negative}twenty-ninth"
        assert Harmonex.Ordinal.to_string(sign * 30) == "#{negative}thirtieth"
        assert Harmonex.Ordinal.to_string(sign * 31) == "#{negative}thirty-first"
        assert Harmonex.Ordinal.to_string(sign * 32) == "#{negative}thirty-second"
        assert Harmonex.Ordinal.to_string(sign * 33) == "#{negative}thirty-third"
        assert Harmonex.Ordinal.to_string(sign * 34) == "#{negative}thirty-fourth"
        assert Harmonex.Ordinal.to_string(sign * 35) == "#{negative}thirty-fifth"
        assert Harmonex.Ordinal.to_string(sign * 36) == "#{negative}thirty-sixth"
        assert Harmonex.Ordinal.to_string(sign * 37) == "#{negative}thirty-seventh"
        assert Harmonex.Ordinal.to_string(sign * 38) == "#{negative}thirty-eighth"
        assert Harmonex.Ordinal.to_string(sign * 39) == "#{negative}thirty-ninth"
        assert Harmonex.Ordinal.to_string(sign * 40) == "#{negative}fortieth"
        assert Harmonex.Ordinal.to_string(sign * 41) == "#{negative}forty-first"
        assert Harmonex.Ordinal.to_string(sign * 42) == "#{negative}forty-second"
        assert Harmonex.Ordinal.to_string(sign * 43) == "#{negative}forty-third"
        assert Harmonex.Ordinal.to_string(sign * 44) == "#{negative}forty-fourth"
        assert Harmonex.Ordinal.to_string(sign * 45) == "#{negative}forty-fifth"
        assert Harmonex.Ordinal.to_string(sign * 46) == "#{negative}forty-sixth"
        assert Harmonex.Ordinal.to_string(sign * 47) == "#{negative}forty-seventh"
        assert Harmonex.Ordinal.to_string(sign * 48) == "#{negative}forty-eighth"
        assert Harmonex.Ordinal.to_string(sign * 49) == "#{negative}forty-ninth"
        assert Harmonex.Ordinal.to_string(sign * 50) == "#{negative}fiftieth"
        assert Harmonex.Ordinal.to_string(sign * 51) == "#{negative}fifty-first"
        assert Harmonex.Ordinal.to_string(sign * 52) == "#{negative}fifty-second"
        assert Harmonex.Ordinal.to_string(sign * 53) == "#{negative}fifty-third"
        assert Harmonex.Ordinal.to_string(sign * 54) == "#{negative}fifty-fourth"
        assert Harmonex.Ordinal.to_string(sign * 55) == "#{negative}fifty-fifth"
        assert Harmonex.Ordinal.to_string(sign * 56) == "#{negative}fifty-sixth"
        assert Harmonex.Ordinal.to_string(sign * 57) == "#{negative}fifty-seventh"
        assert Harmonex.Ordinal.to_string(sign * 58) == "#{negative}fifty-eighth"
        assert Harmonex.Ordinal.to_string(sign * 59) == "#{negative}fifty-ninth"
        assert Harmonex.Ordinal.to_string(sign * 60) == "#{negative}sixtieth"
        assert Harmonex.Ordinal.to_string(sign * 61) == "#{negative}sixty-first"
        assert Harmonex.Ordinal.to_string(sign * 62) == "#{negative}sixty-second"
        assert Harmonex.Ordinal.to_string(sign * 63) == "#{negative}sixty-third"
        assert Harmonex.Ordinal.to_string(sign * 64) == "#{negative}sixty-fourth"
        assert Harmonex.Ordinal.to_string(sign * 65) == "#{negative}sixty-fifth"
        assert Harmonex.Ordinal.to_string(sign * 66) == "#{negative}sixty-sixth"
        assert Harmonex.Ordinal.to_string(sign * 67) == "#{negative}sixty-seventh"
        assert Harmonex.Ordinal.to_string(sign * 68) == "#{negative}sixty-eighth"
        assert Harmonex.Ordinal.to_string(sign * 69) == "#{negative}sixty-ninth"
        assert Harmonex.Ordinal.to_string(sign * 70) == "#{negative}seventieth"
        assert Harmonex.Ordinal.to_string(sign * 71) == "#{negative}seventy-first"
        assert Harmonex.Ordinal.to_string(sign * 72) == "#{negative}seventy-second"
        assert Harmonex.Ordinal.to_string(sign * 73) == "#{negative}seventy-third"
        assert Harmonex.Ordinal.to_string(sign * 74) == "#{negative}seventy-fourth"
        assert Harmonex.Ordinal.to_string(sign * 75) == "#{negative}seventy-fifth"
      end
    end
  end
end
