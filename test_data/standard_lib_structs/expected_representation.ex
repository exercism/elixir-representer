defmodule Placeholder_1 do
  def placeholder_2() do
    placeholder_3 = 0
    %Time{calendar: Calendar.ISO, hour: placeholder_3, microsecond: {0, 0}, minute: 0, second: 0}
  end

  def placeholder_4() do
    %Regex{
      opts: "",
      re_pattern:
        {:re_pattern, 0, 0, 0,
         <<69, 82, 67, 80, 81, 0, 0, 0, 0, 0, 0, 0, 65, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 58, 0, 0,
           0, 0, 0, 0, 0, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
           131, 0, 13, 7, 7, 29, 58, 7, 7, 29, 58, 7, 7, 120, 0, 13, 0>>},
      re_version: {"8.44 2020-02-12", :little},
      source: "\\d\\d:\\d\\d:\\d\\d"
    }
  end
end
