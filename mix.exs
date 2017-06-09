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
     preferred_cli_env: %{:coveralls          => :test,
                          :"coveralls.detail" => :test,
                          :"coveralls.html"   => :test,
                          :"coveralls.json"   => :test,
                          :"coveralls.post"   => :test},
     package: package(),
     source_url: "https://github.com/njonsson/harmonex",
     homepage_url: "https://njonsson.github.io/harmonex",
     docs: [extras: ["README.md":  [filename: "about",
                                    title: "About Harmonex"],
                     "License.md": [filename: "license",
                                    title: "Project license"]],
                     # TODO: Figure out why ExDoc chokes on this
                     # "History.md": [filename: "history",
                     #                title: "Project history"]],
            logo: "assets/logo.png",
            main: "about"],
     test_coverage: [tool: ExCoveralls]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  def version, do: "0.4.0"

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
    [{:dialyxir,    "~> 0.5",  only: :dev},
     {:excoveralls, "~> 0.6",  only: :test},
     {:ex_doc,      "~> 0.15", only: :dev}]
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
