defmodule YubinBango.Address do
  @moduledoc """
  A struct representing a Japanese address
  """

  use TypedStruct

  typedstruct do
    field :zipcode, String.t(), enforce: true
    field :prefecture, String.t(), enforce: true
    field :prefecture_kana, String.t(), enforce: true
    field :city, String.t(), enforce: true
    field :city_kana, String.t(), enforce: true
    field :district, String.t(), enforce: true
    field :district_kana, String.t(), enforce: true
  end
end
