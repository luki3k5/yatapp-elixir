defmodule Yatapp.ConfigTest do
  use ExUnit.Case

  test "default_locale/0" do
    assert Yatapp.Config.default_locale() == "en"
  end

  test "fallback/0" do
    Application.put_env(:yatapp, :fallback, true)

    assert Yatapp.Config.fallback() == true
  end

  test "locales/0" do
    Application.put_env(:yatapp, :locales, ["en", "pl"])
    assert Yatapp.Config.locales() == ["en", "pl"]
  end

  test "get/1 returns proper value" do
    assert Yatapp.Config.get(:default_locale) == "en"
    assert Yatapp.Config.get(:env) == nil
    assert Yatapp.Config.get(:enable_websocket) == false

    Application.put_env(:yatapp, :project_id, 1)
    assert Yatapp.Config.get(:project_id) == 1

    Application.put_env(:yatapp, :env, :test)
    assert Yatapp.Config.get(:env) == :test
  end
end
