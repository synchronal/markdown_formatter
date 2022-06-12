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

  defmodule Q do
    @moduledoc false

    @enforce_keys [:q]
    defstruct [:q]

    @type t() :: %__MODULE__{
            q: :queue.queue()
          }

    def new(values \\ [])
    def new(%Q{} = q), do: q
    def new(values), do: __struct__(q: :queue.from_list(values))

    def push(q, value), do: __struct__(q: :queue.in(value, q.q))

    defimpl Collectable do
      def into(%Q{} = q) do
        {q, &push/2}
      end

      defp push(q, {:cont, item}), do: Q.push(q, item)
      defp push(q, :done), do: q
      defp push(_q, :halt), do: :ok
    end

    defimpl Enumerable do
      def count(%Q{q: q}), do: {:ok, :queue.len(q)}
      def member?(%Q{q: q}, item), do: {:ok, :queue.member(item, q)}
      def reduce(%Q{q: q}, acc, fun), do: Enumerable.List.reduce(:queue.to_list(q), acc, fun)
      def slice(%Q{}), do: {:error, __MODULE__}
    end
  end

  alias RenderState, as: S

  @empty_queue Q.new()

  @doc "Given AST produced from Earmark, turn it back into Markdown."
  @spec to_markdown(Earmark.ast()) :: binary()
  def to_markdown(ast) when is_list(ast) do
    ast
    |> render(Q.new(), S.new())
    |> to_string()
    |> String.trim()
    |> String.replace(~r|\n\n\n*|, "\n\n")
  end

  # end recursion
  defp render([], doc, _opts), do: Enum.to_list(doc)

  # headers
  defp render({"h1", [], contents, %{}}, doc, opts), do: add_section(doc, ["# #{render(contents, Q.new(), opts)}"])
  defp render({"h2", [], contents, %{}}, doc, opts), do: add_section(doc, ["## #{render(contents, Q.new(), opts)}"])
  defp render({"h3", [], contents, %{}}, doc, opts), do: add_section(doc, ["### #{render(contents, Q.new(), opts)}"])
  defp render({"h4", [], contents, %{}}, doc, opts), do: add_section(doc, ["#### #{render(contents, Q.new(), opts)}"])
  defp render({"h5", [], contents, %{}}, doc, opts), do: add_section(doc, ["##### #{render(contents, Q.new(), opts)}"])
  defp render({"h6", [], contents, %{}}, doc, opts), do: add_section(doc, ["###### #{render(contents, Q.new(), opts)}"])

  # paragraph tag
  defp render({"p", [], contents, %{}}, doc, opts),
    do: add_section(doc, render(contents, Q.new([opts.prefix]), S.reset(opts)))

  # blockquote
  defp render({"blockquote", [], contents, %{}}, doc, opts), do: render(contents, doc, S.prefix(opts, "> "))

  # links
  defp render({"a", [{"href", path}], contents, %{}}, doc, opts),
    do: push(doc, ["[#{render(contents, Q.new(), S.reset(opts))}](#{path})"])

  # code
  defp render({"code", [{"class", "inline"}], contents, %{}}, doc, _opts),
    do: push(doc, ["`", contents, "`"])

  defp render({"pre", [], [{"code", [], contents, %{}}], %{}}, doc, _opts),
    do: push(doc, ["```\n", contents, "\n```"])

  # text formatting
  defp render({"em", [], contents, %{}}, doc, opts), do: push(doc, ["*", render(contents, Q.new(), opts), "*"])
  defp render({"strong", [], contents, %{}}, doc, opts), do: push(doc, ["**", render(contents, Q.new(), opts), "**"])

  # lists
  defp render({"ol", [], contents, %{}}, doc, opts), do: render(contents, doc, RenderState.prefix(opts, "1. "))
  defp render({"ul", [], contents, %{}}, doc, opts), do: render(contents, doc, RenderState.prefix(opts, "- "))

  defp render({"li", [], contents, %{}}, doc, opts),
    do: push(doc, [opts.prefix, render(contents, Q.new(), S.reset(opts)), "\n"])

  # text node
  defp render([text], @empty_queue, _opts) when is_binary(text), do: text
  defp render(text, @empty_queue, _opts) when is_binary(text), do: text
  defp render([text], doc, _opts) when is_binary(text), do: push(doc, text)
  defp render(text, doc, _opts) when is_binary(text), do: push(doc, text)

  # handle next element
  defp render([head | tail], doc, opts), do: render(tail, render(head, doc, opts), opts)

  # # #

  defp add_section(@empty_queue, contents), do: contents
  defp add_section(doc, contents), do: push(doc, ["\n\n", Enum.to_list(contents), "\n\n"])

  defp push(%Q{} = doc, contents), do: Q.push(doc, contents)
  defp push(doc, contents), do: doc |> Q.new() |> Q.push(contents)
end
