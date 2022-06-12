defmodule MarkdownFormatter do
  @moduledoc """
  A formatter that can be plugged in to `mix format` in order to format Markdown
  files and sigils.

  ## Usage

  Add the `MarkdownFormatter` to `.formatter.exs`.

  ```elixir`
  [
    # Define the desired plugins
    plugins: [MixMarkdownFormatter],
    # Remember to update the inputs list to include the new extensions
    inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}", "posts/*.{md,markdown}"]
  ]
  ````
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
