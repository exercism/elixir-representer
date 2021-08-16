defmodule User do
  def first_name(user), do: user.first_name
  defp registered_in_last_quarter?(user), do: true
  defmacro validate_user!, do: true
  defmacrop do_validate_user, do: true
  defguard is_even(term) when is_integer(term) and rem(term, 2) == 0
  defguardp is_odd(term) when is_integer(term) and rem(term, 2) == 1

  def even?(term) when is_even(term), do: true
  def even?(term), do: false
  def odd?(term), do: is_odd(term)
end
