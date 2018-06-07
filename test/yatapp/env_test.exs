defmodule Yatapp.EnvTest do
  use ExUnit.Case

  test "get/1 returns proper value" do
    assert Yatapp.Env.get(:default_locale) == "en"
    assert Yatapp.Env.get(:env) == nil
    assert Yatapp.Env.get(:enable_websocket) == false

    Application.put_env(:yatapp, :project_id, 1)
    assert Yatapp.Env.get(:project_id) == 1

    Application.put_env(:yatapp, :env, :test)
    assert Yatapp.Env.get(:env) == :test
  end
end
