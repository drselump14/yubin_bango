import Config

if Mix.env() == :dev do
  config :git_hooks,
    auto_install: true,
    verbose: true,
    hooks: [
      pre_commit: [
        tasks: [
          {:cmd, "mix lint.compile_and_format"}
        ]
      ],
      pre_push: [
        tasks: [
          {:mix_task, :"lint.hex_audit", []},
          {:mix_task, :dialyzer, []},
          {:mix_task, :test, ["--color"]},
          {:cmd, "echo 'success!'"}
        ]
      ]
    ]
end
