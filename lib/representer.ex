defmodule Representer do
  @moduledoc false

  alias Representer.Mapping

  def process(file, code_output, mapping_output) do
    {represented_ast, mapping} = represent(file)

    File.write!(code_output, Macro.to_string(represented_ast) <> "\n")
    File.write!(mapping_output, to_string(mapping))
  end

  def represent(file) do
    file
    |> File.read!()
    |> Code.string_to_quoted!()
    |> Macro.prewalk(&add_meta/1)
    |> Macro.prewalk(Mapping.init(), &exchange/2)
    |> Macro.prewalk(&drop_docstring/1)
    |> Macro.prewalk(&drop_line_meta/1)
  end

  @doc """
  """
  def add_meta({:"::", _, [_, {:binary, meta, _} = bin] = args} = node) do
    meta = Keyword.put(meta, :skip, true)
    bin = Tuple.delete_at(bin, 1) |> Tuple.insert_at(1, meta)
    args = List.replace_at(args, 1, bin)
    _node = Tuple.delete_at(node, 2) |> Tuple.append(args)
  end

  def add_meta(node), do: node

  def exchange({_, meta, _} = node, represented) do
    if meta[:skip] do
      {node, represented}
    else
      do_exchange(node, represented)
    end
  end

  def exchange(node, represented) do
    do_exchange(node, represented)
  end

  defp do_exchange(
         {:defmodule, [line: x],
          [{:__aliases__, [line: x], [module_name]} = module_alias | _] = args} = node,
         represented
       ) do
    {:ok, represented, mapped_term} = Mapping.get_placeholder(represented, module_name, :module)

    module_alias = module_alias |> Tuple.delete_at(2) |> Tuple.append([mapped_term])
    args = [module_alias | args |> tl]
    node = node |> Tuple.delete_at(2) |> Tuple.append(args)

    {node, represented}
  end

  # function/macro/guard definition
  @def_ops [:def, :defp, :defmacro, :defmacrop, :defguard, :defguardp]
  defp do_exchange({op, meta, args}, represented) when op in @def_ops do
    [{name, meta2, args2} | args_tail] = args

    {args, represented} =
      if name == :when do
        # function/macro/guard definition with a guard
        [{name3, meta3, args3} | args2_tail] = args2

        {:ok, represented, mapped_name} = Representer.Mapping.get_placeholder(represented, name3)
        meta2 = Keyword.put(meta2, :skip, true)
        meta3 = Keyword.put(meta3, :skip, true)

        {[{name, meta2, [{mapped_name, meta3, args3} | args2_tail]} | args_tail], represented}
      else
        {:ok, represented, mapped_name} = Representer.Mapping.get_placeholder(represented, name)
        meta2 = Keyword.put(meta2, :skip, true)

        {[{mapped_name, meta2, args2} | args_tail], represented}
      end

    node = {op, meta, args}
    {node, represented}
  end

  # variables
  defp do_exchange({atom, meta, context} = node, represented)
       when is_atom(atom) and is_nil(context) do
    {:ok, represented, mapped_term} = Representer.Mapping.get_placeholder(represented, atom)

    {{mapped_term, meta, context}, represented}
  end

  defp do_exchange(node, represented), do: {node, represented}

  def drop_docstring({:__block__, meta, children}) do
    children =
      children
      |> Enum.reject(fn
        {:@, _, [{:moduledoc, _, _}]} -> true
        {:@, _, [{:typedoc, _, _}]} -> true
        {:@, _, [{:doc, _, _}]} -> true
        _ -> false
      end)

    {:__block__, meta, children}
  end

  def drop_docstring(node), do: node

  def drop_line_meta({marker, metadata, children}) do
    metadata = Keyword.drop(metadata, [:line])
    {marker, metadata, children}
  end

  def drop_line_meta(node), do: node
end
