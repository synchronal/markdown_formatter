defmodule MarkdownFormatter.Renderer do
  # @related [test](/test/markdown_formatter/renderer_test.exs)
  @moduledoc false

  @doc "Given AST produced from Earmark, turn it back into Markdown."
  @spec to_markdown(Earmark.ast()) :: binary()
  def to_markdown(ast) when is_list(ast) do
    ast
    |> render([])
    |> to_string()
  end

  # end recursion
  defp render([], document), do: document |> Enum.reverse()

  # paragraph tag
  defp render({"p", [], contents, %{}}, document), do: add_section(document, render(contents, []))

  # inline code tag
  defp render({"code", [{"class", "inline"}], contents, %{}}, document),
    do: ["`", render(contents, []), "`" | document]

  # text node
  defp render(text, document) when is_binary(text), do: [text | document]
  defp render([text], document) when is_binary(text), do: [text | document]

  # handle next element
  defp render([head | tail], document), do: render(tail, render(head, document))

  defp add_section([], contents), do: [contents]
  defp add_section(document, contents), do: [contents, "\n\n" | document]
end
