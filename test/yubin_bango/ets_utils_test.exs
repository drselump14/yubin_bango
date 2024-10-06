defmodule YubinBango.ETSUtilsTest do
  use ExUnit.Case, async: true

  alias YubinBango.Address
  alias YubinBango.ETSUtils

  @ets_table_name :yubin_bango_test

  test "address_lookup/2" do
    ETSUtils.create_table(@ets_table_name)

    ETSUtils.insert_address_data(@ets_table_name, "1050004", %{
      city: "港区",
      city_kana: "港区",
      district: "新橋",
      district_kana: "新橋",
      prefecture: "東京都",
      prefecture_kana: "東京都",
      zipcode: "1050004"
    })

    assert {:ok, %Address{}} = ETSUtils.address_lookup(@ets_table_name, "1050004")
    assert {:ok, %Address{}} = ETSUtils.address_lookup(@ets_table_name, "105-0004")
    assert {:error, :not_found} = ETSUtils.address_lookup(@ets_table_name, "1234567")
    assert {:error, :wrong_format, _} = ETSUtils.address_lookup(@ets_table_name, "12345678")
  end

  test "import_csv/2" do
    file_path = :code.priv_dir(:yubin_bango) |> Path.join("datasets/yubin_bango.csv")

    ETSUtils.create_table(@ets_table_name)
    assert :ok = ETSUtils.import_csv(file_path, @ets_table_name)
  end
end
