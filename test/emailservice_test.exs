defmodule EmailserviceTest do
  use ExUnit.Case
  doctest Emailservice

  test "greets the world" do
    assert Emailservice.hello() == :world
  end
end
