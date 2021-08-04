defmodule HelloWorld do
  @doc """
  A comment here.
  """
  def hello(name \\ "world") do
    "Hello, #{name}"
  end
end
