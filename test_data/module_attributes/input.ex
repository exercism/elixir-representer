defmodule Eighteen do
  # type specifications
  @type one :: integer
  @typep two :: integer() | atom | one | one()
  @opaque three(four) :: [{:ok, four} | {:error, two}]
  @spec five(six, seventeen :: integer()) :: keyword(six) when six: atom()
  @spec seven(eight, nine) :: {eight, nine} when eight: atom(), nine: integer()
  @spec ten(eleven()) :: [eleven()] when eleven: var()
  @callback twelve(nineteen :: three(one), twenty :: any()) :: ten(any())
  @macrocallback thirteen(twentyone :: String.t()) :: Macro.t()
  @optional_callbacks twentytwo: 0, twentythree: 1
  @impl true
  def twentytwo, do: :ok
  @impl Eighteen
  def twentythree, do: :error

  # other module attributes
  @behaviour Eighteen
  @compile {:inline, twentytwo: 0}
  @deprecated "This module is pretty complex"
  @doc """
  even more without documentation
  """
  @dialyzer {:nowarn_function, twentythree: 0}

  # custom module attributes
  @twentyfour Eighteen
  @twentyfive 0

  defmodule TwentySix do
    @type fourteen() :: Eighteen.TwentySix.TwentySeven.fifteen(integer)

    defmodule TwentySeven do
      @opaque fifteen(sixteen) :: [{atom, sixteen}]
    end

    @spec seventeen(integer :: integer) :: integer
    def twentynine(integer), do: integer + 1
  end
end
