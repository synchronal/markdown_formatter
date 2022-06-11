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

    test "concatenates items with \\n\\n" do
      [{"h1", [], ["header"], %{}}, {"p", [], ["some content"], %{}}, {"h2", [], ["subheader"], %{}}]
      |> Renderer.to_markdown()
      |> assert_eq(
        String.trim("""
        # header

        some content

        ## subheader
        """)
      )
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
      [{"pre", [], [{"code", [], ["some code\nin a block"], %{}}], %{}}]
      |> Renderer.to_markdown()
      |> assert_eq("```\nsome code\nin a block\n```")
    end

    test "renders ordered lists" do
      [
        {"ol", [],
         [
           {"li", [], ["first item"], %{}},
           {"li", [], ["second item"], %{}}
         ], %{}}
      ]
      |> Renderer.to_markdown()
      |> assert_eq("1. first item\n1. second item\n")
    end

    test "renders unordered lists" do
      [
        {"ul", [],
         [
           {"li", [], ["first item"], %{}},
           {"li", [], ["second item"], %{}}
         ], %{}}
      ]
      |> Renderer.to_markdown()
      |> assert_eq("- first item\n- second item\n")
    end
  end
end
