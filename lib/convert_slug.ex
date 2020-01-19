defmodule ConvertSlug do
  def kebab_to_snake(s), do: String.replace(s, "-", "_")
end
