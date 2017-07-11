defmodule Harmonex.OrdinalTest do
  use ExUnit.Case, async: true

  alias Harmonex.Ordinal

  doctest Ordinal

  describe ".to_integer/1" do
    test "accepts valid arguments" do
      assert Ordinal.to_integer("zeroth") == :error
      assert Ordinal.to_integer("0th") == :error
      assert Ordinal.to_integer("unison")         ==  1
      assert Ordinal.to_integer("1st")            ==  1
      assert Ordinal.to_integer("second")         ==  2
      assert Ordinal.to_integer("2nd")            ==  2
      assert Ordinal.to_integer("third")          ==  3
      assert Ordinal.to_integer("3rd")            ==  3
      assert Ordinal.to_integer("fourth")         ==  4
      assert Ordinal.to_integer("4th")            ==  4
      assert Ordinal.to_integer("fifth")          ==  5
      assert Ordinal.to_integer("sixth")          ==  6
      assert Ordinal.to_integer("seventh")        ==  7
      assert Ordinal.to_integer("octave")         ==  8
      assert Ordinal.to_integer("ninth")          ==  9
      assert Ordinal.to_integer("tenth")          == 10
      assert Ordinal.to_integer("eleventh")       == 11
      assert Ordinal.to_integer("twelfth")        == 12
      assert Ordinal.to_integer("thirteenth")     == 13
      assert Ordinal.to_integer("fourteenth")     == 14
      assert Ordinal.to_integer("fifteenth")      == 15
      assert Ordinal.to_integer("sixteenth")      == 16
      assert Ordinal.to_integer("seventeenth")    == 17
      assert Ordinal.to_integer("eighteenth")     == 18
      assert Ordinal.to_integer("nineteenth")     == 19
      assert Ordinal.to_integer("twentieth")      == 20
      assert Ordinal.to_integer("twenty-first")   == 21
      assert Ordinal.to_integer("twenty-second")  == 22
      assert Ordinal.to_integer("twenty-third")   == 23
      assert Ordinal.to_integer("twenty-fourth")  == 24
      assert Ordinal.to_integer("twenty-fifth")   == 25
      assert Ordinal.to_integer("twenty-sixth")   == 26
      assert Ordinal.to_integer("twenty-seventh") == 27
      assert Ordinal.to_integer("twenty-eighth")  == 28
      assert Ordinal.to_integer("twenty-ninth")   == 29
      assert Ordinal.to_integer("thirtieth")      == 30
      assert Ordinal.to_integer("thirty-first")   == 31
      assert Ordinal.to_integer("thirty-second")  == 32
      assert Ordinal.to_integer("thirty-third")   == 33
      assert Ordinal.to_integer("thirty-fourth")  == 34
      assert Ordinal.to_integer("thirty-fifth")   == 35
      assert Ordinal.to_integer("thirty-sixth")   == 36
      assert Ordinal.to_integer("thirty-seventh") == 37
      assert Ordinal.to_integer("thirty-eighth")  == 38
      assert Ordinal.to_integer("thirty-ninth")   == 39
      assert Ordinal.to_integer("fortieth")       == 40
      assert Ordinal.to_integer("forty-first")    == 41
      assert Ordinal.to_integer("forty-second")   == 42
      assert Ordinal.to_integer("forty-third")    == 43
      assert Ordinal.to_integer("forty-fourth")   == 44
      assert Ordinal.to_integer("forty-fifth")    == 45
      assert Ordinal.to_integer("forty-sixth")    == 46
      assert Ordinal.to_integer("forty-seventh")  == 47
      assert Ordinal.to_integer("forty-eighth")   == 48
      assert Ordinal.to_integer("forty-ninth")    == 49
      assert Ordinal.to_integer("fiftieth")       == 50
      assert Ordinal.to_integer("fifty-first")    == 51
      assert Ordinal.to_integer("fifty-second")   == 52
      assert Ordinal.to_integer("fifty-third")    == 53
      assert Ordinal.to_integer("fifty-fourth")   == 54
      assert Ordinal.to_integer("fifty-fifth")    == 55
      assert Ordinal.to_integer("fifty-sixth")    == 56
      assert Ordinal.to_integer("fifty-seventh")  == 57
      assert Ordinal.to_integer("fifty-eighth")   == 58
      assert Ordinal.to_integer("fifty-ninth")    == 59
      assert Ordinal.to_integer("sixtieth")       == 60
      assert Ordinal.to_integer("sixty-first")    == 61
      assert Ordinal.to_integer("sixty-second")   == 62
      assert Ordinal.to_integer("sixty-third")    == 63
      assert Ordinal.to_integer("sixty-fourth")   == 64
      assert Ordinal.to_integer("sixty-fifth")    == 65
      assert Ordinal.to_integer("sixty-sixth")    == 66
      assert Ordinal.to_integer("sixty-seventh")  == 67
      assert Ordinal.to_integer("sixty-eighth")   == 68
      assert Ordinal.to_integer("sixty-ninth")    == 69
      assert Ordinal.to_integer("seventieth")     == 70
      assert Ordinal.to_integer("seventy-first")  == 71
      assert Ordinal.to_integer("seventy-second") == 72
      assert Ordinal.to_integer("seventy-third")  == 73
      assert Ordinal.to_integer("seventy-fourth") == 74
      assert Ordinal.to_integer("seventy-fifth")  == 75
      assert Ordinal.to_integer("76th")           == 76
    end
  end

  describe ".to_string/1" do
    test "accepts valid arguments" do
      assert Ordinal.to_string( 0) == :error
      assert Ordinal.to_string( 1) == "unison"
      assert Ordinal.to_string( 2) == "second"
      assert Ordinal.to_string( 3) == "third"
      assert Ordinal.to_string( 4) == "fourth"
      assert Ordinal.to_string( 5) == "fifth"
      assert Ordinal.to_string( 6) == "sixth"
      assert Ordinal.to_string( 7) == "seventh"
      assert Ordinal.to_string( 8) == "octave"
      assert Ordinal.to_string( 9) == "ninth"
      assert Ordinal.to_string(10) == "tenth"
      assert Ordinal.to_string(11) == "eleventh"
      assert Ordinal.to_string(12) == "twelfth"
      assert Ordinal.to_string(13) == "thirteenth"
      assert Ordinal.to_string(14) == "fourteenth"
      assert Ordinal.to_string(15) == "fifteenth"
      assert Ordinal.to_string(16) == "sixteenth"
      assert Ordinal.to_string(17) == "seventeenth"
      assert Ordinal.to_string(18) == "eighteenth"
      assert Ordinal.to_string(19) == "nineteenth"
      assert Ordinal.to_string(20) == "twentieth"
      assert Ordinal.to_string(21) == "twenty-first"
      assert Ordinal.to_string(22) == "twenty-second"
      assert Ordinal.to_string(23) == "twenty-third"
      assert Ordinal.to_string(24) == "twenty-fourth"
      assert Ordinal.to_string(25) == "twenty-fifth"
      assert Ordinal.to_string(26) == "twenty-sixth"
      assert Ordinal.to_string(27) == "twenty-seventh"
      assert Ordinal.to_string(28) == "twenty-eighth"
      assert Ordinal.to_string(29) == "twenty-ninth"
      assert Ordinal.to_string(30) == "thirtieth"
      assert Ordinal.to_string(31) == "thirty-first"
      assert Ordinal.to_string(32) == "thirty-second"
      assert Ordinal.to_string(33) == "thirty-third"
      assert Ordinal.to_string(34) == "thirty-fourth"
      assert Ordinal.to_string(35) == "thirty-fifth"
      assert Ordinal.to_string(36) == "thirty-sixth"
      assert Ordinal.to_string(37) == "thirty-seventh"
      assert Ordinal.to_string(38) == "thirty-eighth"
      assert Ordinal.to_string(39) == "thirty-ninth"
      assert Ordinal.to_string(40) == "fortieth"
      assert Ordinal.to_string(41) == "forty-first"
      assert Ordinal.to_string(42) == "forty-second"
      assert Ordinal.to_string(43) == "forty-third"
      assert Ordinal.to_string(44) == "forty-fourth"
      assert Ordinal.to_string(45) == "forty-fifth"
      assert Ordinal.to_string(46) == "forty-sixth"
      assert Ordinal.to_string(47) == "forty-seventh"
      assert Ordinal.to_string(48) == "forty-eighth"
      assert Ordinal.to_string(49) == "forty-ninth"
      assert Ordinal.to_string(50) == "fiftieth"
      assert Ordinal.to_string(51) == "fifty-first"
      assert Ordinal.to_string(52) == "fifty-second"
      assert Ordinal.to_string(53) == "fifty-third"
      assert Ordinal.to_string(54) == "fifty-fourth"
      assert Ordinal.to_string(55) == "fifty-fifth"
      assert Ordinal.to_string(56) == "fifty-sixth"
      assert Ordinal.to_string(57) == "fifty-seventh"
      assert Ordinal.to_string(58) == "fifty-eighth"
      assert Ordinal.to_string(59) == "fifty-ninth"
      assert Ordinal.to_string(60) == "sixtieth"
      assert Ordinal.to_string(61) == "sixty-first"
      assert Ordinal.to_string(62) == "sixty-second"
      assert Ordinal.to_string(63) == "sixty-third"
      assert Ordinal.to_string(64) == "sixty-fourth"
      assert Ordinal.to_string(65) == "sixty-fifth"
      assert Ordinal.to_string(66) == "sixty-sixth"
      assert Ordinal.to_string(67) == "sixty-seventh"
      assert Ordinal.to_string(68) == "sixty-eighth"
      assert Ordinal.to_string(69) == "sixty-ninth"
      assert Ordinal.to_string(70) == "seventieth"
      assert Ordinal.to_string(71) == "seventy-first"
      assert Ordinal.to_string(72) == "seventy-second"
      assert Ordinal.to_string(73) == "seventy-third"
      assert Ordinal.to_string(74) == "seventy-fourth"
      assert Ordinal.to_string(75) == "seventy-fifth"
      assert Ordinal.to_string(76) == "76th"
    end
  end
end
