defmodule Representer.Mapping do
  defstruct mappings: %{}, map_count: 0

  alias __MODULE__, as: Mapping

  @module_placeholder "Placeholder_"
  @function_placeholder "placeholder_"

  defimpl String.Chars, for: __MODULE__ do
    def to_string(map) do
      content =
        map.mappings
        |> Map.to_list()
        |> Enum.map(fn {l, r} -> "  \"#{r}\": \"#{l}\"" end)
        |> Enum.sort()
        |> Enum.join(",\n")

      """
      {
      #{content}
      }
      """
    end
  end

  def init() do
    %Mapping{}
  end

  def get_placeholder(%Mapping{} = map, terms) when is_list(terms) do
    {map, names} =
      Enum.reduce(terms, {map, []}, fn
        name, {map, names} ->
          {:ok, map, name} = Mapping.get_placeholder(map, name)
          {map, [name | names]}
      end)

    {:ok, map, Enum.reverse(names)}
  end

  def get_placeholder(%Mapping{} = map, term) do
    if map.mappings[term] do
      {:ok, map, map.mappings[term]}
    else
      map = %{map | map_count: map.map_count + 1}

      placeholder =
        if capitalized?(term) do
          @module_placeholder
        else
          @function_placeholder
        end

      atom = "#{placeholder}#{map.map_count}" |> String.to_atom()

      map = %{map | mappings: Map.put(map.mappings, term, atom)}

      {:ok, map, map.mappings[term]}
    end
  end

  def get_existing_placeholder(%Mapping{} = map, term) do
    map.mappings[term]
  end

  def change_mapping(%Mapping{} = m, term, new) do
    cond do
      m.mappings[term] == nil ->
        raise ArgumentError, "mapping doesn't exist"

      true ->
        %{m | mappings: Map.put(m.mappings, term, new)}
    end
  end

  defp capitalized?(term) do
    first = term |> to_string |> String.first()
    first != String.downcase(first) and first == String.upcase(first)
  end
end
