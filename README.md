# YubinBango

  YubinBango is a library for lookup address with Japan postal code.
  It uses ETS for blazing fast lookup address.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `yubin_bango` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yubin_bango, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/yubin_bango>.

## Usage

```elixir

# Add yubin_bango to your application to start the server when the application starts

defmodule MyApp.Application do
  use Application

  ...

  defp children do
    [
      ...,
      ...,
      {YubinBango, []}

      # or with named ets table
      # {YubinBango, [table_name: :yubin_bango_table]}
    ]
  end
end

# Lookup address with postal code

iex> YubinBango.lookup("1050004")
{:ok, %YubinBango.Address{}}

iex> YubinBango.lookup("105-0004")
{:ok, %YubinBango.Address{}}

iex> YubinBango.lookup("1050004-1")
{:error, :wrong_format, _}

iex> YubinBango.lookup("1234567")
{:error, :wrong_format, _}
```
