defmodule Yatapp.Store do
  @moduledoc """
  Behaviour for implementing store backend for translations.
  """

  @doc """
  Init function run when application starts.
  """
  @callback init(options :: Keyword.t()) :: :ok

  @doc """
  Retrive `value` for given `key`.
  """
  @callback get(key :: term) :: value :: term | none

  @doc """
  Store `value` under given `key`.
  """
  @callback put(key :: term, value :: term) :: :ok

  @doc """
  Deletes `key` from store.
  """
  @callback delete(key :: term) :: :ok
end
