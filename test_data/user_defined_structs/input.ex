defmodule Car do
  defstruct [:wheels, :doors, :color]
end

defmodule VroomVroom do
  alias Car, as: Automobile

  def create(color) do
    %Car{color: color, wheels: 4, doors: 2}
  end

  def repaint(car, color) do
    %Automobile{color: color | car}
  end
end
