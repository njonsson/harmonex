defmodule Harmonex.Ordinal do
  @moduledoc false

  @string_negative "negative"
  @regex_negative "^#{@string_negative} " |> Regex.compile!([:caseless])

  @strings ~w(unison
              second
              third
              fourth
              fifth
              sixth
              seventh
              octave
              ninth
              tenth
              eleventh
              twelfth
              thirteenth
              fourteenth
              fifteenth
              sixteenth
              seventeenth
              eighteenth
              nineteenth
              twentieth
              twenty-first
              twenty-second
              twenty-third
              twenty-fourth
              twenty-fifth
              twenty-sixth
              twenty-seventh
              twenty-eighth
              twenty-ninth
              thirtieth
              thirty-first
              thirty-second
              thirty-third
              thirty-fourth
              thirty-fifth
              thirty-sixth
              thirty-seventh
              thirty-eighth
              thirty-ninth
              fortieth
              forty-first
              forty-second
              forty-third
              forty-fourth
              forty-fifth
              forty-sixth
              forty-seventh
              forty-eighth
              forty-ninth
              fiftieth
              fifty-first
              fifty-second
              fifty-third
              fifty-fourth
              fifty-fifth
              fifty-sixth
              fifty-seventh
              fifty-eighth
              fifty-ninth
              sixtieth
              sixty-first
              sixty-second
              sixty-third
              sixty-fourth
              sixty-fifth
              sixty-sixth
              sixty-seventh
              sixty-eighth
              sixty-ninth
              seventieth
              seventy-first
              seventy-second
              seventy-third
              seventy-fourth
              seventy-fifth)
  @regexes @strings |> Enum.map(fn(string) ->
                         fuzzy_pattern = string |> String.replace("-", "[- ]")
                         "^#{fuzzy_pattern}$" |> Regex.compile!([:caseless])
                       end)

  @doc """
  Interprets the specified `ordinal` as an `Integer`.

  ## Examples

      iex> Harmonex.Ordinal.to_integer "unison"
      1

      iex> Harmonex.Ordinal.to_integer "Octave"
      8

      iex> Harmonex.Ordinal.to_integer "TENTH"
      10

      iex> Harmonex.Ordinal.to_integer "Negative Twenty First"
      -21

      iex> Harmonex.Ordinal.to_integer "zeroth"
      :error
  """
  @spec to_integer(binary) :: integer | :error
  def to_integer(ordinal) do
    sign = if String.match?(ordinal, @regex_negative), do: -1, else: 1
    ordinal = ordinal |> String.replace(@regex_negative, "")

    absolute = (Enum.find_index(@regexes, &(String.match?(ordinal, &1))) || -1) +
               1

    if absolute == 0, do: :error, else: absolute * sign
  end

  @doc """
  Renders the specified `integer` as an ordinal string.

  ## Examples

      iex> Harmonex.Ordinal.to_string 1
      "unison"

      iex> Harmonex.Ordinal.to_string 8
      "octave"

      iex> Harmonex.Ordinal.to_string 10
      "tenth"

      iex> Harmonex.Ordinal.to_string -21
      "negative twenty-first"

      iex> Harmonex.Ordinal.to_string 0
      :error
  """
  @spec to_string(integer) :: binary | :error
  def to_string(integer) do
    sign = if integer < 0, do: "#{@string_negative} ", else: nil
    integer = abs(integer)

    if integer == 0 do
      :error
    else
      case @strings |> Enum.at(integer - 1) do
        nil    -> :error
        string -> [sign, string] |> Enum.join
      end
    end
  end
end
