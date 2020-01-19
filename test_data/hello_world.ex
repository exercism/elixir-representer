defmodule HelloWorld do
  @doc """
  A comment here.
  """
  def hello(name \\ "world") do
    "Hello, #{name}"
  end

  @spec add_then_subtract(integer(), integer(), integer()) :: integer()
  def add_then_subtract(n, a, s) do
    total = n+a
    total - s
  end

  def check_case(var) do
    case var do
      var when is_bitstring(var) -> :string
      var when is_number(var) -> :number
      var when is_boolean(var) -> :boolean
    end
  end

  def check_expand_do(), do: true
end
