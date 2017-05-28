# Harmonex

![logo](assets/logo.png)

[<img alt="Travis CI build status" src="https://secure.travis-ci.org/njonsson/harmonex.svg?branch=master" />][Travis-CI-build-status]
[<img alt="HexFaktor dependencies status" src="https://beta.hexfaktor.org/badge/all/github/njonsson/harmonex.svg" />][HexFaktor-deps-status]
[<img alt="Coveralls test coverage status" src="https://coveralls.io/repos/njonsson/harmonex/badge.svg?branch=master" />][Coveralls-test-coverage-status]
[<img alt="Hex release" src="https://img.shields.io/hexpm/v/harmonex.svg" />][Hex-release]
[<img alt="Hex downloads" src="https://img.shields.io/hexpm/dt/harmonex.svg" />][Hex-release]

This is a collection of tools for music theory called _Harmonex_ (pronounced
“harmonics”).

**See what’s changed lately by reading [the project history][project-history].**

## Usage

What can you do with Harmonex? Its functions can answer textbook music theory
questions such as:

* **Are C♯ and D♭ enharmonically equivalent pitches?**  
  _Answer:_ `Harmonex.Pitch.enharmonic?(:c_sharp, :d_flat) == true`
* **What are the enharmonic equivalents of F𝄪?**  
  _Answer:_
  `Harmonex.Pitch.enharmonics(:f_double_sharp) == [:g_natural, :a_double_flat]`
* **How far apart, in semitones, are the pitches A♭ and D♯?**  
  _Answer:_ `Harmonex.Pitch.semitones(:a_flat, :d_sharp) == 7`
* **What is the interval between the pitches F♮ and B𝄫?**  
  _Answer:_
  `Harmonex.Pitch.interval(:f, :b_double_flat) == %Harmonex.Interval{quality:
  :diminished, size: 4}`  
  _Answer:_
  `Harmonex.Interval.between_pitches(:f, :b_double_flat) ==
  %Harmonex.Interval{quality: :diminished, size: 4}`

### Functionality still under development

* **What is the key signature of G harmonic minor?**  
  _Answer: two flats, one sharp — B♭, E♭, and F♯._
* **What keys and modes have the signature of three sharps?**  
  _Answer: A major/Ionian, B Dorian, C♯ Phrygian, D Lydian, E Mixolydian, F♯
  minor/Aeolian, and G♯ Locrian._
* **Does A♮ occur diatonically in the key of E♭ minor?**  
  _Answer: no._
* **What are the pitches of the simplest voicing of a D♭ minor triad in
  second inversion?**  
  _Answer: A♭, D♭, and F♭._
* **What is the name and inversion of the chord described by the pitches C♮, F♯,
  and A♮?**  
  _Answer: F♯ diminished triad in second inversion._  
  **of the chord described by A♭, C, and F♯?**  
  _Answer: A♭ Italian sixth._  
  **of the chord described by B, D♯, E, and G♯?**  
  _Answer: E major seventh in second inversion._
* **What are the jazz chart symbols of the chords just mentioned?**  
  _Answer: F♯<sup>o</sup>/C, A♭<sup>7(no 5)</sup>, and E<sup>△7</sup>/B._
* **What is the functional-harmonic symbol of the chord described by the pitches
  C♮, F♯, and A♮ in C major?**  
  _Answer: vii<sup>o6</sup><span style="position: relative; left: -1ex;"><sub>4</sub>/V.</span>_  
  **of the chord described by A♭, C, and F♯ in C minor?**  
  _Answer: It<sup>6</sup>._  
  **of the chord described by B, D♯, E, and G♯ in E major?**  
  _Answer: I<sup>7</sup>._

Harmonex also will have functions for exploring compositional questions such as:

* **What is the set of triads and seventh chords, including enharmonic
  equivalents of same, that the keys of B Mixolydian and D Lydian have in
  common?**
* **What is the set of seventh chords, including enharmonic equivalents, that are
  within one degree of difference (by shifting one note by a half or whole step)
  from an F major seventh chord?** **within two degrees?** **three?**
  **four?**
* **What are sets of three-chord changes for modulating from the key of D minor
  to F♯ major?** **sets of four-chord changes?** **sets of five-chord changes?**

## Installation

Install [the Hex package][Hex-release] by adding `:harmonex` to the list of
dependencies in your project’s _mix.exs_ file:

```elixir
# mix.exs

# ...
def deps do
  [{:harmonex, "~> 0.4.0"}]
end
# ...
```

## Contributing

To submit a patch to the project:

1. [Fork][fork-project] the official repository.
2. Create your feature branch: `git checkout -b my-new-feature`.
3. Commit your changes: `git commit -am 'Add some feature'`.
4. Push to the branch: `git push origin my-new-feature`.
5. [Create][compare-project-branches] a new pull request.

After cloning the repository, `mix deps.get` to install dependencies. Then
`mix test` to run the tests. You can also `iex` to get an interactive prompt that
will allow you to experiment. To build this package, `mix hex.build`.

To release a new version:

1. Update [the project history in _History.md_][project-history], and then
   commit.
2. Update the version number in [_mix.exs_][mix-dot-exs-file] respecting
   [Semantic Versioning][Semantic-Versioning], update
   [the “Installation” section](#installation) of
   [this readme][readme-dot-md-file] to reference the new version, and then
   commit.
3. Build and publish [the Hex package][Hex-release] with `mix hex.publish`.
4. Tag with a name like `vMAJOR.MINOR.PATCH` corresponding to the new version,
   and then push commits and tags.

## License

Released under the [MIT License][MIT-License].

[Travis-CI-build-status]:         http://travis-ci.org/njonsson/harmonex                                  "Travis CI build status for ‘Harmonex’"
[HexFaktor-deps-status]:          https://beta.hexfaktor.org/github/njonsson/harmonex                     "HexFaktor dependencies status for ‘Harmonex’"
[Coveralls-test-coverage-status]: https://coveralls.io/r/njonsson/harmonex?branch=master                  "Coveralls test coverage status"
[Hex-release]:                    https://hex.pm/packages/harmonex                                        "Hex release of ‘Harmonex’"
[project-history]:                https://github.com/njonsson/harmonex/blob/master/History.md             "‘Harmonex’ project history"
[fork-project]:                   https://github.com/njonsson/harmonex/fork                               "Fork the official repository of ‘Harmonex’"
[compare-project-branches]:       https://github.com/njonsson/harmonex/compare                            "Compare branches of ‘Harmonex’ repositories"
[mix-dot-exs-file]:               https://github.com/njonsson/harmonex/blob/master/mix.exs                "‘Harmonex’ project ‘mix.exs’ file"
[Semantic-Versioning]:            http://semver.org/
[readme-dot-md-file]:             https://github.com/njonsson/harmonex/blob/master/README.md#installation "‘Harmonex’ project ‘README.md’ file"
[MIT-License]:                    http://github.com/njonsson/harmonex/blob/master/License.md              "MIT License claim for ‘Harmonex’"
