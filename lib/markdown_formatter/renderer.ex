defmodule MarkdownFormatter.Renderer do
  # @related [test](/test/markdown_formatter/renderer_test.exs)
  @moduledoc false

  defmodule RenderState do
    @moduledoc false

    defstruct prefix: ""

    def new, do: __struct__()
    def prefix(state, prefix), do: %{state | prefix: prefix}
    def reset(state), do: %{state | prefix: ""}
  end

  alias RenderState, as: S

  @doc "Given AST produced from Earmark, turn it back into Markdown."
  @spec to_markdown(Earmark.ast()) :: binary()
  def to_markdown(ast) when is_list(ast) do
    ast
    |> render([], S.new())
    |> to_string()
    |> String.trim()
    |> String.replace(~r|\n\n\n*|, "\n\n")
  end

  # end recursion
  defp render([], doc, _opts), do: doc

  # headers
  defp render({"h1", [], contents, %{}}, doc, opts), do: add_section(doc, "# #{render(contents, [], opts)}")
  defp render({"h2", [], contents, %{}}, doc, opts), do: add_section(doc, "## #{render(contents, [], opts)}")
  defp render({"h3", [], contents, %{}}, doc, opts), do: add_section(doc, "### #{render(contents, [], opts)}")
  defp render({"h4", [], contents, %{}}, doc, opts), do: add_section(doc, "#### #{render(contents, [], opts)}")
  defp render({"h5", [], contents, %{}}, doc, opts), do: add_section(doc, "##### #{render(contents, [], opts)}")
  defp render({"h6", [], contents, %{}}, doc, opts), do: add_section(doc, "###### #{render(contents, [], opts)}")

  # paragraph tag
  defp render({"p", [], contents, %{}}, doc, opts), do: add_section(doc, render(contents, [opts.prefix], S.reset(opts)))

  # blockquote
  defp render({"blockquote", [], contents, %{}}, doc, opts), do: render(contents, doc, S.prefix(opts, "> "))

  # links
  defp render({"a", [{"href", path}], contents, %{}}, doc, opts),
    do: doc ++ ["[#{render(contents, [], S.reset(opts))}](#{path})"]

  # code
  defp render({"code", [{"class", "inline"}], contents, %{}}, doc, _opts),
    do: doc ++ ["`", contents, "`"]

  defp render({"pre", [], [{"code", [], contents, %{}}], %{}}, doc, _opts),
    do: doc ++ ["```\n", contents, "\n```"]

  # text formatting
  defp render({"em", [], contents, %{}}, doc, opts), do: doc ++ ["*", render(contents, [], opts), "*"]
  defp render({"strong", [], contents, %{}}, doc, opts), do: doc ++ ["**", render(contents, [], opts), "**"]

  # lists
  defp render({"ol", [], contents, %{}}, doc, opts), do: render(contents, doc, RenderState.prefix(opts, "1. "))
  defp render({"ul", [], contents, %{}}, doc, opts), do: render(contents, doc, RenderState.prefix(opts, "- "))
  defp render({"li", [], contents, %{}}, doc, opts), do: doc ++ [opts.prefix, render(contents, [], S.reset(opts)), "\n"]

  # text node
  defp render([text], [], _opts) when is_binary(text), do: text
  defp render(text, doc, _opts) when is_binary(text), do: doc ++ [text]

  # handle next element
  defp render([head | tail], doc, opts), do: render(tail, render(head, doc, opts), opts)

  defp add_section([], contents), do: [contents]
  defp add_section(doc, contents), do: doc ++ ["\n\n", contents, "\n\n"]
end
