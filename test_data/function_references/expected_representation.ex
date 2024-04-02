placeholder_1 = &is_integer/1
true = is_integer(3)
placeholder_1 = &Kernel.is_integer/1
true = Kernel.is_integer(3)
placeholder_1 = &+/2
5 = 2 + 3
placeholder_1 = &Kernel.+/2
5 = Kernel.+(2, 3)
placeholder_1 = &*/2
10 = 5 * 2
placeholder_1 = &Kernel.*/2
10 = Kernel.*(5, 2)
placeholder_1 = &==/2
true = :foo == :foo
placeholder_1 = &Kernel.==/2
true = Kernel.==(:foo, :foo)

defmodule Placeholder_2 do
  def placeholder_3(placeholder_4, placeholder_5) do
    placeholder_1 = &UnknownModule.unknown_function/1
    placeholder_1 = &placeholder_6/1
    placeholder_1 = &Placeholder_2.placeholder_6/1
    placeholder_1.(placeholder_4) && !placeholder_5
  end

  defp placeholder_6(placeholder_4) do
    is_integer(placeholder_4)
  end
end
