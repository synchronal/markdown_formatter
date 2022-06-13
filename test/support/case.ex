defmodule Test.Case do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      import Test.Case
    end
  end

  def assert_eq(left, right, opts \\ [])
  def assert_eq(left, right, trim: true), do: assert(left == String.trim(right))
  def assert_eq(left, right, _opts), do: assert(left == right)

  def ok!({:ok, value}), do: value
  def ok!({:ok, value, []}), do: value

  def parse!(markdown), do: markdown |> EarmarkParser.as_ast() |> ok!()
end
