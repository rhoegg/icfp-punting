defmodule PythonPhoneTest do
  use ExUnit.Case, async: true

  @moduletag :python

  setup do
      PythonPhone.start_link
      {:ok, []}
  end

  test "We can echo good" do
      assert true
  end

end
  