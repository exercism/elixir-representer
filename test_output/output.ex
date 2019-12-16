defmodule(Placeholder_1) do
  @doc "A comment here.\n"
  def(hello(placeholder_2 \\ "world")) do
    "Hello, #{placeholder_2}"
  end

  def(add_then_subtract(placeholder_3, placeholder_4, placeholder_5)) do
    placeholder_6 = placeholder_3 + placeholder_4
    placeholder_6 - placeholder_5
  end
end