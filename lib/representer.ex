defmodule Representer do
  @moduledoc false

  alias Representer.Mapping

  def process(file, code_output, mapping_output) do
    {represented_ast, mapping} = represent(file)

    File.write!(code_output, Macro.to_string(represented_ast) <> "\n")
    File.write!(mapping_output, to_string(mapping))
  end

  def represent(file) do
    {ast, mapping} =
      file
      |> File.read!()
      |> Code.string_to_quoted!()
      |> Macro.prewalk(&add_meta/1)
      |> Macro.prewalk(Mapping.init(), &define_placeholders/2)

    ast
    # names in local function calls can only be exchanged after all names in function definitions were exchanged
    |> Macro.prewalk(mapping, &use_existing_placeholders/2)
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

  def define_placeholders({_, meta, _} = node, represented) do
    if meta[:skip] do
      {node, represented}
    else
      do_define_placeholders(node, represented)
    end
  end

  def define_placeholders(node, represented) do
    do_define_placeholders(node, represented)
  end

  defp do_define_placeholders(
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
  defp do_define_placeholders({op, meta, args}, represented) when op in @def_ops do
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
  # https://elixir-lang.org/getting-started/meta/quote-and-unquote.html
  # "The third element is either a list of arguments for the function call or an atom. When this element is an atom, it means the tuple represents a variable."
  defp do_define_placeholders({atom, meta, context}, represented)
       when is_atom(atom) and is_nil(context) do
    {:ok, represented, mapped_term} = Representer.Mapping.get_placeholder(represented, atom)

    {{mapped_term, meta, context}, represented}
  end

  defp do_define_placeholders(node, represented), do: {node, represented}

  # function calls
  defp use_existing_placeholders({atom, meta, context}, represented)
       when is_atom(atom) and is_list(context) do
    placeholder = Representer.Mapping.get_existing_placeholder(represented, atom)
    # if there is no placeholder for this name, that means it's not a local function call
    atom = placeholder || atom

    {{atom, meta, context}, represented}
  end

  defp use_existing_placeholders(node, represented), do: {node, represented}

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
