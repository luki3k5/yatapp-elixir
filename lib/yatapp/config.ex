defmodule Yatapp.Config do
  @moduledoc false

  @spec default_locale() :: String.t()
  def default_locale, do: get(:default_locale) || "en"

  @spec locales() :: list(String.t())
  def locales, do: get(:locales) || ~w(en)

  @spec fallback() :: boolean
  def fallback, do: get(:fallback) || false

  @spec store() :: atom
  def store, do: get(:store) || Yatapp.Store.ETS

  @spec store_and_options() :: {atom, Keyword.t()}
  def store_and_options do
    options = get(:store_options) || []
    {store(), options}
  end

  @spec json_parser() :: atom
  def json_parser, do: get(:json_parser) || raise(ArgumentError, "No JSON parser specified")

  @spec prefix() :: String.t()
  def prefix, do: get(:var_prefix) || "%{"

  @spec suffix() :: String.t()
  def suffix, do: get(:var_suffix) || "}"

  @spec get(atom) :: nil | String.t() | integer | boolean | atom
  def get(key), do: resolve(Application.get_env(:yatapp, key))

  @spec pluralizer() :: atom
  def pluralizer, do: get(:pluralizer) || Yatapp.Pluralization.Base

  defp resolve({:system, var}), do: resolve({var, nil})
  defp resolve({:system, var, default}), do: resolve({var, default})
  defp resolve({var, :boolean}), do: System.get_env(var) == "true"
  defp resolve({var, default}), do: System.get_env(var) || default
  defp resolve({var, default, :int}), do: parse_int(resolve({var, ""}), default)
  defp resolve(value), do: value

  defp parse_int(value, default) do
    case Integer.parse(value) do
      {number, _} -> number
      :error -> default
    end
  end
end
