defmodule Yatapp.Pluralization.Base do
  @behaviour Yatapp.Pluralization

  @impl Yatapp.Pluralization
  def parse_key(_, key, 0), do: [key, "zero"]
  def parse_key(_, key, 1), do: [key, "one"]
  def parse_key(_, key, _), do: [key, "other"]
end
