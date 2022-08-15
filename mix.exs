defmodule MarkdownFormatter.MixProject do
  use Mix.Project

  @scm_url "https://github.com/synchronal/markdown_formatter"

  def project do
    [
      app: :markdown_formatter,
      deps: deps(),
      description: "A mix format plugin for markdown files",
      dialyzer: dialyzer(),
      docs: docs(),
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      homepage_url: @scm_url,
      name: "MarkdownFormatter",
      package: package(),
      preferred_cli_env: [credo: :test, dialyzer: :test],
      source_url: @scm_url,
      start_permanent: Mix.env() == :prod,
      version: "0.5.0"
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps,
    do: [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:earmark_parser, "~> 1.4"},
      {:ex_doc, "~> 0.28.4", only: :dev, runtime: false},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false}
    ]

  defp dialyzer,
    do: [
      plt_add_apps: [:ex_unit, :mix],
      plt_add_deps: :app_tree,
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]

  defp docs,
    do: [
      extras: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE.md"
      ],
      main: "readme"
    ]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package,
    do: [
      files: ~w[
        .formatter.exs
        CHANGELOG.*
        LICENSE.*
        README.*
        lib
        mix.exs
      ],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @scm_url,
        "Change Log" => "https://hexdocs.pm/markdown_formatter/changelog.html"
      },
      maintainers: ["synchronal.dev", "Eric Saxby"],
      links: %{github: @scm_url}
    ]
end
