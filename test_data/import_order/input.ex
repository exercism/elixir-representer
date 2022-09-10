defmodule Foo do
  alias X.Y.{Z, A}
  alias X.Y.{A, Z}
  import D
  alias X.Y.Z
  alias Banana, as: Ba
  use Z
  import A
  alias X.Y
  alias X.{Z}
  alias Z
  require C
  alias X.{Y, K.T, K}
  import B, only: [b: 0]
  alias X

  def calc(x), do: x * 2

  import C, only: [bar: 1]
  require L

  def fun() do
    use R
    import X
    alias U
    use Z

    :ok
  end
end
