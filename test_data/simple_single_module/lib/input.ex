defmodule HelloWorld do
  @doc """
  A comment here.
  """
  def hello(name \\ "world") do
    "Hello, #{name}"
  end

  defp private_hello(name) do
    "Hi there... #{name}"
  end
end
