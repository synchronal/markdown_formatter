# MarkdownFormatter

An Elixir formatter for Markdown files and sigils.

## Sponsorship 💕

This library is part of the [Synchronal suite of libraries and tools](https://github.com/synchronal)
which includes more than 15 open source Elixir libraries as well as some Rust libraries and tools.

You can support our open source work by [sponsoring us](https://github.com/sponsors/reflective-dev).
If you have specific features in mind, bugs you'd like fixed, or new libraries you'd like to see,
file an issue or contact us at [contact@reflective.dev](mailto:contact@reflective.dev).

## Installation

```elixir
def deps do
  [
    {:markdown_formatter, "~> 0.6", only: :dev, runtime: false}
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
