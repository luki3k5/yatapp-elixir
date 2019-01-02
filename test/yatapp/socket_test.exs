defmodule Yatapp.SocketTest do
  use ExUnit.Case

  @store Yatapp.Store.ETS

  setup do
    Application.put_env(:yatapp, :locales, ["en", "de"])
    Yatapp.Fixtures.load_translations()

    :ok
  end

  test "handle_message/5 'new_translation'" do
    assert Yatapp.Socket.handle_message(
             "topic",
             "new_translation",
             %{
               "key" => "city",
               "values" => [%{"lang" => "en", "text" => "City"}, %{"lang" => "de", "text" => ""}]
             },
             "transport",
             %{store: @store}
           ) == {:ok, %{store: @store}}

    assert @store.get("en.city") == "City"
  end

  test "handle_message/5 'updated_translation'" do
    # updated key and value
    assert Yatapp.Socket.handle_message(
             "topic",
             "updated_translation",
             %{
               "old_key" => "number",
               "new_key" => "number_two",
               "values" => [%{"lang" => "en", "text" => 2}, %{"lang" => "de", "text" => 2}]
             },
             "transport",
             %{store: @store}
           ) == {:ok, %{store: @store}}

    assert_raise ArgumentError, "Missing translation for key: en.number", fn ->
      @store.get("en.number") == []
    end

    assert @store.get("en.number_two") == 2
    assert @store.get("de.number_two") == 2

    # updated value
    assert Yatapp.Socket.handle_message(
             "topic",
             "updated_translation",
             %{
               "old_key" => "number",
               "new_key" => "number",
               "values" => [%{"lang" => "en", "text" => 2}, %{"lang" => "de", "text" => 3}]
             },
             "transport",
             %{store: @store}
           ) == {:ok, %{store: @store}}

    assert @store.get("en.number") == 2
    assert @store.get("de.number") == 3
  end

  test "handle_message/5 'deleted_translation'" do
    assert Yatapp.Socket.handle_message(
             "topic",
             "deleted_translation",
             %{"key" => "empty"},
             "transport",
             %{store: @store}
           ) == {:ok, %{store: @store}}

    assert_raise ArgumentError, "Missing translation for key: en.empty", fn ->
      @store.get("en.empty") == []
    end

    assert_raise ArgumentError, "Missing translation for key: de.empty", fn ->
      @store.get("de.empty") == []
    end
  end
end
