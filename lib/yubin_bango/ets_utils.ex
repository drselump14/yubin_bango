defmodule YubinBango.ETSUtils do
  @moduledoc """
  A module to work with ets
  """

  alias YubinBango.Address
  alias YubinBango.CsvUtils

  @spec create_table(atom()) :: atom()
  def create_table(table_name) do
    table_name |> :ets.new([:set, :protected, :named_table, read_concurrency: true])
  end

  @spec insert_address_data(atom(), String.t(), map()) :: atom()
  def insert_address_data(table_name, key, value) do
    :ets.insert(table_name, {key, value})
  end

  def import_csv(file_path, table_name) do
    file_path
    |> File.stream!([:trim_bom, read_ahead: 100_000])
    |> CsvUtils.decode_japan_post_csv()
    |> Stream.map(fn row ->
      row
      |> Map.take([
        :zipcode,
        :prefecture,
        :city,
        :district,
        :prefecture_kana,
        :city_kana,
        :district_kana
      ])
    end)
    |> Stream.each(fn row ->
      insert_address_data(
        table_name,
        row[:zipcode],
        row
      )
    end)
    |> Stream.run()
  end

  @doc ~S"""
  Lookup the zipcode and return the result.

  ## Examples

      iex> YubinBango.ETSUtils.address_lookup(:yubin_bango, "105-0004")
      {:ok, %YubinBango.Address{city: "港区", city_kana: "ﾐﾅﾄｸ", district: "新橋", district_kana: "ｼﾝﾊﾞｼ", prefecture: "東京都", prefecture_kana: "ﾄｳｷｮｳﾄ", zipcode: "1050004"}}

      iex> YubinBango.ETSUtils.address_lookup(:yubin_bango, "1050004")
      {:ok, %YubinBango.Address{city: "港区", city_kana: "ﾐﾅﾄｸ", district: "新橋", district_kana: "ｼﾝﾊﾞｼ", prefecture: "東京都", prefecture_kana: "ﾄｳｷｮｳﾄ", zipcode: "1050004"}}

      iex> YubinBango.ETSUtils.address_lookup(:yubin_bango, "1234567")
      {:error, :not_found}

      iex> YubinBango.ETSUtils.address_lookup(:yubin_bango, "12345678")
      {:error, :wrong_format, "Please specify a 7-digit zip code. (e.g. 1234567 or 123-4567)"}
  """
  @spec address_lookup(atom(), String.t()) ::
          {:ok, Address.t()} | {:error, :not_found} | {:error, :wrong_format, String.t()}
  def address_lookup(table_name, <<zipcode::bytes-size(7)>>) when is_atom(table_name),
    do: do_lookup(table_name, zipcode)

  def address_lookup(
        table_name,
        <<zipcode_prefix::bytes-size(3)>> <> "-" <> <<zipcode_suffix::bytes-size(4)>>
      )
      when is_atom(table_name),
      do: do_lookup(table_name, zipcode_prefix <> zipcode_suffix)

  def address_lookup(table_name, _zipcode) when is_atom(table_name),
    do:
      {:error, :wrong_format,
       "Please specify a 7-digit zip code with or without hyphen. (e.g. 1234567 or 123-4567)"}

  defp do_lookup(table_name, zipcode) when is_atom(table_name) and is_binary(zipcode) do
    case :ets.lookup(table_name, zipcode) do
      [{^zipcode, address_map} | _] ->
        address = struct(Address, address_map)
        {:ok, address}

      [] ->
        {:error, :not_found}
    end
  end
end
