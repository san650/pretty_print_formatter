defmodule PrettyPrintFormatter.Mixfile do
  use Mix.Project

  def project do
    [
      app: :pretty_print_formatter,
      version: "0.1.7",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "src/sql_lexer.xrl", "mix.exs", "README.md", "LICENSE"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/san650/pretty_print_formatter"},
      maintainers: ["Santiago Ferreira", "Juan Azambuja"],
      name: :pretty_print_formatter,
    ]
  end

  defp description do
    """
    Library for coloring the output of the logger. Right now it colorizes Ecto SQL statements and Phoenix's request id metadata.
    """
  end
end
