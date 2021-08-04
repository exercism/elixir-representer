defmodule RepresenterTest do
  use ExUnit.Case

  setup_all do
    File.mkdir_p!("./test_output")
  end

  describe "test_data" do
    for directory <- File.ls!("test_data") do
      test "#{directory}" do
        dir = unquote(directory)
        output_directory = Path.join(["./test_output", dir])
        File.mkdir_p!(output_directory)

        input = Path.join(["./test_data", dir, "input.ex"])

        expected_representation = Path.join(["./test_data", dir, "expected_representation.txt"])
        expected_mapping = Path.join(["./test_data", dir, "expected_mapping.json"])

        output_representation = Path.join(["./test_output", dir, "representation.txt"])
        output_mapping = Path.join(["./test_output", dir, "mapping.json"])

        Representer.process(input, output_representation, output_mapping)

        assert File.read!(output_representation) == File.read!(expected_representation)
        assert File.read!(output_mapping) == File.read!(expected_mapping)
      end
    end
  end
end
