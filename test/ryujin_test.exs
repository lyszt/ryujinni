defmodule RyujinTest do
  use ExUnit.Case
  doctest Ryujin

  test "greets the world" do
    assert Ryujin.hello() == :world
  end
end
