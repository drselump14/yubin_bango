defmodule YubinBango.MixProject do
  use Mix.Project

  def project do
    [
      app: :yubin_bango,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.github": :test,
        "test.watch": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      package: package(),
      name: "YubinBango",
      description: description(),
      source_url: "https://github.com/drselump14/yubin_bango"
    ]
  end

  defp description do
    "YubinBango is a library for lookup address with Japan postal code. YubinBangoは日本の郵便番号から住所を検索するライブラリです。"
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:csv, "~> 3.2"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.18", only: [:dev, :test]},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:git_hooks, "~> 0.7.3", only: [:dev], runtime: false},
      {:mix_audit, "~> 2.1"},
      {:typed_struct, "~> 0.3.0"}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE),
      maintainers: ["Slamet Kristanto"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/drselump14/yubin_bango"
      }
    ]
  end
end
