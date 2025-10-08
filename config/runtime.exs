# config/runtime.exs
import Config
import Dotenvy

env_dir_prefix = System.get_env("RELEASE_ROOT") || Path.expand("./envs")

source!([
  Path.absname(".env", env_dir_prefix),
  Path.absname("#{config_env()}.env", env_dir_prefix),
  System.get_env()
  ])

vendor_root = Path.expand(System.get_env("VENDOR_DIR") || "./vendor", File.cwd!())
bin_dir = Path.join(vendor_root, "bin")
streamlink_bin_dir = Path.join(vendor_root, "streamlink-venv/bin")

ffmpeg_exec =
  System.get_env("FFMPEG_PATH") ||
    Path.join(bin_dir, "ffmpeg")

ytdl_exec =
  System.get_env("YOUTUBEDL_PATH") ||
    Path.join(bin_dir, "youtube-dl")

streamlink_exec =
  System.get_env("STREAMLINK_PATH") ||
    Path.join(streamlink_bin_dir, "streamlink")

config :nostrum,
  token: env!("DISCORD_TOKEN", :string!),
  gateway_intents: [:direct_messages, :guild_messages, :message_content],
  ffmpeg: ffmpeg_exec,
  youtubedl: ytdl_exec,
  streamlink: streamlink_exec
