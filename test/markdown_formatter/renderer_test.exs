defmodule MarkdownFormatter.RendererTest do
  # @related [subject](/lib/markdown_formatter/renderer.ex)
  use Test.Case
  doctest MarkdownFormatter.Renderer
  alias MarkdownFormatter.Renderer

  describe "to_markdown" do
    test "renders headers" do
      [{"h1", [], ["primary"], %{}}] |> Renderer.to_markdown() |> assert_eq("# primary")
      [{"h2", [], ["secondary"], %{}}] |> Renderer.to_markdown() |> assert_eq("## secondary")
      [{"h3", [], ["tertiary"], %{}}] |> Renderer.to_markdown() |> assert_eq("### tertiary")
      [{"h4", [], ["quaternary"], %{}}] |> Renderer.to_markdown() |> assert_eq("#### quaternary")
      [{"h5", [], ["quinary"], %{}}] |> Renderer.to_markdown() |> assert_eq("##### quinary")
      [{"h6", [], ["senary"], %{}}] |> Renderer.to_markdown() |> assert_eq("###### senary")
    end

    test "renders paragraphs to content" do
      [{"p", [], ["text"], %{}}]
      |> Renderer.to_markdown()
      |> assert_eq("text")
    end

    test "renders italic" do
      [{"em", [], ["italicized content"], %{}}]
      |> Renderer.to_markdown()
      |> assert_eq("*italicized content*")
    end

    test "renders bold" do
      [{"strong", [], ["bold content"], %{}}]
      |> Renderer.to_markdown()
      |> assert_eq("**bold content**")
    end

    test "renders bold italic" do
      [{"strong", [], [{"em", [], ["bold italic content"], %{}}], %{}}]
      |> Renderer.to_markdown()
      |> assert_eq("***bold italic content***")
    end

    test "renders links" do
      "[I am a link](path/to/file.md)"
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("[I am a link](path/to/file.md)")
    end

    test "renders images" do
      "![alt text](./image.png)"
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("![alt text](./image.png)")
    end

    test "renders images with title attributes" do
      ~s|[![CI](https://github.com/synchronal/pages/actions/workflows/tests.yml/badge.svg "CI")](https://github.com/synchronal/pages/actions)|
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq(
        ~s|[![CI](https://github.com/synchronal/pages/actions/workflows/tests.yml/badge.svg "CI")](https://github.com/synchronal/pages/actions)|
      )
    end

    test "renders simple links" do
      "http://example.com/path"
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("http://example.com/path")
    end

    test "renders inline code fragments" do
      [{"p", [], [{"code", [{"class", "inline"}], ["hello"], %{}}], %{}}]
      |> Renderer.to_markdown()
      |> assert_eq("`hello`")

      [
        {"p", [],
         [
           "text ",
           {"code", [{"class", "inline"}], ["stuff"], %{}},
           " things and ",
           {"code", [{"class", "inline"}], ["junk"], %{}}
         ], %{}}
      ]
      |> Renderer.to_markdown()
      |> assert_eq("text `stuff` things and `junk`")
    end

    test "renders code blocks" do
      """
      ```
      some code
      in a block
      ```
      """
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("""
      ```
      some code
      in a block
      ```
      """)

      """
      ```elixir
      a = 1
      b = 2
      ```
      """
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("""
      ```elixir
      a = 1
      b = 2
      ```
      """)
    end

    test "renders code blocks directly after headers" do
      """
      # Header

      ```elixir
      a = b
      ```
      """
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("""
      # Header

      ```elixir
      a = b
      ```
      """)
    end

    test "renders ordered lists" do
      """
      1. first item
      2. second item
      """
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("""
      1. first item
      1. second item
      """)
    end

    test "renders unordered lists" do
      """
      * first item
      * second item
      """
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("""
      - first item
      - second item
      """)
    end

    test "formats nested text under list items" do
      """
      - item with
        nested text.
      """
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("- item with nested text.")
    end

    test "renders nested lists" do
      """
      - a list
      - item with
        - nested a nested item
        - and another
      - followed by this
      """
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("""
      - a list
      - item with
        - nested a nested item
        - and another
      - followed by this
      """)
    end

    test "renders blockquotes" do
      """
      > I am inset text
      that started with multiple lines.
      """
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("> I am inset text that started with multiple lines.")
    end

    test "renders warning and error admonition blocks" do
      """
      > #### I am a warning {: .warning}
      >
      > You should read me.
      """
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("""
      > #### I am a warning {: .warning}
      >
      > You should read me.
      """)
    end
  end

  describe "to_markdown documents" do
    test "concatenates sections with \\n\\n" do
      """
      # header

      some content [with a link](/path/to/file.txt).

      and some other text

      * Unordered list
      * With elements

      > Some block quote text
      that wraps lines.

      1. Ordered list
      2. With elements

      ## subheader

      ![I am an image](path/to/image.png)
      """
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("""
      # header

      some content [with a link](/path/to/file.txt).

      and some other text

      - Unordered list
      - With elements

      > Some block quote text that wraps lines.

      1. Ordered list
      1. With elements

      ## subheader

      ![I am an image](path/to/image.png)
      """)
    end

    test "handles spacing between paragraphs and lists" do
      """
      some text in a paragraph

      - text in a list
      - text in a list
      """
      |> parse!()
      |> Renderer.to_markdown()
      |> assert_eq("""
      some text in a paragraph

      - text in a list
      - text in a list
      """)
    end

    test "changes line length in text" do
      html =
        """
        I am a paragraph
        block with text split across multiple lines
        that came in with strange spacing.

        - I am
          a list with
          text that should wrap across multiple lines.
          - I am
            a nested list with
            text that should wrap across multiple lines.

        > #### I am an admonition {: .warning}
        >
        > There is some extra
        > information you
        > should be aware of.

        1. I am an
           ordered list
           1. With nesting
           1. And items with
              nested things.
        2. I have multiple 
           items.

        > Blockquotes with long text
        > work
        > also, it's so cool.
        """
        |> parse!()

      html
      |> Renderer.to_markdown(line_length: 50)
      |> assert_eq("""
      I am a paragraph block with text split across
      multiple lines that came in with strange spacing.

      - I am a list with text that should wrap across
        multiple lines.
        - I am a nested list with text that should wrap
          across multiple lines.

      > #### I am an admonition {: .warning}
      >
      > There is some extra information you should be
      > aware of.

      1. I am an ordered list
        1. With nesting
        1. And items with nested things.
      1. I have multiple items.

      > Blockquotes with long text work also, it's so
      > cool.
      """)
    end
  end
end
