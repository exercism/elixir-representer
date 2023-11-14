defmodule Clock do
  def midnight() do
    hour = 0

    %{
      minute: 0,
      hour: hour,
      second: 0
    }
  end

  def tick(clock) do
    minute = clock.minute + 1
    %{clock | minute: minute, hour: clock.hour}
  end
end
