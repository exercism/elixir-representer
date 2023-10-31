defmodule Clock do
  def midnight() do
    hour = 0

    %Time{
      microsecond: {0, 0},
      calendar: Calendar.ISO,
      hour: hour,
      minute: 0,
      second: 0
    }
  end

  def hour_regex() do
    r = %Regex{
      opts: "",
      re_version: {"8.44 2020-02-12", :little},
      re_pattern:
        {:re_pattern, 0, 0, 0,
         <<69, 82, 67, 80, 81, 0, 0, 0, 0, 0, 0, 0, 65, 0, 0, 0, 255, 255, 255, 255, 255, 255,
           255, 255, 0, 0, 58, 0, 0, 0, 0, 0, 0, 0, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 131, 0, 13, 7, 7, 29, 58, 7, 7, 29, 58, 7,
           7, 120, 0, 13, 0>>},
      source: "\\d\\d:\\d\\d:\\d\\d"
    }

    %Regex{r | re_version: {"8.44 2020-02-14", :little}, opts: "i"}
  end
end
