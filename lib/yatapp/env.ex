defmodule Yatapp.Env do
  @doc """
  Returns configuration for provided key.
  ## Config
  It will resolve and convert system env variables.
  ```elixir
  config :yatapp,
    config1: "string"
    config2: {"SOME_ENV", "default"}
    config3: {"SOME_NUMBER", 10, :int}
    config4: {"SOME_BOOLEAN", :boolean}
  ```
  ## Examples
      iex> Yatapp.Env.get(:server_address)
      "http://localhost:4000"
  """
  @spec get(atom) :: nil | String.t() | integer | boolean | atom
  def get(key), do: resolve(Application.get_env(:yatapp, key))
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
