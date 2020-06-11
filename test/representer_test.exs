defmodule RepresenterTest do
  use ExUnit.Case

  test "run" do
    Representer.process(
      "./test_data/hello_world.ex",
      "./test_output/output.ex",
      "./test_output/mapping.json"
    )
  end
end
