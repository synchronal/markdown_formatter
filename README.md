# MarkdownFormatter

An Elixir formatter for Markdown files and sigils.

## Installation

```elixir
def deps do
  [
    {:markdown_formatter, "~> 0.3", only: :dev, runtime: false}
  ]
end
```

Run `mix dep.get` and `mix deps.compile`, or the module will not be available to the formatter.

## Usage

Add `MarkdownFormatter` to the `.formatter.exs` plugin list, and add `.md` files to the list of
inputs.

```elixir
[
  plugins: [MarkdownFormatter],
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
  plugins: [MarkdownFormatter],
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
