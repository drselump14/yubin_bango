defmodule YubinBango do
  @moduledoc """
  YubinBango is a library for lookup address with Japan postal code.
  """
  use GenServer

  alias YubinBango.ETSUtils

  require Logger

  @doc """
  Start the yubin bango server.
  """
  @spec start_link([]) :: {:ok, pid()}
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    file_path = :code.priv_dir(:yubin_bango) |> Path.join("datasets/yubin_bango.csv")
    table_name = opts[:table_name] || :yubin_bango

    Logger.info("#### Creating ETS table for #{table_name} ####")
    ETSUtils.create_table(table_name)

    Logger.info("#### Inserting zipcodes to ets table... ####")

    :ok = file_path |> ETSUtils.import_csv(table_name)

    Logger.info("#### Finish inserting zipcodes to ets table... ####")

    {:ok, %{table_name: table_name}}
  end

  @impl true
  def handle_call(
        {:search, zipcode},
        _from,
        %{table_name: table_name} = state
      ) do
    response = ETSUtils.address_lookup(table_name, zipcode)

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
    {:error, :wrong_format, "Please specify a 7-digit zip code with or without hyphen. (e.g. 1234567 or 123-4567)"}
  """
  @spec lookup(String.t()) ::
          {:ok, map()} | {:error, :wrong_format, String.t()} | {:error, :not_found}
  def lookup(zipcode), do: GenServer.call(__MODULE__, {:search, zipcode})
end
