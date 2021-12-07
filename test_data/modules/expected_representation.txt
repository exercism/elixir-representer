defmodule Placeholder_1 do
  alias Placeholder_1, as: Placeholder_2

  def placeholder_3 do
    Placeholder_1.placeholder_4()
    Placeholder_2.placeholder_4()
  end

  def placeholder_4 do
    :ok
  end
end

defmodule Placeholder_5.Placeholder_6.Placeholder_7 do
  alias Placeholder_5.Placeholder_6, as: Placeholder_8

  def placeholder_9 do
    Placeholder_1.placeholder_3()
    Placeholder_2.placeholder_3()
    Placeholder_5.Placeholder_6.Placeholder_7.placeholder_9()
    Placeholder_8.Placeholder_7.placeholder_9()
    __MODULE__.placeholder_9()
    External.external()
    Placeholder_1.External.external()
    Placeholder_5.External.Placeholder_7.nine()
  end

  defmodule Placeholder_10 do
  end

  defmodule Placeholder_11 do
    alias Placeholder_5.Placeholder_6.Placeholder_7.{Placeholder_10, Placeholder_11}
    alias Placeholder_8.Placeholder_7.Placeholder_11, as: Placeholder_12
    alias Placeholder_8.Placeholder_7, as: Placeholder_2
    alias External, as: Placeholder_13

    def placeholder_14 do
      External.external()
      Placeholder_13.external()
    end
  end
end
