defmodule CachetestTest do
  use ExUnit.Case
  doctest Cachetest

  test "greets the world" do
    assert Cachetest.hello() == :world
  end
end
