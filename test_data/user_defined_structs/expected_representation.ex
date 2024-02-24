defmodule Placeholder_1 do
  defstruct [:wheels, :doors, :color]
  @type t :: %__MODULE__{}
end

defmodule Placeholder_2 do
  defstruct [:cars, :driving_licence]
  alias Placeholder_1, as: Placeholder_3

  def placeholder_4(placeholder_5) do
    %Placeholder_1{color: placeholder_5, doors: 2, wheels: 4}
  end

  def placeholder_6(placeholder_7, placeholder_5) do
    %Placeholder_3{
      placeholder_7
      | color: placeholder_5,
        driving_licence: placeholder_7.driving_licence
    }
  end

  def placeholder_8(placeholder_5) do
    %{color: placeholder_5, doors: 2, wheels: 4}
  end

  def placeholder_9() do
    %__MODULE__{cars: nil, driving_licence: "I can totally drive a car"}
  end
end
