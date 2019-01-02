defmodule Yatapp do
  @moduledoc """
  Yata integration hex package.
  """

  @doc false
  def start(_type, _args), do: Yatapp.Supervisor.start_link()

  @doc """
  Search for translation in given `locale` based on provided `key`.

  ## Parameters
    - `locale`: `String` with name of locale.
    - `key`: `String` with path to translation.
    - `values`: `Map` with values that will be interpolated.

  ## Examples
      iex> Yatapp.translate("en", "hello")
      "Hello world"

      iex> Yatapp.translate("en", "hello_name", name: "Joe")
      "Hello Joe"

      iex> Yatapp.translate("en", "invalid")
      ** (ArgumentError) Missing translation for key: en.invalid

      iex> Yatapp.translate("en", "hello_name", name: %{"1" => "2"})
      ** (ArgumentError) Only string, boolean or number allowed for values.
  """
  @spec translate(String.t(), String.t(), map) :: String.t() | none
  def translate(locale, key, values \\ %{}), do: Yatapp.Translator.translate(locale, key, values)

  defdelegate locale(), to: Yatapp.Config, as: :default_locale
end
