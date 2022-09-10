defmodule Placeholder_1 do
  def placeholder_2(placeholder_3) do
    "Hello, #{placeholder_3}"
  end

  def placeholder_2() do
    placeholder_2("Alice")
  end

  def placeholder_4(placeholder_5) do
    placeholder_6(placeholder_5, [])
  end

  defp placeholder_6([], placeholder_7) do
    placeholder_7
  end

  defp placeholder_6([placeholder_8 | placeholder_9], placeholder_7) do
    placeholder_6(placeholder_9, [placeholder_8 | placeholder_7])
  end

  def placeholder_10(placeholder_5) do
    Enum.reverse(placeholder_5)
  end

  def placeholder_11() do
    Placeholder_1.placeholder_2()
  end

  def placeholder_12(placeholder_3) do
    __MODULE__.placeholder_2(placeholder_3)
  end
end
