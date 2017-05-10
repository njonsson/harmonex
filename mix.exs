defmodule Harmonex.Mixfile do
  use Mix.Project

  def project do
    [app: :harmonex,
     version: version(),
     description: description(),
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     docs: [extras: ["README.md":  [filename: "about",
                                    title: "About Harmonex"],
                     "License.md": [filename: "license",
                                    title: "Project license"]],
                     # TODO: Figure out why ExDoc chokes on this
                     # "History.md": [filename: "history",
                     #                title: "Project history"]],
            logo: "assets/logo.png",
            main: "about"]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  def version, do: "0.1.0"

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:dialyze, "~> 0.2",  only: :dev},
     {:ex_doc,  "~> 0.15", only: :dev}]
  end

  defp description do
    "A collection of tools for music theory — pronounced “harmonics”"
  end

  defp package do
    [files:       ~w(History.md License.md README.md lib mix.exs),
     maintainers: ["Nils Jonsson <harmonex@nilsjonsson.com>"],
     licenses:    ["MIT"],
     links:       %{"Home"   => "https://njonsson.github.io/harmonex",
                    "Source" => "https://github.com/njonsson/harmonex",
                    "Issues" => "https://github.com/njonsson/harmonex/issues"}]
  end
end
