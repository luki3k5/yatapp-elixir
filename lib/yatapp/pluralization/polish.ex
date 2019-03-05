defmodule Yatapp.Pluralization.Polish do
  @behaviour Yatapp.Pluralization

  @impl Yatapp.Pluralization
  def parse_key(_, key, 0), do: parse_key(key, :zero)
  def parse_key(_, key, 1), do: parse_key(key, :one)

  def parse_key(_, key, count) when is_integer(count) do
    mod10 = rem(count, 10)
    mod100 = rem(count, 100)

    case {two_four_check(mod10), twelve_fourteen_check(mod100), zero_n_check(mod10)} do
      {true, false, _} -> parse_key(key, :few)
      {_, true, _} -> parse_key(key, :many)
      {_, _, true} -> parse_key(key, :many)
      {_, _, _} -> parse_key(key, :other)
    end
  end

  def parse_key(_, key, _), do: parse_key(key, :other)

  defp parse_key(key, :zero), do: [key, "zero"]
  defp parse_key(key, :one), do: [key, "one"]
  defp parse_key(key, :few), do: [key, "few"]
  defp parse_key(key, :many), do: [key, "many"]
  defp parse_key(key, :other), do: [key, "other"]

  defp list_include?(list, mod), do: Enum.any?(list, fn x -> x == mod end)

  defp two_four_check(mod10), do: list_include?([2, 3, 4], mod10)

  defp twelve_fourteen_check(mod100), do: list_include?([12, 13, 14], mod100)

  defp zero_n_check(mod10), do: list_include?([0, 1, 5, 6, 7, 8, 9], mod10)
end
