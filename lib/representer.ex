defmodule Representer do
  @moduledoc false

  alias Representer.Mapping

  def process(file, code_output, mapping_output) do
    {represented_ast, mapping} =
      file
      |> File.read!()
      |> represent

    formatted_represented_string =
      represented_ast
      |> Macro.to_string()
      |> Code.format_string!(line_length: 120, force_do_end_blocks: true)
      |> IO.iodata_to_binary()

    File.write!(code_output, formatted_represented_string <> "\n")
    File.write!(mapping_output, to_string(mapping))
  end

  @spec represent(code :: String.t()) :: {Macro.t(), map()}
  def represent(code) do
    {ast, mapping} =
      code
      |> Code.string_to_quoted!()
      |> Macro.prewalk(&add_meta/1)
      |> Macro.prewalk(&order_map_and_struct_keys/1)
      # gathering type definitions
      |> Macro.prewalk(Mapping.init(), &define_type_placeholders/2)

    # replacing type definitions
    {ast, mapping} =
      Macro.prewalk(ast, mapping, &use_existing_placeholders/2)
      |> Macro.prewalk(&protect_types/1)

    # gathering function names and variables
    {ast, mapping} = Macro.prewalk(ast, mapping, &define_placeholders/2)

    ast
    # replacing function names and variables
    |> Macro.prewalk(mapping, &use_existing_placeholders/2)
    |> Macro.prewalk(&drop_docstring/1)
    |> Macro.prewalk(&drop_line_meta/1)
    |> Macro.prewalk(&add_parentheses_in_pipes/1)
  end

  # protect string interpolations
  defp add_meta({:"::", meta, [interpolate, {:binary, meta2, atom}]}) do
    meta2 = Keyword.put(meta2, :visited?, true)
    {:"::", meta, [interpolate, {:binary, meta2, atom}]}
  end

  defp add_meta(node), do: node

  defp order_map_and_struct_keys({:%{}, meta, [{:|, meta2, [map, args]}]}),
    do: {:%{}, meta, [{:|, meta2, [map, Enum.sort(args)]}]}

  defp order_map_and_struct_keys({:%{}, meta, args}), do: {:%{}, meta, Enum.sort(args)}
  defp order_map_and_struct_keys(node), do: node

  defp define_type_placeholders({_, meta, _} = node, represented) do
    if meta[:visited?] do
      {node, represented}
    else
      do_define_type_placeholders(node, represented)
    end
  end

  defp define_type_placeholders(node, represented) do
    do_define_type_placeholders(node, represented)
  end

  @typecreation ~w(type typep opaque)a
  @typespecs ~w(spec callback macrocallback)a
  # type creation and type specifications without :when
  defp do_define_type_placeholders(
         {:@, meta, [{create, meta2, [{:"::", meta3, [{name, meta4, args}, definition]}]}]},
         represented
       )
       when create in @typecreation or create in @typespecs do
    {:ok, represented, name} = Mapping.get_placeholder(represented, name)

    {args, represented} =
      cond do
        is_atom(args) ->
          {args, represented}

        args == [] ->
          {nil, represented}

        create in @typespecs ->
          args = Enum.map(args, &remove_type_parentheses/1)
          {args, represented}

        create in @typecreation ->
          args = Enum.map(args, &remove_type_parentheses/1)
          # when creating types, types may be passed as arguments to be used in the definitions
          vars = Enum.map(args, fn {var, _, nil} -> var end)
          {:ok, represented, _} = Mapping.get_placeholder(represented, vars)
          {args, represented}
      end

    definition = Macro.prewalk(definition, &remove_type_parentheses/1)
    meta = Keyword.put(meta, :visited?, true)
    meta2 = Keyword.put(meta2, :visited?, true)
    meta4 = Keyword.put(meta4, :visited?, true)

    {{:@, meta, [{create, meta2, [{:"::", meta3, [{name, meta4, args}, definition]}]}]},
     represented}
  end

  # type specifications with :when
  defp do_define_type_placeholders(
         {:@, meta,
          [
            {create, meta2,
             [{:when, meta_when, [{:"::", meta3, [{name, meta4, args}, definition]}, conditions]}]}
          ]},
         represented
       )
       when create in @typespecs do
    {:ok, represented, name} = Mapping.get_placeholder(represented, name)

    {args, represented} =
      if is_atom(args) do
        {args, represented}
      else
        args = Enum.map(args, &remove_type_parentheses/1)
        {args, represented}
      end

    conditions = Macro.prewalk(conditions, &remove_type_parentheses/1)
    # typespecs may receive variable types as arguments if they are constrained by :when
    {conditions, represented} =
      Enum.map_reduce(conditions, represented, fn {var, type}, represented ->
        {:ok, represented, var} = Mapping.get_placeholder(represented, var)
        {{var, type}, represented}
      end)

    definition = Macro.prewalk(definition, &remove_type_parentheses/1)
    meta = Keyword.put(meta, :visited?, true)
    meta2 = Keyword.put(meta2, :visited?, true)
    meta4 = Keyword.put(meta4, :visited?, true)

    {{:@, meta,
      [
        {create, meta2,
         [{:when, meta_when, [{:"::", meta3, [{name, meta4, args}, definition]}, conditions]}]}
      ]}, represented}
  end

  defp do_define_type_placeholders(node, represented), do: {node, represented}

  defp remove_type_parentheses({:"::", meta, [var, type]}) do
    {:"::", meta, [var, remove_type_parentheses(type)]}
  end

  defp remove_type_parentheses({atom, type}) when is_atom(atom) do
    {atom, remove_type_parentheses(type)}
  end

  defp remove_type_parentheses({{:., meta, path}, meta2, args}) do
    meta2 = Keyword.put(meta2, :no_parens, true)
    {{:., meta, path}, meta2, args}
  end

  defp remove_type_parentheses({type, meta, args}) when args == [] or is_atom(args) do
    meta = Keyword.put(meta, :type?, true)
    {type, meta, nil}
  end

  defp remove_type_parentheses(node), do: node

  defp protect_types({name, meta, args} = node) do
    if meta[:type?] do
      meta = meta |> Keyword.drop([:type?]) |> Keyword.put(:visited?, true)
      {name, meta, args}
    else
      node
    end
  end

  defp protect_types(node), do: node

  defp define_placeholders({_, meta, _} = node, represented) do
    if meta[:visited?] do
      {node, represented}
    else
      do_define_placeholders(node, represented)
    end
  end

  defp define_placeholders(node, represented) do
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

        {:ok, represented, mapped_name} =
          if meta3[:visited?] do
            {:ok, represented, name3}
          else
            Mapping.get_placeholder(represented, name3)
          end

        meta2 = Keyword.put(meta2, :visited?, true)
        meta3 = Keyword.put(meta3, :visited?, true)

        {[{name, meta2, [{mapped_name, meta3, args3} | args2_tail]} | args_tail], represented}
      else
        {:ok, represented, mapped_name} =
          if meta2[:visited?] do
            {:ok, represented, name}
          else
            Mapping.get_placeholder(represented, name)
          end

        meta2 = Keyword.put(meta2, :visited?, true)

        {[{mapped_name, meta2, args2} | args_tail], represented}
      end

    node = {op, meta, args}
    {node, represented}
  end

  # module attributes
  @reserved_attributes ~w(after_compile before_compile behaviour impl compile deprecated doc typedoc dialyzer external_resource file moduledoc on_definition on_load vsn derive enforce_keys optional_callbacks)a
  defp do_define_placeholders({:@, meta, [{name, meta2, value}]}, represented)
       when name not in @reserved_attributes do
    {:ok, represented, name} = Mapping.get_placeholder(represented, name)
    node = {:@, meta, [{name, meta2, value}]}
    {node, represented}
  end

  # variables
  # https://elixir-lang.org/getting-started/meta/quote-and-unquote.html
  # "The third element is either a list of arguments for the function call or an atom. When this element is an atom, it means the tuple represents a variable."
  @special_var_names [:__CALLER__, :__DIR__, :__ENV__, :__MODULE__, :__STACKTRACE__, :..., :_]
  defp do_define_placeholders({atom, meta, context}, represented)
       when is_atom(atom) and is_atom(context) and atom not in @special_var_names do
    {:ok, represented, mapped_term} = Mapping.get_placeholder(represented, atom)

    {{mapped_term, meta, context}, represented}
  end

  defp do_define_placeholders(node, represented), do: {node, represented}

  defp use_existing_placeholders({_, meta, _} = node, represented) do
    if meta[:visited?] do
      {node, represented}
    else
      do_use_existing_placeholders(node, represented)
    end
  end

  defp use_existing_placeholders(node, represented) do
    do_use_existing_placeholders(node, represented)
  end

  # module attributes that hold module or function names inside of key-value pairs.
  # Note that module attributes that hold module or function names outside of key-value pairs are excluded from this list.
  @attributes_with_key_value_pairs_that_hold_module_or_function_names ~w(compile optional_callbacks dialyzer)a
  defp do_use_existing_placeholders({:@, meta, [{name, meta2, value}]}, represented)
       when name in @attributes_with_key_value_pairs_that_hold_module_or_function_names do
    handle_list = fn list, represented ->
      Enum.map_reduce(list, represented, fn elem, represented ->
        case elem do
          {key, value} ->
            key = Mapping.get_existing_placeholder(represented, key) || key
            {{key, value}, represented}

          _ ->
            {elem, represented}
        end
      end)
    end

    {value, represented} =
      case value do
        # e.g. @dialyzer {:nowarn_function, function_name: 0}
        [{elem1, elem2}] when is_list(elem2) ->
          {elem2, represented} = handle_list.(elem2, represented)
          {[{elem1, elem2}], represented}

        # e.g. @optional_callbacks [function_name1: 0]
        [elem1] when is_list(elem1) ->
          {elem1, represented} = handle_list.(elem1, represented)
          {[elem1], represented}

        value ->
          {value, represented}
      end

    {{:@, meta, [{name, meta2, value}]}, represented}
  end

  # module names
  defp do_use_existing_placeholders({:__aliases__, meta, module_name}, represented)
       when is_list(module_name) do
    module_name =
      Enum.map(module_name, &(Mapping.get_existing_placeholder(represented, &1) || &1))

    {{:__aliases__, meta, module_name}, represented}
  end

  # variables or local function calls
  defp do_use_existing_placeholders({atom, meta, context} = node, represented)
       when is_atom(atom) do
    case Mapping.get_existing_placeholder(represented, atom) do
      nil ->
        # no representation yet, built-in type, imported, standard function/macro/special form...
        {node, represented}

      atom ->
        meta = Keyword.put(meta, :visited?, true)
        {{atom, meta, context}, represented}
    end
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
        nil
      end

    function_name = placeholder_function_name || function_name
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
    {{{:., meta2, [{:__MODULE__, meta3, args3}, function_name]}, meta, context}, represented}
  end

  defp do_use_existing_placeholders(node, represented),
    do: {node, represented}

  defp drop_docstring({:__block__, meta, children}) do
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

  defp drop_docstring(node), do: node

  defp drop_line_meta({marker, metadata, children}) do
    metadata = Keyword.drop(metadata, [:line])
    {marker, metadata, children}
  end

  defp drop_line_meta(node), do: node

  defp add_parentheses_in_pipes({:|>, meta, [input, {name, meta2, atom}]}) when is_atom(atom) do
    {:|>, meta, [input, {name, meta2, []}]}
  end

  defp add_parentheses_in_pipes(node), do: node
end
