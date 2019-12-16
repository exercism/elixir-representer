defmodule Representer do
  @moduledoc false

  alias Representer.Mapping

  def process(file, code_output, mapping_output) do
    {represented_ast, mapping} = represent(file)

    output =
      represented_ast
      |> Macro.to_string()
      |> Code.format_string!(locals_without_parens: [def: :*, defmodule: :*])
      |> to_string()

    {mapping, output} =
      mapping.mappings
      |> Enum.reduce({mapping, output}, fn {term, placeholder}, {mapping, output} ->
        normalized = placeholder |> Atom.to_string() |> String.upcase()
        mapping = Mapping.change_mapping(mapping, term, normalized)
        output = String.replace(output, placeholder |> Atom.to_string() , normalized)

        {mapping, output}
      end)

    File.write!(code_output<>"_normalized", output)
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
