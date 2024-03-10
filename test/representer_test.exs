defmodule RepresenterTest do
  use ExUnit.Case

  setup_all do
    File.mkdir_p!("./test_output")
  end

  describe "test_data" do
    test "simple_single_module" do
      test_directory("simple_single_module")
    end

    test "two_modules" do
      test_directory("two_modules")
    end

    test "macros_and_guards" do
      test_directory("macros_and_guards")
    end

    test "local_function_calls" do
      test_directory("local_function_calls")
    end

    test "special_variables" do
      test_directory("special_variables")
    end

    test "parentheses_in_pipes" do
      test_directory("parentheses_in_pipes")
    end

    test "modules" do
      test_directory("modules")
    end

    test "module_attributes" do
      test_directory("module_attributes")
    end

    test "maps" do
      test_directory("maps")
    end

    test "keyword_lists" do
      test_directory("keyword_lists")
    end

    test "user_defined_structs" do
      test_directory("user_defined_structs")
    end

    test "standard_lib_structs" do
      test_directory("standard_lib_structs")
    end

    test "import_order" do
      test_directory("import_order")
    end

    test "function_references" do
      test_directory("function_references")
    end
  end

  defp test_directory(dir) do
    output_directory = Path.join(["./test_output", dir])
    File.mkdir_p!(output_directory)

    input = Path.join(["./test_data", dir, "lib", "input.ex"])
    assert {:ok, _} = input |> File.read!() |> Code.string_to_quoted()

    expected_representation = Path.join(["./test_data", dir, "expected_representation.ex"])
    expected_mapping = Path.join(["./test_data", dir, "expected_mapping.json"])

    output_representation = Path.join(["./test_output", dir, "representation.txt"])
    output_mapping = Path.join(["./test_output", dir, "mapping.json"])

    Representer.process(input, output_representation, output_mapping)

    assert File.read!(output_representation) == File.read!(expected_representation)
    assert File.read!(output_mapping) == File.read!(expected_mapping)
    assert {:ok, _} = output_representation |> File.read!() |> Code.string_to_quoted()
  end
end
