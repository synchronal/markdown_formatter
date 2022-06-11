defmodule MarkdownFormatter.Renderer do
  # @related [test](/test/markdown_formatter/renderer_test.exs)
  @moduledoc false

  defmodule RenderState do
    @moduledoc false

    defstruct ~w{parent}a

    def new(), do: __struct__()
    def parent(state, parent), do: %{state | parent: parent}
  end

  @doc "Given AST produced from Earmark, turn it back into Markdown."
  @spec to_markdown(Earmark.ast()) :: binary()
  def to_markdown(ast) when is_list(ast) do
    ast
    |> render([], RenderState.new())
    |> to_string()
  end

  # end recursion
  defp render([], doc, _opts), do: Enum.reverse(doc)

  # headers
  defp render({"h1", [], contents, %{}}, doc, opts), do: add_section(doc, render(contents, ["# "], opts))
  defp render({"h2", [], contents, %{}}, doc, opts), do: add_section(doc, render(contents, ["## "], opts))
  defp render({"h3", [], contents, %{}}, doc, opts), do: add_section(doc, render(contents, ["### "], opts))
  defp render({"h4", [], contents, %{}}, doc, opts), do: add_section(doc, render(contents, ["#### "], opts))
  defp render({"h5", [], contents, %{}}, doc, opts), do: add_section(doc, render(contents, ["##### "], opts))
  defp render({"h6", [], contents, %{}}, doc, opts), do: add_section(doc, render(contents, ["###### "], opts))

  # paragraph tag
  defp render({"p", [], contents, %{}}, doc, opts), do: add_section(doc, render(contents, [], opts))

  # links
  defp render({"a", [{"href", path}], contents, %{}}, doc, opts),
    do: ["(#{path})", "]", render(contents, [], opts), "[" | doc]

  # code
  defp render({"code", [{"class", "inline"}], contents, %{}}, doc, _opts),
    do: ["`", contents, "`" | doc]

  defp render({"pre", [], [{"code", [], contents, %{}}], %{}}, doc, _opts),
    do: ["\n```", contents, "```\n" | doc]

  # text formatting
  defp render({"em", [], contents, %{}}, doc, opts), do: ["*", render(contents, [], opts), "*" | doc]
  defp render({"strong", [], contents, %{}}, doc, opts), do: ["**", render(contents, [], opts), "**" | doc]

  # lists
  defp render({"ol", [], contents, %{}}, doc, opts), do: render(contents, doc, RenderState.parent(opts, :ol))
  defp render({"ul", [], contents, %{}}, doc, opts), do: render(contents, doc, RenderState.parent(opts, :ul))
  defp render({"li", [], contents, %{}}, doc, %{parent: :ol}), do: doc ++ [render(contents, ["1. "], nil), "\n"]
  defp render({"li", [], contents, %{}}, doc, %{parent: :ul}), do: doc ++ [render(contents, ["- "], nil), "\n"]

  # text node
  defp render(text, doc, _opts) when is_binary(text), do: [text | doc]

  # handle next element
  defp render([head | tail], doc, opts), do: render(tail, render(head, doc, opts), opts)

  defp add_section([], contents), do: [contents]
  defp add_section(doc, contents), do: [contents, "\n\n" | doc]
end
