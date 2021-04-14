defmodule CapteurTest do
  use ExUnit.Case
  doctest Capteur

  test "greets the world" do
    assert Capteur.hello() == :world
  end
end
