defmodule AnythingAndEverything do
  def hello(name) do
    "Hello, #{name}"
  end

  def hello() do
    hello("Alice")
  end

  def reverse(list) do
    do_reverse(list, [])
  end

  defp do_reverse([], acc), do: acc
  defp do_reverse([head | tail], acc) do
    do_reverse(tail, [head | acc])
  end

  def cheat_reverse(list) do
    Enum.reverse(list)
  end
end
