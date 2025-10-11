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
  ffmpeg: ffmpeg_exec,
  youtubedl: ytdl_exec,
  streamlink: streamlink_exec,
  gateway_intents: [
      :guilds,
      :guild_members,
      :guild_bans,
      :guild_emojis,
      :guild_integrations,
      :guild_webhooks,
      :guild_invites,
      :guild_voice_states,
      :guild_presences,
      :guild_messages,
      :guild_message_reactions,
      :guild_message_typing,
      :direct_messages,
      :direct_message_reactions,
      :direct_message_typing,
      :message_content,
      :guild_scheduled_events
    ]
if System.get_env("PHX_SERVER") do
  config :ryujin, RyujinWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :ryujin, Ryujin.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6,
    parameters: [search_path: "ag_catalog,\"$user\",public"]

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :ryujin, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :ryujin, RyujinWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
