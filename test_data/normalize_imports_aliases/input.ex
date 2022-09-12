defmodule A do
  import B, only: [b_function: 1]
  import C, except: [c_function: 1]
  alias D, as: Dog
  def use_b(x), do: x |> b_function
  def use_c(c_function), do: c_function(0)
  def use_d(y), do: Dog.sniff(y)
end
