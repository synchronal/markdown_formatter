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
  defp render([], doc), do: Enum.reverse(doc)

  # headers
  defp render({"h1", [], contents, %{}}, doc), do: add_section(doc, render(["# ", contents], []))
  defp render({"h2", [], contents, %{}}, doc), do: add_section(doc, render(["## ", contents], []))
  defp render({"h3", [], contents, %{}}, doc), do: add_section(doc, render(["### ", contents], []))
  defp render({"h4", [], contents, %{}}, doc), do: add_section(doc, render(["#### ", contents], []))
  defp render({"h5", [], contents, %{}}, doc), do: add_section(doc, render(["##### ", contents], []))
  defp render({"h6", [], contents, %{}}, doc), do: add_section(doc, render(["###### ", contents], []))

  # paragraph tag
  defp render({"p", [], contents, %{}}, doc), do: add_section(doc, render(contents, []))

  # code
  defp render({"code", [{"class", "inline"}], contents, %{}}, doc), do: ["`", render(contents, []), "`" | doc]
  defp render({"pre", [], [{"code", [], contents, %{}}], %{}}, doc), do: ["\n```", render(contents, []), "```\n" | doc]

  # text formatting
  defp render({"em", [], contents, %{}}, doc), do: ["*", render(contents, []), "*" | doc]
  defp render({"strong", [], contents, %{}}, doc), do: ["**", render(contents, []), "**" | doc]

  # text node
  defp render(text, doc) when is_binary(text), do: [text | doc]
  defp render([text], doc) when is_binary(text), do: [text | doc]

  # handle next element
  defp render([head | tail], doc), do: render(tail, render(head, doc))

  defp add_section([], contents), do: [contents]
  defp add_section(doc, contents), do: [contents, "\n\n" | doc]
end
