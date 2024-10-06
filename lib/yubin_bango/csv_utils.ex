defmodule YubinBango.CsvUtils do
  @moduledoc """
  A module for CSV utilities
  """

  @headers [
    :org_code,
    :former_zipcode,
    :zipcode,
    :prefecture_kana,
    :city_kana,
    :district_kana,
    :prefecture,
    :city,
    :district,
    :is_double_zip,
    :is_subdivision,
    :is_townships,
    :is_doubled_area,
    :is_updated,
    :change_reason
  ]

  @spec decode_japan_post_csv(Enumerable.t()) :: Enumerable.t()
  def decode_japan_post_csv(stream) do
    stream
    |> CSV.decode!(headers: @headers)
  end
end
