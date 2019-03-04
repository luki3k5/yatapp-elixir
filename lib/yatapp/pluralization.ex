defmodule Yatapp.Pluralization do
  @moduledoc """
  Behaviour for implementing pluralizer backend for translations.
  """

  @doc """
  Retrive pluralized key.
  """
  @callback parse_key(String.t(), String.t(), Integer.t()) :: String.t()
end
