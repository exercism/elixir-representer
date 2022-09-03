defmodule Placeholder_1 do
  defstruct [:wheels, :doors, :color]
end

defmodule Placeholder_2 do
  alias Placeholder_1, as: Placeholder_3

  def placeholder_4(placeholder_5) do
    %Placeholder_1{placeholder_5: placeholder_5, wheels: 4, doors: 2}
  end

  def placeholder_6(placeholder_7, placeholder_5) do
    %Placeholder_3{placeholder_5: placeholder_5 | placeholder_7}
  end
end
