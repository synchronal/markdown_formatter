# MarkdownFormatter

An Elixir formatter for Markdown files and sigils.


## Installation

```elixir
def deps do
  [
    {:markdown_formatter, "~> 0.1.0", only: :dev, runtime: false}
  ]
end
```

## Usage

Add `MarkdownFormatter` to the `.formatter.exs` plugin list, and add `.md` files
to the list of inputs.

```
[
  plugins: [MixMarkdownFormatter],
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "posts/*.{md,markdown}"
  ]
]
```
