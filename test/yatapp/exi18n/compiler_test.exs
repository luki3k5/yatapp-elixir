defmodule Yatapp.ExI18n.CompilerTest do
  use ExUnit.Case
  doctest Yatapp.ExI18n.Compiler

  test "compile/2 returns compiled text" do
    text = "hello %{test}"
    values = %{"test" => "world"}

    assert Yatapp.ExI18n.Compiler.compile("", %{}) == ""
    assert Yatapp.ExI18n.Compiler.compile(text, values) == "hello world"
    assert Yatapp.ExI18n.Compiler.compile(text, %{}) == "hello %{test}"
    assert Yatapp.ExI18n.Compiler.compile([text, "%{test}"], values) == ["hello world", "world"]
  end
end
