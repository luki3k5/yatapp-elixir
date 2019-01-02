defmodule YatappTest do
  use ExUnit.Case
  doctest Yatapp

  setup do
    Yatapp.Fixtures.load_translations()
  end
end
