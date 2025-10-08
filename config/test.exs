import Config

config :ryujin, Ryujin.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ryujin_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :ryujin, RyujinWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "VQvdNvOFJ9XlbRm83pPg1litbClBqfyEluTvbKP5g4vm1DKfc8ZbT+p00d2gKIbQ",
  server: false

config :ryujin, Ryujin.Mailer, adapter: Swoosh.Adapters.Test

config :swoosh, :api_client, false

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view, enable_expensive_runtime_checks: true
