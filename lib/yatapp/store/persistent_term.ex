if Kernel.function_exported?(:persistent_term, :info, 0) do
  defmodule Yatapp.Store.PersistentTerm do
    @moduledoc """
    Store that uses `:persistent_term` as backend.
    """
    @behaviour Yatapp.Store

    @impl Yatapp.Store
    def init(_opts) do
      :ok
    end

    @impl Yatapp.Store
    def get(key) do
      :persistent_term.get(key)
    rescue
      ArgumentError -> raise ArgumentError, "Missing translation for key: #{key}"
    end

    @impl Yatapp.Store
    def put(key, value) do
      :persistent_term.put(key, value)
    end

    @impl Yatapp.Store
    def delete(key) do
      :persistent_term.erase(key)
      :ok
    end
  end
end
