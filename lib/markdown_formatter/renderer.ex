defmodule MarkdownFormatter.Renderer do
  # @related [test](/test/markdown_formatter/renderer_test.exs)
  @moduledoc false

  @doc "Given AST produced from Earmark, turn it back into Markdown."
  @spec to_markdown(Earmark.ast()) :: binary()
  def to_markdown(ast) when is_list(ast) do
    Enum.reduce(ast, [], &render/2)
    |> Enum.reverse()
    |> to_string()
  end

  defp render({"p", [], [contents], %{}}, document) do
    concat(document, contents)
  end

  defp concat([], contents), do: [contents]
  defp concat(document, contents), do: [contents, "\n\n" | document]
end
