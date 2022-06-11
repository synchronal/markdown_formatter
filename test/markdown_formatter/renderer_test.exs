defmodule MarkdownFormatter.RendererTest do
  # @related [subject](/lib/markdown_formatter/renderer.ex)
  use ExUnit.Case
  doctest MarkdownFormatter.Renderer
  alias MarkdownFormatter.Renderer

  describe "to_markdown" do
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
  end
end
