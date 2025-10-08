# config/runtime.exs
import Config
import Dotenvy

env_dir_prefix = System.get_env("RELEASE_ROOT") || Path.expand("./envs")

source!([
  Path.absname(".env", env_dir_prefix),
  Path.absname("#{config_env()}.env", env_dir_prefix),
  System.get_env()
  ])

config :nostrum,
  token: env!("DISCORD_TOKEN", :string!),
  gateway_intents: [:direct_messages, :guild_messages, :message_content]
