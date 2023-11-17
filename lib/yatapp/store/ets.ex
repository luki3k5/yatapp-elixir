defmodule Yatapp.Store.ETS do
  @moduledoc """
  Store that uses `:ets` as backend.
  """
  @behaviour Yatapp.Store
  @table :yatapp_translations

  @impl Yatapp.Store
  def init(opts) do
    new_opts = Keyword.get(opts, :new_opts, [:named_table, :public])

    case :ets.info(@table) do
      :undefined ->
        :ets.new(@table, new_opts)
        :ok

      _ ->
        :ok
    end
  end

  @impl Yatapp.Store
  def get(key) do
    case :ets.lookup(@table, key) do
      [{^key, translation}] ->
        translation

      [] ->
        GenServer.cast(Yatapp.TranslationsSynchronizer, :synchronize)
        raise ArgumentError, "Missing translation for key: #{key}"
    end
  end

  @impl Yatapp.Store
  def put(key, value) do
    :ets.insert(@table, {key, value})
    :ok
  end

  @impl Yatapp.Store
  def delete(key) do
    :ets.take(@table, key)
    :ok
  end
end

