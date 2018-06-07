defmodule Yatapp.SocketClientTest do
  use ExUnit.Case

  setup do
    create_ets_table()
    Application.put_env(:yatapp, :locales, ["en", "de"])

    File.read!("test/fixtures/en.json") |> Poison.decode!() |> create_translations()
    File.read!("test/fixtures/de.json") |> Poison.decode!() |> create_translations()

    :ok
  end

  test "handle_message/5 'new_translation'" do
    assert Yatapp.SocketClient.handle_message("topic", "new_translation", %{"key" => "city", "values" => [%{"lang" => "en", "text" => "City"}, %{"lang" => "de", "text" => ""}]}, "transport", "state") == {:ok, "state"}
    assert :ets.lookup(:exi18n_translations, "en.city") == [{"en.city", "City"}]
    assert :ets.lookup(:exi18n_translations, "en.empty") == [{"en.empty", "empty"}]
    assert :ets.lookup(:exi18n_translations, "de.empty") == [{"de.empty", ""}]
  end

  test "handle_message/5 'updated_translation'" do
    # updated key and value
    assert Yatapp.SocketClient.handle_message("topic", "updated_translation", %{"old_key" => "number", "new_key" => "number_two", "values" => [%{"lang" => "en", "text" => 2}, %{"lang" => "de", "text" => 2}]}, "transport", "state") == {:ok, "state"}
    assert :ets.lookup(:exi18n_translations, "en.number") == []
    assert :ets.lookup(:exi18n_translations, "en.number_two") == [{"en.number_two", 2}]
    assert :ets.lookup(:exi18n_translations, "de.number_two") == [{"de.number_two", 2}]

    # updated value
    assert Yatapp.SocketClient.handle_message("topic", "updated_translation", %{"old_key" => "number", "new_key" => "number", "values" => [%{"lang" => "en", "text" => 2}, %{"lang" => "de", "text" => 3}]}, "transport", "state") == {:ok, "state"}
    assert :ets.lookup(:exi18n_translations, "en.number") == [{"en.number", 2}]
    assert :ets.lookup(:exi18n_translations, "de.number") == [{"de.number", 3}]
  end

  test "handle_message/5 'deleted_translation'" do
    assert Yatapp.SocketClient.handle_message("topic", "deleted_translation", %{"key" => "empty"}, "transport", "state") == {:ok, "state"}
    assert :ets.lookup(:exi18n_translations, "en.empty") == []
    assert :ets.lookup(:exi18n_translations, "de.empty") == []
  end

  defp create_ets_table do
    :ets.new(:exi18n_translations, [:named_table, :protected])
  end

  defp create_translations(map) do
    Enum.map(map, fn {key, value} ->
      create_translation(key, value)
    end)
  end

  defp create_translation(key, value)
       when is_map(value) do
    Enum.map(value, fn {k, v} ->
      key = Enum.join([key, k], ".")
      create_translation(key, v)
    end)
  end

  defp create_translation(key, value) do
    :ets.insert(:exi18n_translations, {key, value})
  end
end
