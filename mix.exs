defmodule YubinBango.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :yubin_bango,
      version: "0.1.2",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "YubinBango",
        extras: ["README.md"]
      ],
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
    "YubinBango is a library for lookup address with Japan postal-code/zipcode. YubinBangoは日本の郵便番号から住所を検索するライブラリです。"
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
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:git_hooks, "~> 0.7.3", only: [:dev], runtime: false},
      {:mix_audit, "~> 2.1"},
      {:typed_struct, "~> 0.3.0"}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE priv),
      maintainers: ["Slamet Kristanto"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/drselump14/yubin_bango"
      }
    ]
  end

  defp aliases do
    [
      gp: "git.prepare",
      "dev.setup": [
        "deps.get",
        "git.prepare",
        "compile",
        "dialyzer.prepare"
      ],
      "dialyzer.prepare": [
        fn _ -> shell().info("prepare dialyzer_plt") end,
        "deps.unlock --check-unused"
      ],
      "git.prepare": [
        fn _ -> shell().info("Installing git hooks") end,
        "git_hooks.install"
      ],
      lint: [
        "lint.hex_audit",
        "lint.compile_and_format",
        "dialyzer"
      ],
      "lint.hex_audit": [
        fn _ -> shell().info("Lint Audit Hex Dependencies") end,
        "deps.audit",
        "deps.unlock --check-unused"
      ],
      "lint.compile_and_format": [
        fn _ -> shell().info("Run linter to check code formatting") end,
        "format --dry-run --check-formatted",
        "hex.audit",
        "credo --strict",
        "compile --all-warnings"
      ]
    ]
  end

  defp shell, do: Mix.shell()
end
