defmodule YubinBango do
  use GenServer

  alias YubinBango.Address
  alias YubinBango.CsvUtils
  alias YubinBango.ETSUtils

  require Logger

  @doc """
  Start the yubin bango server.
  """
  @spec start_link([]) :: {:ok, pid()}
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  郵便番号データファイルの形式等

  全角となっている町域部分の文字数が38文字を越える場合、また半角となっているフリガナ部分の文字数が76文字を越える場合は、複数レコードに分割しています。
  この郵便番号データファイルでは、以下の順に配列しています。

  1. 全国地方公共団体コード（JIS X0401、X0402）………　半角数字
  2.（旧）郵便番号（5桁）………………………………………　半角数字
  3. 郵便番号（7桁）………………………………………　半角数字
  4. 都道府県名　…………　半角カタカナ（コード順に掲載）　（※1）
  5. 市区町村名　…………　半角カタカナ（コード順に掲載）　（※1）
  6. 町域名　………………　半角カタカナ（五十音順に掲載）　（※1）
  7. 都道府県名　…………　漢字（コード順に掲載）　（※1,2）
  8. 市区町村名　…………　漢字（コード順に掲載）　（※1,2）
  9. 町域名　………………　漢字（五十音順に掲載）　（※1,2）
  10. 一町域が二以上の郵便番号で表される場合の表示　（※3）　（「1」は該当、「0」は該当せず）
  11. 小字毎に番地が起番されている町域の表示　（※4）　（「1」は該当、「0」は該当せず）
  12. 丁目を有する町域の場合の表示　（「1」は該当、「0」は該当せず）
  13. 一つの郵便番号で二以上の町域を表す場合の表示　（※5）　（「1」は該当、「0」は該当せず）
  14. 更新の表示（※6）（「0」は変更なし、「1」は変更あり、「2」廃止（廃止データのみ使用））
  15. 変更理由　（「0」は変更なし、「1」市政・区政・町政・分区・政令指定都市施行、「2」住居表示の実施、「3」区画整理、「4」郵便区調整等、「5」訂正、「6」廃止（廃止データのみ使用））
  ※1

  文字コードには、MS漢字コード（SHIFT JIS）を使用しています。
  ※2

  文字セットとして、JIS X0208-1983を使用し、規定されていない文字はひらがなで表記しています。
  ※3

  「一町域が二以上の郵便番号で表される場合の表示」とは、町域のみでは郵便番号が特定できず、丁目、番地、小字などにより番号が異なる町域のことです。
  ※4

  「小字毎に番地が起番されている町域の表示」とは、郵便番号を設定した町域（大字）が複数の小字を有しており、各小字毎に番地が起番されているため、町域（郵便番号）と番地だけでは住所が特定できない町域のことです。
  """

  @impl true
  def init(_opts) do
    file_path = :code.priv_dir(:yubin_bango) |> Path.join("datasets/yubin_bango.csv")
    table_name = :yubin_bango

    Logger.info("#### Creating ETS table for #{table_name} ####")
    ETSUtils.create_table(table_name)

    Logger.info("#### Inserting zipcodes to ets table... ####")

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
      ETSUtils.insert_address_data(
        table_name,
        row[:zipcode],
        row
      )
    end)
    |> Stream.run()

    Logger.info("#### Finish inserting zipcodes to ets table... ####")

    {:ok, %{table_name: table_name}}
  end

  @impl true
  def handle_call(
        {:search, <<zipcode::bytes-size(7)>>},
        _from,
        %{table_name: table_name} = state
      ) do
    response =
      case :ets.lookup(table_name, zipcode) do
        [{^zipcode, address_map} | _] ->
          address = struct(Address, address_map)
          {:ok, address}

        [] ->
          {:error, :not_found}
      end

    {:reply, response, state}
  end

  @doc ~S"""
  Lookup the zipcode and return the result.

  ## Examples

    iex> YubinBango.lookup("105-0004")
    {:ok, %YubinBango.Address{city: "港区", city_kana: "ﾐﾅﾄｸ", district: "新橋", district_kana: "ｼﾝﾊﾞｼ", prefecture: "東京都", prefecture_kana: "ﾄｳｷｮｳﾄ", zipcode: "1050004"}}

    iex> YubinBango.lookup("1050004")
    {:ok, %YubinBango.Address{city: "港区", city_kana: "ﾐﾅﾄｸ", district: "新橋", district_kana: "ｼﾝﾊﾞｼ", prefecture: "東京都", prefecture_kana: "ﾄｳｷｮｳﾄ", zipcode: "1050004"}}

    iex> YubinBango.lookup("1234567")
    {:error, :not_found}

    iex> YubinBango.lookup("12345678")
    {:error, :wrong_format, "Please specify a 7-digit zip code. (e.g. 1234567 or 123-4567)"}
  """
  @spec lookup(String.t()) ::
          {:ok, map()} | {:error, :wrong_format, String.t()} | {:error, :not_found}
  def lookup(<<zipcode::bytes-size(7)>>), do: GenServer.call(__MODULE__, {:search, zipcode})

  def lookup(<<zipcode_prefix::bytes-size(3)>> <> "-" <> <<zipcode_suffix::bytes-size(4)>>),
    do: GenServer.call(__MODULE__, {:search, zipcode_prefix <> zipcode_suffix})

  def lookup(_zipcode),
    do: {:error, :wrong_format, "Please specify a 7-digit zip code. (e.g. 1234567 or 123-4567)"}
end
