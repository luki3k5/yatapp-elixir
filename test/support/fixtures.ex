defmodule Yatapp.Fixtures do
  def load_translations() do
    File.read!("test/fixtures/en.json") |> Jason.decode!() |> create_translations()
    File.read!("test/fixtures/de.json") |> Jason.decode!() |> create_translations()
  end

  defp create_translations(translations) do
    Enum.each(translations, fn {key, value} -> create_translation(key, value) end)
  end

  defp create_translation(key, value) when is_map(value) do
    Enum.map(value, fn {k, v} ->
      key = Enum.join([key, k], ".")
      create_translation(key, v)
    end)
  end

  defp create_translation(key, value) do
    store = Yatapp.Config.store()
    store.put(key, value)
  end
end
