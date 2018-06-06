defmodule ExI18nTest do
  use ExUnit.Case

  setup do
    create_ets_table()

    File.read!("test/fixtures/en.json") |> Poison.decode!() |> create_translations()
    File.read!("test/fixtures/de.json") |> Poison.decode!() |> create_translations()

    :ok
  end

  test "locale/0" do
    assert Yatapp.ExI18n.locale() == "en"
  end

  test "fallback/0" do
    Application.put_env(:yatapp, :fallback, true)

    assert Yatapp.ExI18n.fallback() == true
  end

  test "t/3 returns proper translation for given path" do
    assert Yatapp.ExI18n.t("en", "number") == 1
    assert Yatapp.ExI18n.t("en", "hello") == "Hello world"
    assert Yatapp.ExI18n.t("en", "hello_2.world") == "test"
    assert Yatapp.ExI18n.t("en", "incomplete.path.text") == "test"
    assert Yatapp.ExI18n.t("en", "hello_many") == "- John\n- Mike\n- Paul"

    assert Yatapp.ExI18n.t("en", "hello_name", name: "Joe") == "Hello Joe"
    assert Yatapp.ExI18n.t("en", "hello_name") == "Hello %{name}"
  end

  test "t/3 raise error for invalid key" do
    assert_raise ArgumentError, "Invalid key - must be string", fn ->
      Yatapp.ExI18n.t("en", nil)
    end

    assert_raise ArgumentError, "Invalid key - must be string", fn ->
      Yatapp.ExI18n.t("en", %{a: 1})
    end

    assert_raise ArgumentError, "Invalid key - must be string", fn ->
      Yatapp.ExI18n.t("en", [])
    end
  end

  test "t/3 raise error for invalid values" do
    assert_raise ArgumentError, "Values for translation need to be a map or keyword list", fn ->
      Yatapp.ExI18n.t("en", "hello_name", [1])
    end

    assert_raise ArgumentError, "Values for translation need to be a map or keyword list", fn ->
      Yatapp.ExI18n.t("en", "hello_name", "test")
    end

    assert_raise ArgumentError, "Only string, boolean or number allowed for values.", fn ->
      Yatapp.ExI18n.t("en", "hello_name", name: {"1", "2"})
    end

    assert_raise ArgumentError, "Only string, boolean or number allowed for values.", fn ->
      Yatapp.ExI18n.t("en", "hello_name", name: %{test: "1"})
    end

    assert_raise ArgumentError, "Only string, boolean or number allowed for values.", fn ->
      Yatapp.ExI18n.t("en", "hello_name", name: [1, 2, 3])
    end
  end

  test "t/3 raise error for incomplete path or missing key" do
    assert_raise ArgumentError, "Missing translation for key: invalid", fn ->
      Yatapp.ExI18n.t("en", "invalid")
    end

    assert_raise ArgumentError, "Missing translation for key: ", fn ->
      Yatapp.ExI18n.t("en", "")
    end
  end

  test "t/3 fallback to default locale if passed unsupported locale" do
    assert Yatapp.ExI18n.t("fr", "hello") == "Hello world"
  end

  test "t/3 fallback to default locale translation if translation empty" do
    Application.put_env(:yatapp, :locales, ~w(en de))
    Application.put_env(:yatapp, :fallback, true)

    assert Yatapp.ExI18n.t("de", "empty") == Yatapp.ExI18n.t("en", "empty")

    assert_raise ArgumentError, "Missing translation for key: empty2", fn ->
      Yatapp.ExI18n.t("de", "empty2")
    end

    Application.put_env(:yatapp, :fallback, false)

    assert Yatapp.ExI18n.t("de", "empty") != Yatapp.ExI18n.t("en", "empty")
  end

  def create_ets_table do
    :ets.new(:exi18n_translations, [:named_table, :protected])
  end

  def create_translations(map) do
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
