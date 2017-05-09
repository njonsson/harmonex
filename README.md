# Harmonex

[<img alt="Travis CI build status" src="https://secure.travis-ci.org/njonsson/harmonex.svg?branch=master" />][Travis-CI-build-status]
[<img alt="Hex release" src="https://img.shields.io/hexpm/v/harmonex.svg" />][Hex-release]

This is a collection of tools for music theory called _Harmonex_ (pronounced
“harmonics”).

**See what’s changed lately by reading the [project history][project-history].**

## Installation

Install [the Hex package][Hex-package] by adding `:harmonex` to the list of
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
2. Update the project history in _History.md_, and commit.
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
