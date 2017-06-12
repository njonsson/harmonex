defmodule Harmonex.OrdinalTest do
  use ExUnit.Case, async: true

  alias Harmonex.Ordinal

  doctest Ordinal

  describe ".to_integer/1" do
    test "accepts valid arguments" do
      assert Ordinal.to_integer("zeroth") == :error
      assert Ordinal.to_integer("0th") == :error
      for sign <- [-1, 1] do
        negative = if sign < 0, do: "negative ", else: nil
        assert Ordinal.to_integer("#{negative}unison")         == sign *  1
        assert Ordinal.to_integer("#{negative}1st")            == sign *  1
        assert Ordinal.to_integer("#{negative}second")         == sign *  2
        assert Ordinal.to_integer("#{negative}2nd")            == sign *  2
        assert Ordinal.to_integer("#{negative}third")          == sign *  3
        assert Ordinal.to_integer("#{negative}3rd")            == sign *  3
        assert Ordinal.to_integer("#{negative}fourth")         == sign *  4
        assert Ordinal.to_integer("#{negative}4th")            == sign *  4
        assert Ordinal.to_integer("#{negative}fifth")          == sign *  5
        assert Ordinal.to_integer("#{negative}sixth")          == sign *  6
        assert Ordinal.to_integer("#{negative}seventh")        == sign *  7
        assert Ordinal.to_integer("#{negative}octave")         == sign *  8
        assert Ordinal.to_integer("#{negative}ninth")          == sign *  9
        assert Ordinal.to_integer("#{negative}tenth")          == sign * 10
        assert Ordinal.to_integer("#{negative}eleventh")       == sign * 11
        assert Ordinal.to_integer("#{negative}twelfth")        == sign * 12
        assert Ordinal.to_integer("#{negative}thirteenth")     == sign * 13
        assert Ordinal.to_integer("#{negative}fourteenth")     == sign * 14
        assert Ordinal.to_integer("#{negative}fifteenth")      == sign * 15
        assert Ordinal.to_integer("#{negative}sixteenth")      == sign * 16
        assert Ordinal.to_integer("#{negative}seventeenth")    == sign * 17
        assert Ordinal.to_integer("#{negative}eighteenth")     == sign * 18
        assert Ordinal.to_integer("#{negative}nineteenth")     == sign * 19
        assert Ordinal.to_integer("#{negative}twentieth")      == sign * 20
        assert Ordinal.to_integer("#{negative}twenty-first")   == sign * 21
        assert Ordinal.to_integer("#{negative}twenty-second")  == sign * 22
        assert Ordinal.to_integer("#{negative}twenty-third")   == sign * 23
        assert Ordinal.to_integer("#{negative}twenty-fourth")  == sign * 24
        assert Ordinal.to_integer("#{negative}twenty-fifth")   == sign * 25
        assert Ordinal.to_integer("#{negative}twenty-sixth")   == sign * 26
        assert Ordinal.to_integer("#{negative}twenty-seventh") == sign * 27
        assert Ordinal.to_integer("#{negative}twenty-eighth")  == sign * 28
        assert Ordinal.to_integer("#{negative}twenty-ninth")   == sign * 29
        assert Ordinal.to_integer("#{negative}thirtieth")      == sign * 30
        assert Ordinal.to_integer("#{negative}thirty-first")   == sign * 31
        assert Ordinal.to_integer("#{negative}thirty-second")  == sign * 32
        assert Ordinal.to_integer("#{negative}thirty-third")   == sign * 33
        assert Ordinal.to_integer("#{negative}thirty-fourth")  == sign * 34
        assert Ordinal.to_integer("#{negative}thirty-fifth")   == sign * 35
        assert Ordinal.to_integer("#{negative}thirty-sixth")   == sign * 36
        assert Ordinal.to_integer("#{negative}thirty-seventh") == sign * 37
        assert Ordinal.to_integer("#{negative}thirty-eighth")  == sign * 38
        assert Ordinal.to_integer("#{negative}thirty-ninth")   == sign * 39
        assert Ordinal.to_integer("#{negative}fortieth")       == sign * 40
        assert Ordinal.to_integer("#{negative}forty-first")    == sign * 41
        assert Ordinal.to_integer("#{negative}forty-second")   == sign * 42
        assert Ordinal.to_integer("#{negative}forty-third")    == sign * 43
        assert Ordinal.to_integer("#{negative}forty-fourth")   == sign * 44
        assert Ordinal.to_integer("#{negative}forty-fifth")    == sign * 45
        assert Ordinal.to_integer("#{negative}forty-sixth")    == sign * 46
        assert Ordinal.to_integer("#{negative}forty-seventh")  == sign * 47
        assert Ordinal.to_integer("#{negative}forty-eighth")   == sign * 48
        assert Ordinal.to_integer("#{negative}forty-ninth")    == sign * 49
        assert Ordinal.to_integer("#{negative}fiftieth")       == sign * 50
        assert Ordinal.to_integer("#{negative}fifty-first")    == sign * 51
        assert Ordinal.to_integer("#{negative}fifty-second")   == sign * 52
        assert Ordinal.to_integer("#{negative}fifty-third")    == sign * 53
        assert Ordinal.to_integer("#{negative}fifty-fourth")   == sign * 54
        assert Ordinal.to_integer("#{negative}fifty-fifth")    == sign * 55
        assert Ordinal.to_integer("#{negative}fifty-sixth")    == sign * 56
        assert Ordinal.to_integer("#{negative}fifty-seventh")  == sign * 57
        assert Ordinal.to_integer("#{negative}fifty-eighth")   == sign * 58
        assert Ordinal.to_integer("#{negative}fifty-ninth")    == sign * 59
        assert Ordinal.to_integer("#{negative}sixtieth")       == sign * 60
        assert Ordinal.to_integer("#{negative}sixty-first")    == sign * 61
        assert Ordinal.to_integer("#{negative}sixty-second")   == sign * 62
        assert Ordinal.to_integer("#{negative}sixty-third")    == sign * 63
        assert Ordinal.to_integer("#{negative}sixty-fourth")   == sign * 64
        assert Ordinal.to_integer("#{negative}sixty-fifth")    == sign * 65
        assert Ordinal.to_integer("#{negative}sixty-sixth")    == sign * 66
        assert Ordinal.to_integer("#{negative}sixty-seventh")  == sign * 67
        assert Ordinal.to_integer("#{negative}sixty-eighth")   == sign * 68
        assert Ordinal.to_integer("#{negative}sixty-ninth")    == sign * 69
        assert Ordinal.to_integer("#{negative}seventieth")     == sign * 70
        assert Ordinal.to_integer("#{negative}seventy-first")  == sign * 71
        assert Ordinal.to_integer("#{negative}seventy-second") == sign * 72
        assert Ordinal.to_integer("#{negative}seventy-third")  == sign * 73
        assert Ordinal.to_integer("#{negative}seventy-fourth") == sign * 74
        assert Ordinal.to_integer("#{negative}seventy-fifth")  == sign * 75
        assert Ordinal.to_integer("#{negative}76th")           == sign * 76
      end
    end
  end

  describe ".to_string/1" do
    test "accepts valid arguments" do
      assert Ordinal.to_string(0) == :error
      for sign <- [-1, 1] do
        negative = if sign < 0, do: "negative ", else: nil
        assert Ordinal.to_string(sign *  1) == "#{negative}unison"
        assert Ordinal.to_string(sign *  2) == "#{negative}second"
        assert Ordinal.to_string(sign *  3) == "#{negative}third"
        assert Ordinal.to_string(sign *  4) == "#{negative}fourth"
        assert Ordinal.to_string(sign *  5) == "#{negative}fifth"
        assert Ordinal.to_string(sign *  6) == "#{negative}sixth"
        assert Ordinal.to_string(sign *  7) == "#{negative}seventh"
        assert Ordinal.to_string(sign *  8) == "#{negative}octave"
        assert Ordinal.to_string(sign *  9) == "#{negative}ninth"
        assert Ordinal.to_string(sign * 10) == "#{negative}tenth"
        assert Ordinal.to_string(sign * 11) == "#{negative}eleventh"
        assert Ordinal.to_string(sign * 12) == "#{negative}twelfth"
        assert Ordinal.to_string(sign * 13) == "#{negative}thirteenth"
        assert Ordinal.to_string(sign * 14) == "#{negative}fourteenth"
        assert Ordinal.to_string(sign * 15) == "#{negative}fifteenth"
        assert Ordinal.to_string(sign * 16) == "#{negative}sixteenth"
        assert Ordinal.to_string(sign * 17) == "#{negative}seventeenth"
        assert Ordinal.to_string(sign * 18) == "#{negative}eighteenth"
        assert Ordinal.to_string(sign * 19) == "#{negative}nineteenth"
        assert Ordinal.to_string(sign * 20) == "#{negative}twentieth"
        assert Ordinal.to_string(sign * 21) == "#{negative}twenty-first"
        assert Ordinal.to_string(sign * 22) == "#{negative}twenty-second"
        assert Ordinal.to_string(sign * 23) == "#{negative}twenty-third"
        assert Ordinal.to_string(sign * 24) == "#{negative}twenty-fourth"
        assert Ordinal.to_string(sign * 25) == "#{negative}twenty-fifth"
        assert Ordinal.to_string(sign * 26) == "#{negative}twenty-sixth"
        assert Ordinal.to_string(sign * 27) == "#{negative}twenty-seventh"
        assert Ordinal.to_string(sign * 28) == "#{negative}twenty-eighth"
        assert Ordinal.to_string(sign * 29) == "#{negative}twenty-ninth"
        assert Ordinal.to_string(sign * 30) == "#{negative}thirtieth"
        assert Ordinal.to_string(sign * 31) == "#{negative}thirty-first"
        assert Ordinal.to_string(sign * 32) == "#{negative}thirty-second"
        assert Ordinal.to_string(sign * 33) == "#{negative}thirty-third"
        assert Ordinal.to_string(sign * 34) == "#{negative}thirty-fourth"
        assert Ordinal.to_string(sign * 35) == "#{negative}thirty-fifth"
        assert Ordinal.to_string(sign * 36) == "#{negative}thirty-sixth"
        assert Ordinal.to_string(sign * 37) == "#{negative}thirty-seventh"
        assert Ordinal.to_string(sign * 38) == "#{negative}thirty-eighth"
        assert Ordinal.to_string(sign * 39) == "#{negative}thirty-ninth"
        assert Ordinal.to_string(sign * 40) == "#{negative}fortieth"
        assert Ordinal.to_string(sign * 41) == "#{negative}forty-first"
        assert Ordinal.to_string(sign * 42) == "#{negative}forty-second"
        assert Ordinal.to_string(sign * 43) == "#{negative}forty-third"
        assert Ordinal.to_string(sign * 44) == "#{negative}forty-fourth"
        assert Ordinal.to_string(sign * 45) == "#{negative}forty-fifth"
        assert Ordinal.to_string(sign * 46) == "#{negative}forty-sixth"
        assert Ordinal.to_string(sign * 47) == "#{negative}forty-seventh"
        assert Ordinal.to_string(sign * 48) == "#{negative}forty-eighth"
        assert Ordinal.to_string(sign * 49) == "#{negative}forty-ninth"
        assert Ordinal.to_string(sign * 50) == "#{negative}fiftieth"
        assert Ordinal.to_string(sign * 51) == "#{negative}fifty-first"
        assert Ordinal.to_string(sign * 52) == "#{negative}fifty-second"
        assert Ordinal.to_string(sign * 53) == "#{negative}fifty-third"
        assert Ordinal.to_string(sign * 54) == "#{negative}fifty-fourth"
        assert Ordinal.to_string(sign * 55) == "#{negative}fifty-fifth"
        assert Ordinal.to_string(sign * 56) == "#{negative}fifty-sixth"
        assert Ordinal.to_string(sign * 57) == "#{negative}fifty-seventh"
        assert Ordinal.to_string(sign * 58) == "#{negative}fifty-eighth"
        assert Ordinal.to_string(sign * 59) == "#{negative}fifty-ninth"
        assert Ordinal.to_string(sign * 60) == "#{negative}sixtieth"
        assert Ordinal.to_string(sign * 61) == "#{negative}sixty-first"
        assert Ordinal.to_string(sign * 62) == "#{negative}sixty-second"
        assert Ordinal.to_string(sign * 63) == "#{negative}sixty-third"
        assert Ordinal.to_string(sign * 64) == "#{negative}sixty-fourth"
        assert Ordinal.to_string(sign * 65) == "#{negative}sixty-fifth"
        assert Ordinal.to_string(sign * 66) == "#{negative}sixty-sixth"
        assert Ordinal.to_string(sign * 67) == "#{negative}sixty-seventh"
        assert Ordinal.to_string(sign * 68) == "#{negative}sixty-eighth"
        assert Ordinal.to_string(sign * 69) == "#{negative}sixty-ninth"
        assert Ordinal.to_string(sign * 70) == "#{negative}seventieth"
        assert Ordinal.to_string(sign * 71) == "#{negative}seventy-first"
        assert Ordinal.to_string(sign * 72) == "#{negative}seventy-second"
        assert Ordinal.to_string(sign * 73) == "#{negative}seventy-third"
        assert Ordinal.to_string(sign * 74) == "#{negative}seventy-fourth"
        assert Ordinal.to_string(sign * 75) == "#{negative}seventy-fifth"
        assert Ordinal.to_string(sign * 76) == "#{negative}76th"
      end
    end
  end
end
