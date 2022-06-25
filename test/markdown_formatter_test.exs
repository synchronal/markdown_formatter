defmodule MarkdownFormatterTest do
  # @related [subject](/lib/markdown_formatter.ex)
  use Test.Case
  doctest MarkdownFormatter

  describe "format" do
    test "reformats markdown" do
      """
      I am a paragraph
      block with text split across multiple lines
      that came in with strange spacing.

      - I am
        a list with
        text that began wrapped across multiple lines.
        - I am
          a nested list with
          text that also wrapped across multiple lines.

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
      |> MarkdownFormatter.format([])
      |> assert_eq("""
      I am a paragraph block with text split across multiple lines that came in with strange spacing.

      - I am a list with text that began wrapped across multiple lines.
        - I am a nested list with text that also wrapped across multiple lines.

      > #### I am an admonition {: .warning}
      >
      > There is some extra information you should be aware of.

      1. I am an ordered list
        1. With nesting
        1. And items with nested things.
      1. I have multiple items.

      > Blockquotes with long text work also, it's so cool.
      """)
    end

    test "changes line length in [markdown: [line_length: N]]" do
      """
      I am a paragraph
      block with text split across multiple lines
      that came in with strange spacing.

      ```
      code blocks
      respect
      the initial
      formatting
      ```

      > blockquotes across multiple lines are prefixed on each line.
      """
      |> MarkdownFormatter.format(markdown: [line_length: 30])
      |> assert_eq("""
      I am a paragraph block with
      text split across multiple
      lines that came in with
      strange spacing.

      ```
      code blocks
      respect
      the initial
      formatting
      ```

      > blockquotes across multiple
      > lines are prefixed on each
      > line.
      """)
    end
  end
end
