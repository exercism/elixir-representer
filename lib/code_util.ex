defmodule CodeUtil do
  @doc """
  remove one-line comments from file as string
  """
  @spec remove_comments(String.t()) :: String.t()
  def remove_comments(file) do
    state = %{
      in_comment: false,
      io_list: []
    }

    do_remove_comments(file, state)
  end

  # Base case - convert IOList to string
  defp do_remove_comments(<<>>, %{} = state), do: IO.iodata_to_binary(state.io_list)

  # Catch # as a part of string interpolation
  defp do_remove_comments(<<"#", "{", rest::binary>>, %{in_comment: false} = state) do
    do_remove_comments(rest, %{state | io_list: [state.io_list, "#", "{"]})
  end

  # Open comment
  defp do_remove_comments(<<"#", rest::binary>>, %{in_comment: false} = state) do
    do_remove_comments(rest, %{state | in_comment: true})
  end

  # Close comment
  defp do_remove_comments(<<"\n", rest::binary>>, %{in_comment: true} = state) do
    state =
      %{state |
        in_comment: false,
        io_list: [state.io_list, "\n"]
      }

    do_remove_comments(rest, state)
  end

  # Ignore comment content
  defp do_remove_comments(<<_::binary-size(1), rest::binary>>, %{in_comment: true} = state) do
    do_remove_comments(rest, state)
  end

  # Add character to IOList
  defp do_remove_comments(<<c::binary-size(1), rest::binary>>, %{} = state) do
    do_remove_comments(rest, %{state | io_list: [state.io_list, c]})
  end

  @doc """
  normalize doc comments from file-as-string
  """
  def normalize_doc(file) do
    state = %{
      in_doc: false,
      io_list: []
    }

    do_normalize_doc(file, state)
  end

  # Base case - convert IOList to string
  defp do_normalize_doc(<<>>, %{} = state), do: IO.iodata_to_binary(state.io_list)

  # Open doc
  defp do_normalize_doc(<<"@doc \"\"\"", rest::binary>>, %{in_doc: false} = state), do: open_doc_normalization("@doc \"\"\"", rest, state)
  defp do_normalize_doc(<<"@moduledoc \"\"\"", rest::binary>>, %{in_doc: false} = state), do: open_doc_normalization("@doc \"\"\"", rest, state)

  # Close doc
  defp do_normalize_doc(<<"\"\"\"", rest::binary>>, %{in_doc: true} = state) do
    state =
      %{state |
        in_doc: false,
        io_list: [state.io_list, "  \"\"\""]
      }

    do_normalize_doc(rest, state)
  end

  # Ignore doc content
  defp do_normalize_doc(<<_::binary-size(1), rest::binary>>, %{in_doc: true} = state) do
    do_normalize_doc(rest, state)
  end

  # Add character to IOList
  defp do_normalize_doc(<<c::binary-size(1), rest::binary>>, %{} = state) do
    do_normalize_doc(rest, %{state | io_list: [state.io_list, c]})
  end

  defp open_doc_normalization(opener, rest, state) do
    state =
      %{ state |
        in_doc: true,
        io_list: [state.io_list, opener, "\n", "  Doc contents removed for normalization\n"]
      }

      do_normalize_doc(rest, state)
  end
end
