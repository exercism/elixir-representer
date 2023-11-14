defmodule HelloWorld do
  @moduledoc """
  A module comment here.
  """

  @doc """
  A comment here.
  """
  def hello(name \\ "world") do
    "Hello, #{name}"
  end

  @typedoc "A type comment here."

  # Comment
  @spec add_then_subtract(integer(), integer(), integer()) :: integer()
  def add_then_subtract(n, a, s) do
    total = n+a
    total - s
  end

  def check_case(var) do # Poorly placed Comment
    case var do
      var when is_bitstring(var) -> :string
      var when is_number(var) -> :number
      var when is_boolean(var) -> :boolean
    end
  end

  def check_expand_do(), do: true
end

defmodule TestMultiple do
  def test do
    :test
  end
end
