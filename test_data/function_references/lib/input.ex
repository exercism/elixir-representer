# Kernel functions should not get placeholders at all
func = &is_integer/1
true = is_integer(3)
func = &Kernel.is_integer/1
true = Kernel.is_integer(3)

func = &+/2
5 = 2 + 3
func = &Kernel.+/2
5 = Kernel.+(2, 3)

func = &*/2
10 = 5 * 2
func = &Kernel.*/2
10 = Kernel.*(5, 2)

func = &==/2
true = :foo == :foo
func = &Kernel.==/2
true = Kernel.==(:foo, :foo)

# local functions get placeholders when defined, later their references get replaced with placeholders
defmodule Foo do
  def bar(x, y) do
    func = &UnknownModule.unknown_function/1
    func = &baz/1
    func = &Foo.baz/1

    func.(x) && !y
  end

  defp baz(x) do
    is_integer(x)
  end
end
