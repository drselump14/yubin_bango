defmodule YubinBangoTest do
  use ExUnit.Case
  alias YubinBango.Address

  doctest YubinBango

  setup_all do
    {:ok, pid} = YubinBango.start_link([])
    {:ok, pid: pid}
  end

  test "lookup/1" do
    assert {:ok, %Address{}} = YubinBango.lookup("105-0004")
    assert {:ok, %Address{}} = YubinBango.lookup("1050004")
    assert {:error, :wrong_format, _} = YubinBango.lookup("#1050004")
    assert {:error, :wrong_format, _} = YubinBango.lookup("12345678")
    assert {:error, :not_found} = YubinBango.lookup("1234567")
  end
end
