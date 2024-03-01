defmodule Placeholder_2 do
  defstruct [:wheels, :doors, :color]
  @type placeholder_1 :: %__MODULE__{}
end

defmodule Placeholder_3 do
  defstruct [:cars, :driving_licence]
  alias Placeholder_2, as: Placeholder_4

  def placeholder_5(placeholder_6) do
    %Placeholder_2{color: placeholder_6, doors: 2, wheels: 4}
  end

  def placeholder_7(placeholder_8, placeholder_6) do
    %Placeholder_4{
      placeholder_8
      | color: placeholder_6,
        driving_licence: placeholder_8.driving_licence
    }
  end

  def placeholder_9(placeholder_6) do
    %{color: placeholder_6, doors: 2, wheels: 4}
  end

  def placeholder_10() do
    %__MODULE__{cars: nil, driving_licence: "I can totally drive a car"}
  end
end
