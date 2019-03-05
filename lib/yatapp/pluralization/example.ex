defmodule Yatapp.Pluralization.Example do
  @behaviour Yatapp.Pluralization

  @polish ~w(pl pl_PL)

  @impl Yatapp.Pluralization
  def parse_key(locale, key, count) do
    locale
    |> pluralizer
    |> Kernel.apply(:parse_key, [locale, key, count])
  end

  defp pluralizer(locale) when locale in @polish, do: Yatapp.Pluralization.Polish
  defp pluralizer(_), do: Yatapp.Pluralization.Base
end
