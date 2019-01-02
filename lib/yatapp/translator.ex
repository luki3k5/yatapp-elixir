defmodule Yatapp.Translator do
  @moduledoc false

  alias Yatapp.Config

  @spec translate(String.t(), String.t(), map) :: String.t() | none
  def translate(locale, key, values) when is_bitstring(key) and is_map(values) do
    locale
    |> check_locale
    |> get_translation(key)
    |> check_translation(key)
    |> check_values(values)
    |> compile(key, values)
  end

  def translate(_, key, _) when not is_bitstring(key) do
    raise ArgumentError, "Invalid key - must be string"
  end

  def translate(locale, key, values) when not is_map(values) do
    translate(locale, key, convert_values(values))
  end

  defp convert_values(values) do
    try do
      Enum.into(values, %{})
    rescue
      _ -> raise ArgumentError, "Values for translation need to be a map or keyword list"
    end
  end

  defp check_locale(locale) do
    if locale in Config.locales(), do: locale, else: Config.default_locale()
  end

  defp get_translation(locale, key) do
    locale_key = Enum.join([locale, key], ".")
    store = Config.store()
    store.get(locale_key)
  end

  defp check_translation("", key) do
    if Config.fallback(), do: get_translation(Config.default_locale(), key), else: ""
  end

  defp check_translation(translation, _), do: translation

  defp check_values(translation, values) do
    values
    |> Map.values()
    |> Enum.all?(&validate_value/1)
    |> validate_values(translation)
  end

  defp validate_value(value) do
    is_bitstring(value) or is_number(value) or is_boolean(value)
  end

  defp validate_values(true, translation), do: translation

  defp validate_values(false, _) do
    raise ArgumentError, "Only string, boolean or number allowed for values."
  end

  defp compile(text, _, _) when is_number(text), do: text

  defp compile(text, _, values) when is_bitstring(text) or is_list(text) do
    do_compile(text, values)
  end

  defp compile(nil, key, _) do
    raise ArgumentError, "Missing translation for key: #{key}"
  end

  defp do_compile(text, values) when is_bitstring(text) do
    Enum.reduce(values, text, fn {key, value}, result ->
      String.replace(result, variable(key), to_string(value))
    end)
  end

  defp do_compile(texts, values) when is_list(texts) do
    Enum.map(texts, fn text -> do_compile(text, values) end)
  end

  defp variable(key), do: "#{Config.prefix()}#{key}#{Config.suffix()}"
end
