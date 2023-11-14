defmodule One do
  alias One, as: Two

  def three do
    One.four()
    Two.four()
  end

  def four, do: :ok
end

defmodule Five.Six.Seven do
  alias Five.Six, as: Eight

  def nine do
    One.three()
    Two.three()

    Five.Six.Seven.nine()
    Eight.Seven.nine()
    __MODULE__.nine()
    # not replaced
    External.external()
    # only :One is replaced
    One.External.external()
    # nine not replaced because of External
    Five.External.Seven.nine()
  end

  defmodule Ten do
  end

  defmodule Eleven do
    alias Five.Six.Seven.{Ten, Eleven}
    alias Eight.Seven.Eleven, as: Twelve
    alias Eight.Seven, as: Two

    alias External, as: Thirteen

    def fourteen do
      External.external()
      Thirteen.external()
    end
  end
end
