defmodule Representer do
  @moduledoc false

  alias Representer.Mapping

  def process(file, code_output, mapping_output) do
    {represented_ast, mapping} =
      file
      |> File.read!()
      |> represent

    File.write!(code_output, Macro.to_string(represented_ast) <> "\n")
    File.write!(mapping_output, to_string(mapping))
  end

  def represent(code) do
    {ast, mapping} =
      code
      |> Code.string_to_quoted!()
      |> Macro.prewalk(&add_meta/1)
      |> Macro.prewalk(Mapping.init(), &define_placeholders/2)

    ast
    # names in local function calls can only be exchanged after all names in function definitions were exchanged
    |> Macro.prewalk(mapping, &use_existing_placeholders/2)
    |> Macro.prewalk(&drop_docstring/1)
    |> Macro.prewalk(&drop_line_meta/1)
    |> Macro.prewalk(&add_parentheses_in_pipes/1)
  end

  @doc """
  """
  def add_meta({:"::", _, [_, {:binary, meta, _} = bin] = args} = node) do
    meta = Keyword.put(meta, :visited?, true)
    bin = Tuple.delete_at(bin, 1) |> Tuple.insert_at(1, meta)
    args = List.replace_at(args, 1, bin)
    _node = Tuple.delete_at(node, 2) |> Tuple.append(args)
  end

  def add_meta(node), do: node

  def define_placeholders({_, meta, _} = node, represented) do
    if meta[:visited?] do
      {node, represented}
    else
      do_define_placeholders(node, represented)
    end
  end

  def define_placeholders(node, represented) do
    do_define_placeholders(node, represented)
  end

  # module definition
  defp do_define_placeholders(
         {:defmodule, meta1, [{:__aliases__, meta2, module_name}, content]},
         represented
       ) do
    {:ok, represented, names} = Mapping.get_placeholder(represented, module_name)
    node = {:defmodule, meta1, [{:__aliases__, meta2, names}, content]}
    {node, represented}
  end

  # module alias
  defp do_define_placeholders(
         {:alias, meta, [module, [as: {:__aliases__, meta2, module_alias}]]},
         represented
       ) do
    {:ok, represented, names} = Mapping.get_placeholder(represented, module_alias)
    node = {:alias, meta, [module, [as: {:__aliases__, meta2, names}]]}
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

        {:ok, represented, mapped_name} = Mapping.get_placeholder(represented, name3)
        meta2 = Keyword.put(meta2, :visited?, true)
        meta3 = Keyword.put(meta3, :visited?, true)

        {[{name, meta2, [{mapped_name, meta3, args3} | args2_tail]} | args_tail], represented}
      else
        {:ok, represented, mapped_name} = Mapping.get_placeholder(represented, name)
        meta2 = Keyword.put(meta2, :visited?, true)

        {[{mapped_name, meta2, args2} | args_tail], represented}
      end

    node = {op, meta, args}
    {node, represented}
  end

  # variables
  # https://elixir-lang.org/getting-started/meta/quote-and-unquote.html
  # "The third element is either a list of arguments for the function call or an atom. When this element is an atom, it means the tuple represents a variable."
  @special_var_names [:__CALLER__, :__DIR__, :__ENV__, :__MODULE__, :__STACKTRACE__, :..., :_]
  defp do_define_placeholders({atom, meta, context}, represented)
       when is_atom(atom) and is_nil(context) and atom not in @special_var_names do
    {:ok, represented, mapped_term} = Mapping.get_placeholder(represented, atom)

    {{mapped_term, meta, context}, represented}
  end

  defp do_define_placeholders(node, represented), do: {node, represented}

  def use_existing_placeholders({_, meta, _} = node, represented) do
    if meta[:visited?] do
      {node, represented}
    else
      do_use_existing_placeholders(node, represented)
    end
  end

  def use_existing_placeholders(node, represented) do
    do_use_existing_placeholders(node, represented)
  end

  # module names
  defp do_use_existing_placeholders({:__aliases__, meta, module_name}, represented)
       when is_list(module_name) do
    module_name =
      Enum.map(
        module_name,
        &(Mapping.get_existing_placeholder(represented, &1) || &1)
      )

    meta = Keyword.put(meta, :visited?, true)
    {{:__aliases__, meta, module_name}, represented}
  end

  # local function calls
  defp do_use_existing_placeholders({atom, meta, context}, represented)
       when is_atom(atom) and is_list(context) do
    placeholder = Mapping.get_existing_placeholder(represented, atom)

    # if there is no placeholder for this name, that means it's an imported or a standard library function/macro/special form
    atom = placeholder || atom

    {{atom, meta, context}, represented}
  end

  # external function calls
  defp do_use_existing_placeholders(
         {{:., meta2, [{:__aliases__, _, module_name} = module, function_name]}, meta, context},
         represented
       )
       when is_list(module_name) and is_atom(function_name) do
    {{_, _, new_module_name} = module, _} = do_use_existing_placeholders(module, represented)

    all_replaced? =
      Enum.zip_with(module_name, new_module_name, &(&1 != &2))
      |> Enum.all?()

    placeholder_function_name =
      if all_replaced? do
        Mapping.get_existing_placeholder(represented, function_name)
      else
        # hack: assuming that if a module has no complete placeholder name, that means it's not being defined in this file
        # TODO: fix when dealing with aliases
        nil
      end

    function_name = placeholder_function_name || function_name

    meta2 = Keyword.put(meta2, :visited?, true)

    {{{:., meta2, [module, function_name]}, meta, context}, represented}
  end

  # external function calls via __MODULE__
  defp do_use_existing_placeholders(
         {{:., meta2, [{:__MODULE__, meta3, args3}, function_name]}, meta, context},
         represented
       )
       when is_atom(function_name) do
    placeholder_function_name = Mapping.get_existing_placeholder(represented, function_name)

    function_name = placeholder_function_name || function_name
    meta2 = Keyword.put(meta2, :visited?, true)
    meta3 = Keyword.put(meta3, :visited?, true)

    {{{:., meta2, [{:__MODULE__, meta3, args3}, function_name]}, meta, context}, represented}
  end

  defp do_use_existing_placeholders(node, represented), do: {node, represented}

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

  def add_parentheses_in_pipes({:|>, meta, [input, {name, meta2, atom}]}) when is_atom(atom) do
    {:|>, meta, [input, {name, meta2, []}]}
  end

  def add_parentheses_in_pipes(node), do: node
end
