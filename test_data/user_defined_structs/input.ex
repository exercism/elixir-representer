defmodule Car do
  defstruct [:wheels, :doors, :color]
end

defmodule VroomVroom do
  defstruct [:cars, :driving_licence]
  alias Car, as: Automobile

  def create(color) do
    %Car{color: color, wheels: 4, doors: 2}
  end

  def repaint(car, color) do
    %Automobile{car | driving_licence: car.driving_licence, color: color}
  end

  def fake_create(color) do
    # map, not a struct, hence "fake"
    %{color: color, wheels: 4, doors: 2}
  end

  def authorize_driver() do
    %__MODULE__{
      driving_licence: "I can totally drive a car",
      cars: nil
    }
  end
end
