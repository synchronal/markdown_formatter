defmodule MarkdownFormatter do
  @moduledoc """
  A formatter that can be plugged in to `mix format` in order to format Markdown
  files and sigils.

  ## Usage

  Add `MarkdownFormatter` to the `.formatter.exs` plugin list.

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
  """

  @behaviour Mix.Tasks.Format

  def features(_opts) do
    [sigils: [:M], extensions: [".md", ".markdown"]]
  end

  def format(contents, _opts) do
    {:ok, markdown_ast, []} = EarmarkParser.as_ast(contents)
    MarkdownFormatter.Renderer.to_markdown(markdown_ast)
  end
end
