defmodule Representer.CLI do
  @concatenated_file "_concatenated.ex"
  @output_file "representation.txt"
  @output_mapping_file "mapping.json"

  def main(args \\ []) do
    if length(args) != 2 do
      IO.puts("representer requires two arguments: exercise slug, path to solution")
      # exit({:shutdown, 1})
    else
      do_main(args)
    end
  end

  def do_main(args) do
    [slug, input_path, output_path] = args
    exercise = slug |> ConvertSlug.kebab_to_snake()

    # save the cwd to go back later
    cwd = File.cwd!()

    input_path |> Path.absname() |> File.cd!()
    output_path |> Path.absname() |> File.cd!()

    # get all .ex files, put the exercise file last
    files =
      File.ls!()
      |> Enum.filter(fn f -> String.ends_with?(f, ".ex") end)
      |> Enum.sort_by(fn f -> f == "#{exercise}.ex" end)

    # join all of the files
    concatenated = Enum.map_join(files, "\n", fn f -> File.read!(f) end)

    File.write!(@concatenated_file, concatenated)

    # go back to the previous directory
    cwd |> File.cd!()

    Representer.process(
      Path.join(input_path, @concatenated_file),
      Path.join(output_path, @output_file),
      Path.join(output_path, @output_mapping_file)
    )
  end
end
