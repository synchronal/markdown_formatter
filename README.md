# MarkdownFormatter

An Elixir formatter for Markdown files and sigils.

## Installation

```elixir
def deps do
  [
    {:markdown_formatter, "~> 0.2", only: :dev, runtime: false}
  ]
end
```

## Usage

Add `MarkdownFormatter` to the `.formatter.exs` plugin list, and add `.md` files to the list of
inputs.

```elixir
[
  plugins: [MixMarkdownFormatter],
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "posts/*.{md,markdown}"
  ]
]
```

Configure with a `:markdown` section:

```elixir
[
  plugins: [MixMarkdownFormatter],
  markdown: [
    line_length: 120
  ],
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "posts/*.{md,markdown}"
  ]
]
```