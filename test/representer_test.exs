defmodule RepresenterTest do
  use ExUnit.Case

  test "run" do
    File.mkdir!("./test_output")

    Representer.process(
      "./test_data/hello_world.ex",
      "./test_output/representation.txt",
      "./test_output/mapping.json"
    )
  end
end
