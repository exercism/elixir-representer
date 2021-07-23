defmodule RepresenterTest do
  use ExUnit.Case

  test "run" do
    File.mkdir_p!("./test_output")

    Representer.process(
      "./test_data/hello_world.ex",
      "./test_output/representation.txt",
      "./test_output/mapping.json"
    )

    assert File.read!("./test_output/representation.txt") ==
             File.read!("./test_data/expected_representation.txt")

    assert File.read!("./test_output/mapping.json") ==
             File.read!("./test_data/expected_mapping.json")
  end
end
