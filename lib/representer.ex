defmodule Representer do
  @moduledoc false

  alias Representer.Mapping

  def process(file, code_output, mapping_output) do
    {_represented_ast, mapping} = represent(file)

    output =
      file
      |> File.read!()
      |> Code.format_string!(force_do_end_blocks: true)
      |> to_string()

    {mapping, output} =
      mapping.mappings
      |> Enum.reduce({mapping, output}, fn {term, placeholder}, {mapping, output} ->
        str_term = term |> Atom.to_string()
        normalized = placeholder |> Atom.to_string() |> String.upcase()
        mapping = Mapping.change_mapping(mapping, term, normalized)
        re = Regex.compile!("([\[\{\(\s])(#{str_term})([\]\}\)\s\n\(),])")
        output = Regex.replace(re, output, "\\1#{normalized}\\3")

        {mapping, output}
      end)

    File.write!(code_output, output)
    File.write!(mapping_output, to_string(mapping))
  end

  def represent(file) do
    file
    |> File.read!()
    |> Code.string_to_quoted!()
    |> Macro.prewalk(&add_meta/1)
    |> Macro.prewalk(Mapping.init(), &exchange/2)
  end

  @doc """
  """
  def add_meta({:"::", _, [_, {:binary, meta, _} = bin] = args} = node) do
    meta = Keyword.put(meta, :binary_helper, true)
    bin = Tuple.delete_at(bin, 1) |> Tuple.insert_at(1, meta)
    args = List.replace_at(args, 1, bin)
    _node = Tuple.delete_at(node, 2) |> Tuple.append(args)
  end

  def add_meta(node), do: node

  def exchange({:defmodule, [line: x], [{:__aliases__, [line: x], [module_name]} = module_alias | _] = args} = node, represented) do
    {:ok, represented, mapped_term} = Mapping.get_placeholder(represented, module_name, :module)

    module_alias = module_alias |> Tuple.delete_at(2) |> Tuple.append([mapped_term])
    args = [module_alias | (args |> tl)]
    node = node |> Tuple.delete_at(2) |> Tuple.append(args)

    {node, represented}
  end

  def exchange({:def, _, [{function_name, _, _} = function_head | _] = args} = node, represented) do
    {:ok, represented, mapped_function_name} = Representer.Mapping.get_placeholder(represented, function_name)

    function_head = function_head |> Tuple.delete_at(0) |> Tuple.insert_at(0, mapped_function_name)
    args = [function_head | (args |> tl)]
    node = node |> Tuple.delete_at(2) |> Tuple.append(args)

    {node, represented}
  end

  def exchange({atom, meta, context} = node, represented)
      when is_atom(atom) and is_nil(context) do
    if meta[:binary_helper] do
      {node, represented}
    else
      {:ok, represented, mapped_term} = Representer.Mapping.get_placeholder(represented, atom)

      {{mapped_term, meta, context}, represented}
    end
  end

  def exchange(node, represented), do: {node, represented}
end
