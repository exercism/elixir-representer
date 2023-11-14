defmodule BitStuff do
  import Bitwise, only: [:bsl]

  def powers_of_two do
    only = "something"
    zero = 1

    [
      zero: zero,
      one: bsl(1, 1),
      two: bsl(1, 2),
      three: bsl(1, 3),
    ]
  end
end
