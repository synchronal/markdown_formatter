defmodule MarkdownFormatter.RendererTest do
  # @related [subject](/lib/markdown_formatter/renderer.ex)
  use ExUnit.Case
  doctest MarkdownFormatter.Renderer
  alias MarkdownFormatter.Renderer

  describe "to_markdown" do
    test "renders headers" do
      assert [{"h1", [], ["primary"], %{}}] |> Renderer.to_markdown() == "# primary"
      assert [{"h2", [], ["secondary"], %{}}] |> Renderer.to_markdown() == "## secondary"
      assert [{"h3", [], ["tertiary"], %{}}] |> Renderer.to_markdown() == "### tertiary"
      assert [{"h4", [], ["quaternary"], %{}}] |> Renderer.to_markdown() == "#### quaternary"
      assert [{"h5", [], ["quinary"], %{}}] |> Renderer.to_markdown() == "##### quinary"
      assert [{"h6", [], ["senary"], %{}}] |> Renderer.to_markdown() == "###### senary"
    end

    test "renders paragraphs to content" do
      assert [{"p", [], ["text"], %{}}]
             |> Renderer.to_markdown() == "text"
    end

    test "concatenates paragraphs" do
      assert [{"p", [], ["first"], %{}}, {"p", [], ["second"], %{}}]
             |> Renderer.to_markdown() ==
               String.trim("""
               first

               second
               """)
    end

    test "renders inline code fragments" do
      assert [{"p", [], [{"code", [{"class", "inline"}], ["hello"], %{}}], %{}}]
             |> Renderer.to_markdown() == "`hello`"

      assert [
               {"p", [],
                [
                  "text ",
                  {"code", [{"class", "inline"}], ["stuff"], %{}},
                  " things and ",
                  {"code", [{"class", "inline"}], ["junk"], %{}}
                ], %{}}
             ]
             |> Renderer.to_markdown() == "text `stuff` things and `junk`"
    end
  end
end
