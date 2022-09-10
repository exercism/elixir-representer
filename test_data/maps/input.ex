defmodule Clock do
  def midnight() do
    hour = 0

    %{
      hour: hour,
      minute: 0,
      second: 0
    }
  end

  def tick(clock) do
    minute = clock.minute + 1
    %{minute: minute | clock}
  end
end
