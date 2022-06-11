defmodule MarkdownFormatter.MixProject do
  use Mix.Project

  def project do
    [
      app: :markdown_formatter,
      deps: deps(),
      dialyzer: dialyzer(),
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [credo: :test, dialyzer: :test],
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4"},
      {:ex_doc, "~> 0.28.4", only: :dev, runtime: false},
      {:mix_audit, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  def dialyzer do
    [
      plt_add_apps: [:ex_unit],
      plt_add_deps: :app_tree,
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
