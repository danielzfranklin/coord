defmodule Coord.MixProject do
  use Mix.Project

  @github "https://github.com/danielzfranklin/coord"

  def project do
    [
      app: :coord,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [
        propcheck: :test,
        "propcheck.clean": :test,
        "propcheck.inspect": :test
      ],
      description: description(),
      # See <https://elixirforum.com/t/loading-modules-in-test-helper-exs-file/16609>
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      # docs
      name: "Coord",
      source_url: @github,
      # homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
      docs: [
        # The main page in the docs
        main: "Coord"
        # logo: "path/to/logo.png",
        # extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Convert between latitude/longitude and UTM.

    Tested by comparing the results of converting hundreds of thousands of points
    against a reference implementation.
    """
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:propcheck, "~> 1.2", only: :test},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @github}
    ]
  end

  def elixirc_paths(:test), do: ["test/support"] ++ elixirc_paths(:prod)
  def elixirc_paths(_), do: ["lib"]
end
