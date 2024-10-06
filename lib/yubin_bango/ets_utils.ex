defmodule YubinBango.ETSUtils do
  @moduledoc """
  A module to work with ets
  """

  @spec create_table(atom()) :: atom()
  def create_table(table_name) do
    table_name |> :ets.new([:set, :protected, :named_table, read_concurrency: true])
  end

  @spec insert_address_data(atom(), String.t(), map()) :: atom()
  def insert_address_data(table_name, key, value) do
    :ets.insert(table_name, {key, value})
  end
end
