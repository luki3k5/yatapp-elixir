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

  test "t/3 returns translation with value count which is not pluralized" do
    Yatapp.Fixtures.create_translation("en.days", "%{count} days")

    assert Yatapp.Translator.translate("en", "days", %{count: 10})
  end

  test "t/3 pluralize translation with base pluralizer" do
    Application.put_env(:yatapp, :pluralizer, Yatapp.Pluralization.Base)
    Application.put_env(:yatapp, :locales, ~w(en))

    Yatapp.Fixtures.create_translation("en.days.one", "%{count} day")
    Yatapp.Fixtures.create_translation("en.days.zero", "no days")
    Yatapp.Fixtures.create_translation("en.days.other", "%{count} days")

    # == "1 day"
    assert Yatapp.Translator.translate("en", "days", %{count: 1})
    # == "no days"
    assert Yatapp.Translator.translate("en", "days", %{count: 0})
    # == "3 days"
    assert Yatapp.Translator.translate("en", "days", %{count: 3})
  end

  test "t/3 pluralize translation with custom pluralizer" do
    Application.put_env(:yatapp, :pluralizer, Yatapp.Pluralization.Example)
    Application.put_env(:yatapp, :locales, ~w(en pl))

    Yatapp.Fixtures.create_translation("en.homes.one", "%{count} home")
    Yatapp.Fixtures.create_translation("en.homes.zero", "no homes")
    Yatapp.Fixtures.create_translation("en.homes.other", "%{count} homes")
    Yatapp.Fixtures.create_translation("pl.homes.one", "%{count} dom")
    Yatapp.Fixtures.create_translation("pl.homes.zero", "brak domów")
    Yatapp.Fixtures.create_translation("pl.homes.few", "%{count} domy")
    Yatapp.Fixtures.create_translation("pl.homes.many", "%{count} domów")
    Yatapp.Fixtures.create_translation("pl.homes.other", "%{count} domu")

    assert Yatapp.Translator.translate("en", "homes", %{count: 1}) == "1 home"
    assert Yatapp.Translator.translate("en", "homes", %{count: 0}) == "no homes"
    assert Yatapp.Translator.translate("en", "homes", %{count: 3}) == "3 homes"

    assert Yatapp.Translator.translate("pl", "homes", %{count: 1}) == "1 dom"
    assert Yatapp.Translator.translate("pl", "homes", %{count: 0}) == "brak domów"
    assert Yatapp.Translator.translate("pl", "homes", %{count: 3}) == "3 domy"
    assert Yatapp.Translator.translate("pl", "homes", %{count: 13}) == "13 domów"
    assert Yatapp.Translator.translate("pl", "homes", %{count: 7}) == "7 domów"
    assert Yatapp.Translator.translate("pl", "homes", %{count: 101}) == "101 domów"
    assert Yatapp.Translator.translate("pl", "homes", %{count: 104}) == "104 domy"
    assert Yatapp.Translator.translate("pl", "homes", %{count: 1.5}) == "1.5 domu"
  end
end
