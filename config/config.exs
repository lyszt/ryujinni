import Config

config :ryujin,
  ecto_repos: [Ryujin.Repo],
  generators: [timestamp_type: :utc_datetime]

config :ryujin, RyujinWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: RyujinWeb.ErrorHTML, json: RyujinWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Ryujin.PubSub,
  live_view: [signing_salt: "8WM2Fheb"]

config :ryujin, Ryujin.Mailer, adapter: Swoosh.Adapters.Local

config :esbuild,
  version: "0.25.4",
  ryujin: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

config :tailwind,
  version: "4.1.7",
  ryujin: [
    args: ~w(--input=assets/css/app.css --output=priv/static/assets/css/app.css),
    cd: Path.expand("..", __DIR__)
  ]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
