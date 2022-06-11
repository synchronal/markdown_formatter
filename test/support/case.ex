defmodule Test.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Test.Case
    end
  end

  def assert_eq(left, right) do
    assert left == right
  end
end
