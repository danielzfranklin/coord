defmodule Coord.MixProject do
  use Mix.Project

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
      # See <https://elixirforum.com/t/loading-modules-in-test-helper-exs-file/16609>
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:propcheck, "~> 1.2", only: :test}
    ]
  end

  def elixirc_paths(:test), do: ["test/support"] ++ elixirc_paths(:prod)
  def elixirc_paths(_), do: ["lib"]
end
