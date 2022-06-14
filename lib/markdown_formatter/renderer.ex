defmodule MarkdownFormatter.Renderer do
  # @related [test](/test/markdown_formatter/renderer_test.exs)
  @moduledoc false

  defmodule RenderState do
    @moduledoc false

    defstruct depth: 0, parent: nil, prefix: ""

    def new, do: __struct__()
    def inc(state), do: %{state | depth: state.depth + 1}
    def parent(state, parent), do: %{state | parent: parent}
    def prefix(state, prefix), do: %{state | prefix: prefix}
    def reset(state), do: %{state | parent: nil, prefix: ""}
  end

  defmodule Q do
    @moduledoc false
    # Mostly copied from the `Qex` library. Copied in here rather than used via
    # `Qex` because 1) Qex is `@opaque` and dialyzer does not like us matching on
    # `%Qex{}`, and 2) implementing `String.Chars` simplifies things immensely.

    @enforce_keys [:q]
    defstruct [:q]

    @type t() :: %__MODULE__{
            q: :queue.queue()
          }

    def new(values \\ [])
    def new(%Q{} = q), do: q
    def new(values), do: __struct__(q: :queue.from_list(List.wrap(values)))

    def push(%Q{} = q, value), do: __struct__(q: :queue.in(value, q.q))
    def push(text, value) when is_binary(text), do: new(text) |> push(value)

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

    defimpl Inspect do
      import Inspect.Algebra

      def inspect(%Q{} = q, opts) do
        concat(["Q.new(", to_doc(Enum.to_list(q), opts), ")"])
      end
    end

    defimpl String.Chars do
      def to_string(%Q{} = q),
        do: q |> Enum.to_list() |> Kernel.to_string()
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
  defp render([], doc, _opts), do: doc

  # headers
  defp render({"h1", [], contents, %{}}, doc, opts), do: add_section(doc, ["# #{render(contents, Q.new(), opts)}"])
  defp render({"h2", [], contents, %{}}, doc, opts), do: add_section(doc, ["## #{render(contents, Q.new(), opts)}"])
  defp render({"h3", [], contents, %{}}, doc, opts), do: add_section(doc, ["### #{render(contents, Q.new(), opts)}"])
  defp render({"h4", [], contents, %{}}, doc, opts), do: add_section(doc, ["#### #{render(contents, Q.new(), opts)}"])
  defp render({"h5", [], contents, %{}}, doc, opts), do: add_section(doc, ["##### #{render(contents, Q.new(), opts)}"])
  defp render({"h6", [], contents, %{}}, doc, opts), do: add_section(doc, ["###### #{render(contents, Q.new(), opts)}"])

  # paragraph tag
  defp render({"p", [], contents, %{}}, doc, opts),
    do: add_section(doc, render(contents, Q.new([opts.prefix]), S.reset(opts) |> S.parent(:p)))

  # blockquote
  defp render({"blockquote", [], contents, %{}}, doc, opts), do: render(contents, doc, S.prefix(opts, "> "))

  # links
  defp render({"a", [{"href", path}], contents, %{}}, doc, opts),
    do: push(doc, ["[#{render(contents, Q.new(), S.reset(opts))}](#{path})"])

  # code
  defp render({"code", [{"class", "inline"}], contents, %{}}, doc, _opts),
    do: push(doc, ["`", contents, "`"])

  defp render({"pre", [], [{"code", attrs, contents, %{}}], %{}}, doc, %{parent: :p}),
    do: push(doc, ["```", class(attrs), "\n", contents, "\n```"])

  defp render({"pre", [], [{"code", attrs, contents, %{}}], %{}}, doc, _opts),
    do: add_section(doc, ["```", class(attrs), "\n", contents, "\n```"])

  # text formatting
  defp render({"em", [], contents, %{}}, doc, opts), do: push(doc, ["*", render(contents, Q.new(), opts), "*"])
  defp render({"strong", [], contents, %{}}, doc, opts), do: push(doc, ["**", render(contents, Q.new(), opts), "**"])

  # lists
  defp render({"ol", [], contents, %{}}, doc, opts),
    do:
      contents
      |> render(doc, S.prefix(opts, "\n1. ") |> S.inc())

  defp render({"ul", [], contents, %{}}, doc, opts),
    do:
      contents
      |> render(doc, S.prefix(opts, "\n- ") |> S.inc())

  defp render({"li", [], contents, %{}}, doc, opts),
    do:
      doc
      |> push([with_depth(opts.prefix, opts.depth - 1), render(contents, Q.new(), S.reset(opts))])

  # text node
  defp render([text], @empty_queue, opts) when is_binary(text), do: text |> with_depth(opts.depth)
  defp render(text, @empty_queue, opts) when is_binary(text), do: text |> with_depth(opts.depth)
  defp render([text], doc, _opts) when is_binary(text), do: push(doc, text) |> to_string()
  defp render(text, doc, _opts) when is_binary(text), do: push(doc, text) |> to_string()

  # handle next element
  defp render([head], doc, opts), do: render(head, doc, opts) |> to_string()
  defp render([head | tail], doc, opts), do: render(tail, render(head, doc, opts), opts)

  # # #

  defp class([]), do: ""
  defp class([{"class", class}]), do: class

  defp add_section(@empty_queue, contents), do: contents
  defp add_section(doc, contents), do: push(doc, ["\n\n", to_string(contents), "\n\n"])

  defp push(%Q{} = doc, contents), do: Q.push(doc, contents)
  defp push(doc, contents), do: doc |> Q.new() |> Q.push(contents)

  defp with_depth(text, 0), do: text
  defp with_depth(text, depth), do: text |> String.replace("\n", "\n" <> String.duplicate(" ", depth * 2))
end
