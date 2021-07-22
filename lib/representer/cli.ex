defmodule Representer.CLI do
  @concatenated_file "_concatenated.ex"
  @output_file "representation.txt"
  @output_mapping_file "mapping.json"
  @notes_file "notes.md"

  def main([slug, input_path, output_path]) do
    exercise = slug |> ConvertSlug.kebab_to_snake()

    # input_path should be a path to a mix project, so the solution is somewhere in /lib
    input_path = Path.join([Path.absname(input_path), "lib"])
    output_path = Path.absname(output_path)
    concatenated_input_file_path = Path.join([input_path, @concatenated_file])

    # get all .ex files, put the exercise file last
    files =
      Path.wildcard(Path.join([input_path, "**", "*.ex"]))
      |> Enum.filter(fn f -> !String.ends_with?(f, @concatenated_file) end)
      |> Enum.sort_by(fn f -> f == "#{exercise}.ex" end)

    # join all of the files
    concatenated = Enum.map_join(files, "\n", fn f -> File.read!(f) end)

    File.write!(concatenated_input_file_path, concatenated)

    Representer.process(
      concatenated_input_file_path,
      Path.join(output_path, @output_file),
      Path.join(output_path, @output_mapping_file),
      Path.join(output_path, @notes_file)
    )
  end

  def main(_) do
    """
    Usage
    > exercism_representer <slug> <path to solution> <path to output>
    """
    |> IO.puts()
  end
end
