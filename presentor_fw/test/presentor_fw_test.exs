defmodule PresentorFwTest do
  use ExUnit.Case
  doctest PresentorFw

  test "greets the world" do
    assert PresentorFw.hello() == :world
  end
end
