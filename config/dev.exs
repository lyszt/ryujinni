import Config

if System.find_executable("inotifywait") == nil do
  config :file_system, backend: FileSystem.Backends.FSPoll
end

config :ryujin, Ryujin.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ryujin_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  parameters: [search_path: "ag_catalog,\"$user\",public"]

config :ryujin, RyujinWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT") || "4000")],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "C0cClJS8OoWwUtprTCpX70AOPLK3uzdbnnr/wm8NqExOQ54lP05gjte/3QxlH8BY",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:ryujin, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:ryujin, ~w(--watch)]}
  ]

config :ryujin, RyujinWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/ryujin_web/(?:controllers|live|components|router)/?.*\.(ex|heex)$"
    ]
  ]

config :ryujin, dev_routes: true

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true

config :swoosh, :api_client, false
