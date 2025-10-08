# Ryujin

![Traveler traveling across the fields of a foreign land](https://i.pinimg.com/1200x/1c/df/0d/1cdf0d48e184a436a19cc61ff07c60a1.jpg)

Ryujin is the diplomatic liaison of the Clairemont · Providentia · Ryujin bot trio.
While Clairemont keeps watch over personal spaces and Providentia handles hostile actors,
Ryujin focuses on cultivating allied relationships, coordinating joint initiatives,
and keeping inter-guild channels calm. The bot is built on Elixir with [`nostrum`](https://hex.pm/packages/nostrum)
and is designed to extend into Rust-backed features for high-performance tasks.

## Highlights

- **Alliance-first automation** – DM and guild intents preconfigured for relationship management.
- **Voice-ready** – Bundled FFmpeg, Streamlink, and yt-dlp support for dispatching audio briefings.
- **Rust acceleration** – `native/ryujin` houses Rustler NIFs for compute-heavy diplomacy aides.
- **Scripted setup** – Repeatable install/run scripts keep toolchains local to the repo.

## Prerequisites

- Elixir ≥ 1.18 (with a matching Erlang/OTP release)
- PostgreSQL (defaults to `postgres`/`postgres` on `localhost`)
- Python 3 (virtualenv used for Streamlink + yt-dlp)
- `curl` and `tar` (FFmpeg download)
- Cargo/Rust toolchain if you intend to expand the native extension

Ensure both `install.sh` and `run.sh` are executable so the helper scripts run cleanly:

```bash
chmod +x install.sh run.sh
```

## Configuration

Secrets live under `envs/`. The runtime config loads:

- `envs/.env` – shared defaults
- `envs/<MIX_ENV>.env` – environment-specific overrides (e.g. `envs/dev.env`)

At minimum, define your Discord bot token:

```dotenv
# envs/.env
DISCORD_TOKEN=YOUR_DISCORD_TOKEN
```

The runtime script exports `vendor/bin` and the virtualenv so all bundled tools are
found without touching your global PATH.

## Configuration

Secrets live under `envs/`. The runtime config automatically merges:

- `envs/.env` – shared defaults
- `envs/<MIX_ENV>.env` – environment-specific overrides (e.g. `envs/dev.env`)

At minimum, define your Discord bot token:

```dotenv
# envs/.env
DISCORD_TOKEN=YOUR_DISCORD_TOKEN
```

Runtime scripts export `vendor/bin` and the virtualenv, so the bundled tooling is
available without touching your global PATH.

## Installation

Run the installer to fetch Mix dependencies and stage the media binaries locally:

```bash
./install.sh
```

The installer will:

1. Fetch and compile the Mix dependencies (skip with `SKIP_MIX=1 ./install.sh`).
2. Download the static FFmpeg build into `vendor/bin`.
3. Create `vendor/streamlink-venv`, install Streamlink and yt-dlp, and link
   `vendor/bin/youtube-dl` to the yt-dlp executable.

If Nostrum logs warnings about missing tools, rerun the installer to refresh everything.

## Running the Bot

Launch Ryujin with:

```bash
./run.sh
```

The script:

- Exports the vendor tool directories to `PATH`.
- Verifies `ffmpeg`, `ffprobe`, `youtube-dl` (yt-dlp), and `streamlink` are present.
- Fetches dependencies, runs `mix ecto.create`/`mix ecto.migrate`, compiles, and starts the bot via
  `iex -S mix`.
- Boots the node with a short name (`ryujin_dev@127.0.0.1` by default) and cookie (`ryujin_cookie`),
  making it easy to attach Observer or remote IEx sessions.
- Falls back to FileSystem's polling backend automatically if `inotifywait` is not installed, so
  live reload still works (albeit without inotify performance).

While running, Ryujin registers `Ryujin.Consumer` to respond to allied greetings—
extend `lib/ryujin/consumer.ex` with the guild workflows relevant to your coalition.

## Native Extension (Rust)

The `native/ryujin` crate is wired up with [Rustler](https://github.com/rusterlium/rustler):

- `Cargo.toml` defines the NIF crate; build it with `mix compile` or `cargo build`.
- `src/lib.rs` currently exposes a sample `add/2` NIF; expand this with
  diplomacy-focused utilities (rate calculations, scoring heuristics, etc.).
- Add new NIF functions and expose them in Elixir via `lib/ryujin.ex`.

Rust artifacts are ignored by `.gitignore`, so builds remain local to each machine.
When you introduce additional Rust dependencies, run `cargo check` under `native/ryujin`
to validate the NIF before joining coalition ops.

## Troubleshooting

- **“command not found” for the helper scripts** – make sure you ran `chmod +x install.sh run.sh`.
- **Installer complains about Python** – install `python3` and ensure it’s on PATH.
- **Stale binaries** – remove `vendor/` and re-run `./install.sh` to fetch a fresh toolchain.
- **`database "ryujin_dev" does not exist`** – ensure PostgreSQL is running and rerun `./run.sh`
  (it runs `mix ecto.create` before boot). For custom credentials, adjust `config/dev.exs`.
- **Need Observer** – with the named node and cookie, open a second terminal and run
  `iex --sname observer --cookie ryujin_cookie` followed by `:observer.start()`, then connect to
  `ryujin_dev@127.0.0.1`. Adjust `NODE_NAME`/`ERLANG_COOKIE` env vars in `run.sh` if you prefer
  different identifiers.
- **`inotify-tools` warning** – the dev config auto-switches to a polling watcher when `inotifywait`
  is missing, or install it system-wide (e.g. `sudo apt install inotify-tools`) to restore the
  faster inotify backend.

## Roadmap Notes

- Expand event handlers in `lib/ryujin/consumer.ex` to coordinate with Clairemont and Providentia.
- Integrate Rust-backed analytics (e.g., alliance scoring) through the NIF interface.
- Document shared protocols or vocab the trio should use when negotiating with other guilds.
- Flesh out database schemas and migrations for alliance state.
