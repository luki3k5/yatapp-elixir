defmodule Yatapp.TranslatorTest do
  use ExUnit.Case

  setup do
    Yatapp.Fixtures.load_translations()
    :ok
  end

  test "t/3 returns proper translation for given path" do
    assert Yatapp.Translator.translate("en", "number", %{}) == 1
    assert Yatapp.Translator.translate("en", "hello", %{}) == "Hello world"
    assert Yatapp.Translator.translate("en", "hello_2.world", %{}) == "test"
    assert Yatapp.Translator.translate("en", "incomplete.path.text", %{}) == "test"
    assert Yatapp.Translator.translate("en", "hello_many", %{}) == "- John\n- Mike\n- Paul"

    assert Yatapp.Translator.translate("en", "hello_name", name: "Joe") == "Hello Joe"
    assert Yatapp.Translator.translate("en", "hello_name", %{}) == "Hello %{name}"
  end

  test "t/3 raise error for invalid key" do
    assert_raise ArgumentError, "Invalid key - must be string", fn ->
      Yatapp.Translator.translate("en", nil, %{})
    end

    assert_raise ArgumentError, "Invalid key - must be string", fn ->
      Yatapp.Translator.translate("en", %{a: 1}, %{})
    end

    assert_raise ArgumentError, "Invalid key - must be string", fn ->
      Yatapp.Translator.translate("en", [], %{})
    end
  end

  test "t/3 raise error for invalid values" do
    assert_raise ArgumentError, "Values for translation need to be a map or keyword list", fn ->
      Yatapp.Translator.translate("en", "hello_name", [1])
    end

    assert_raise ArgumentError, "Values for translation need to be a map or keyword list", fn ->
      Yatapp.Translator.translate("en", "hello_name", "test")
    end

    assert_raise ArgumentError, "Only string, boolean or number allowed for values.", fn ->
      Yatapp.Translator.translate("en", "hello_name", name: {"1", "2"})
    end

    assert_raise ArgumentError, "Only string, boolean or number allowed for values.", fn ->
      Yatapp.Translator.translate("en", "hello_name", name: %{test: "1"})
    end

    assert_raise ArgumentError, "Only string, boolean or number allowed for values.", fn ->
      Yatapp.Translator.translate("en", "hello_name", name: [1, 2, 3])
    end
  end

  test "t/3 raise error for incomplete path or missing key" do
    assert_raise ArgumentError, "Missing translation for key: en.invalid", fn ->
      Yatapp.Translator.translate("en", "invalid", %{})
    end

    assert_raise ArgumentError, "Missing translation for key: en.", fn ->
      Yatapp.Translator.translate("en", "", %{})
    end
  end

  test "t/3 fallback to default locale if passed unsupported locale" do
    assert Yatapp.Translator.translate("fr", "hello", %{}) == "Hello world"
  end

  test "t/3 fallback to default locale translation if translation empty" do
    Application.put_env(:yatapp, :locales, ~w(en de))
    Application.put_env(:yatapp, :fallback, true)

    assert Yatapp.Translator.translate("de", "empty", %{}) ==
             Yatapp.Translator.translate("en", "empty", %{})

    assert_raise ArgumentError, "Missing translation for key: en.empty2", fn ->
      Yatapp.Translator.translate("de", "empty2", %{})
    end

    Application.put_env(:yatapp, :fallback, false)

    assert Yatapp.Translator.translate("de", "empty", %{}) !=
             Yatapp.Translator.translate("en", "empty", %{})
  end
end
