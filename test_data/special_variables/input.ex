defmodule AnythingAndEverything do
  def some_function(parameter1, parameter2) do
    ... = parameter1
    user = %__MODULE__{}
    :math.pow(__DIR__)
    some_value.(__ENV__)
  end

  defmacro foo(_) do
    some_function(__CALLER__, __STACKTRACE__)
    _ignored = 3
  end
end
