defmodule AnythingAndEverything do
  def pipe_one(a, b, c), do: a |> b |> c
  def pipe_two(a, b, c), do: a |> b |> c()
  def pipe_three(a, b, c), do: a |> b() |> c
  def pipe_four(a, b, c), do: a |> b() |> c()
end
