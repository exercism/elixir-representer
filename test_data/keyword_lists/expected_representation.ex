defmodule Placeholder_1 do
  import Bitwise, only: [:bsl]

  def placeholder_2 do
    placeholder_3 = "something"
    placeholder_4 = 1
    [zero: placeholder_4, one: bsl(1, 1), two: bsl(1, 2), three: bsl(1, 3)]
  end
end
