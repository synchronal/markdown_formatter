# Changelog

- Verify support for Elixir 1.17.0.
- *Breaking*: Drop support for Elixir older than 1.15.0.

## 0.6.0

- Unknown tags which are parsed with `verbatim: true` are rendered as-is.
- Handle image links with titles.

## 0.5.0

- Handle images.

## 0.4.1

- Fixup docs.
- Unlock `earmark`; only `earmark_parser` is used.

## 0.4.0

- Add change log to docs.
- Handle `ex_doc`-style [admonition blocks](https://hexdocs.pm/ex_doc/readme.html#admonition-blocks).

## 0.3.0

- Multi-line markdown documents are formatted with a trailing newline.

## 0.2.0

- Add `line_length` text reformatting (default 100 characters).
- Fix: sometimes spacing between block elements and lists would collapse.

## 0.1.2

- Render links inline when the text is the same as the path.
- Handle edge-case where code block is not contained in a `p` tag.

## 0.1.1

- Code blocks can be tagged with language syntax.

## 0.1.0

- Initial release.
