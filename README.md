# Ryujin

![Traveler traveling across the fields of a foreign land](https://i.pinimg.com/736x/66/ae/1c/66ae1c45850b48307a8927b25cabd976.jpg)

Ryujin is the diplomatic liaison module for the Clairemont bot. While other modules in the system handle security and administration, Ryujin's focus is on cultivating allied relationships, coordinating joint initiatives, and maintaining calm in inter-guild channels. It is built on Elixir with Nostrum and designed to extend into Rust-backed features for high-performance tasks.

## ◆ Features

- **Alliance-Focused Automation**: Intents are preconfigured for direct message and guild-level relationship management.
- **Voice Capable**: Bundled with FFmpeg, Streamlink, and yt-dlp support for dispatching audio.
- **Rust Accelerated**: Includes a `native/ryujin` crate for Rustler NIFs to handle compute-heavy tasks.
- **Scripted Setup**: Local `install.sh` and `run.sh` scripts manage the toolchain and environment for repeatable setups.

## ◆ Prerequisites

- Elixir ≥ 1.18 (with a matching Erlang/OTP release)
- PostgreSQL (defaults to `postgres`/`postgres` on `localhost`)
- Python 3 (for Streamlink + yt-dlp in a virtualenv)
- `curl` and `tar` (for the FFmpeg download)
- Rust toolchain (if modifying the native extension)

Ensure the helper scripts are executable before starting:

```bash
chmod +x install.sh run.sh
```

## ◆ Configuration

Configuration is loaded from `envs/`. The runtime merges `envs/.env` (shared defaults) and an environment-specific file like `envs/dev.env`.

At minimum, you must define your Discord token in `envs/.env`:

```bash
DISCORD_TOKEN=YOUR_DISCORD_TOKEN
```

The runtime scripts automatically add the local `vendor/bin` and Python virtualenv to your `PATH`.

## ◆ Installation

The installer fetches Mix dependencies and stages the required media binaries locally in the `vendor/` directory:

```bash
./install.sh
```

This script will:

1. Fetch and compile Mix dependencies.
2. Download a static FFmpeg build.
3. Create a Python virtualenv for Streamlink and yt-dlp.

## ◆ Running in Development

Launch the bot for development using the run script:

```bash
./run.sh
```

The script verifies that all tools (`ffmpeg`, `yt-dlp`, etc.) are present, runs database migrations, and starts the Phoenix application via `iex -S mix`.

## ◆ PostgreSQL AGE Integration

The project includes a migration to enable the [Apache AGE extension](https://github.com/apache/age) for graph queries. After installing AGE on your PostgreSQL server, the `run.sh` script or `mix ecto.setup` will enable it in the database.

You can then issue Cypher queries through `Ecto.Repo.query/2`:

```elixir
Repo.query!("""
SELECT *
FROM cypher('ryujin_graph', $$
MATCH (n) RETURN n
$$) AS (node ag_catalog.agtype);
""")
```

## ◆ Native Rust Extension

The `native/ryujin` crate is integrated with [Rustler](https://github.com/rusterlium/rustler). Elixir and Rust code is compiled together with `mix compile`. Add new NIFs in `src/lib.rs` and expose them to Elixir through the `lib/ryujin.ex` module.

## ◆ Troubleshooting

- **"command not found"**: Ensure you ran `chmod +x install.sh run.sh`.
- **Stale binaries**: Remove the `vendor/` directory and re-run `./install.sh`.
- **Database does not exist**: Make sure PostgreSQL is running and re-run `./run.sh`, which executes `mix ecto.create`.
- **Connect Observer**: The bot runs as a named node. Open a new terminal and run:

```elixir
iex --sname observer --cookie ryujin_cookie
:observer.start()
```
