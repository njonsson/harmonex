# Harmonex

![logo](assets/logo.png)

[<img alt="Travis CI build status" src="https://secure.travis-ci.org/njonsson/harmonex.svg?branch=master" />][Travis-CI-build-status]
[<img alt="Hex release" src="https://img.shields.io/hexpm/v/harmonex.svg" />][Hex-release]

This is a collection of tools for music theory called _Harmonex_ (pronounced
“harmonics”).

**See what’s changed lately by reading [the project history][project-history].**

## Usage

What can you do with Harmonex? Its functions can answer textbook music theory
questions such as:

* [x] **Are C♯ and D♭ enharmonically equivalent pitches?**  
  _Answer:_ `Harmonex.Pitch.enharmonic?(:c_sharp, :d_flat) == true`
* [x] **What are the enharmonic equivalents of F𝄪?**  
  _Answer:_
  `Harmonex.Pitch.enharmonics(:f_double_sharp) == [:g_natural, :a_double_flat]`
* [x] **How far apart, in semitones, are the pitches A♭ and D♯?**  
  _Answer:_ `Harmonex.Pitch.semitones(:a_flat, :d_sharp) == 7`
* [x] **What is the quality and number of the interval between the pitches F♮ and
  B𝄫?**  
  _Answer:_
  `Harmonex.Pitch.interval_diatonic(:f, :b_double_flat) == {:diminished, 4}`
* [ ] **What is the key signature of the modal key G Locrian?**  
  _Answer: four flats — B♭, E♭, A♭, and D♭._
* [ ] **What keys and modes have the signature of three sharps?**  
  _Answer: A major/Ionian, B Dorian, C♯ Phrygian, D Lydian, E Mixolydian, F♯
  minor/Aeolian, and G♯ Locrian._
* [ ] **Does A♮ occur diatonically in the key of E♭ minor?**  
  _Answer: no._
* [ ] **What are the pitches of the simplest voicing of a D♭ minor triad in
  second inversion?**  
  _Answer: A♭, D♭, and F♭._
* [ ] **What is the name and inversion of the chord described by the pitches C♮,
  F♯, and A♮?**  
  _Answer: F♯ diminished triad in second inversion._  
  **of the chord described by A♭, C, and F♯?**  
  _Answer: A♭ Italian sixth._  
  **of the chord described by B, D♯, E, and G♯?**  
  _Answer: E major seventh in second inversion._
* [ ] **What are the jazz chart symbols of the chords just mentioned?**  
  _Answer: F<sup>O</sup>/A♭, A♭<sup>7(no 5)</sup>, and E<sup>△7</sup>/B._
* [ ] **What is the functional-harmonic symbol of the chord described by the
  pitches C♮, F♯, and A♮ in C major?**  
  _Answer: vii<sup>O</sup>/V._  
  **of the chord described by A♭, C, and F♯ in C minor?**  
  _Answer: It<sup>6</sup>._  
  **of the chord described by B, D♯, E, and G♯ in E major?**  
  _Answer: I<sup>7</sup>._

Harmonex also will have functions for exploring compositional questions such as:

* [ ] **What is the set of triads and seventh chords, including enharmonic
  equivalents of same, that the keys of B Mixolydian and D Lydian have in
  common?**
* [ ] **What is the set of seventh chords, including enharmonic equivalents, that
  are within one degree of difference (by shifting one note by a half or whole
  step) from an F major seventh chord?** **within two degrees?** **three?**
  **four?**
* [ ] **What are sets of three-chord changes for modulating from the key of D
  minor to F♯ major?** **sets of four-chord changes?** **sets of five-chord
  changes?**

## Installation

Install [the Hex package][Hex-release] by adding `:harmonex` to the list of
dependencies in your project’s _mix.exs_ file:

```elixir
# mix.exs

# ...
def deps do
  [{:harmonex, "~> 0.1.0"}]
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

1. Update [the “Installation” section](#installation) of this readme to reference
   the new version, and commit.
2. Update [the project history in _History.md_][project-history], and commit.
3. Update the version number in _mix.exs_, and commit.
4. Tag the commit and push commits and tags.
5. Build and publish [the Hex package][Hex-release] with `mix hex.publish`.

## License

Released under the [MIT License][MIT-License].

[Travis-CI-build-status]:      http://travis-ci.org/njonsson/harmonex                      "Travis CI build status for ‘Harmonex’"
[Hex-release]:                 https://hex.pm/packages/harmonex                            "Hex release of ‘Harmonex’"
[project-history]:             https://github.com/njonsson/harmonex/blob/master/History.md "‘Harmonex’ project history"
[fork-project]:                https://github.com/njonsson/harmonex/fork                   "Fork the official repository of ‘Harmonex’"
[compare-project-branches]:    https://github.com/njonsson/harmonex/compare                "Compare branches of ‘Harmonex’ repositories"
[MIT-License]:                 http://github.com/njonsson/harmonex/blob/master/License.md  "MIT License claim for ‘Harmonex’"
