defmodule ExbotTest do
  use ExUnit.Case
  doctest Exbot

  test "greets the world" do
    assert Exbot.hello() == :world
  end
end
