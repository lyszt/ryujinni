#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔧 Starting installation for Ryujin..."

VENDOR_ROOT="$SCRIPT_DIR/vendor"
BIN_DIR="$VENDOR_ROOT/bin"
CACHE_DIR="$VENDOR_ROOT/cache"
STREAMLINK_VENV="$VENDOR_ROOT/streamlink-venv"

mkdir -p "$BIN_DIR" "$CACHE_DIR"

# ────────────────────────────────────────────────
# 1. Prepare Elixir project
# ────────────────────────────────────────────────
echo "📦 Syncing Mix dependencies..."
mix deps.get
mix compile

# ────────────────────────────────────────────────
# 2. Download and stage FFmpeg locally
# ────────────────────────────────────────────────
echo "🎞️  Ensuring FFmpeg is available locally..."
FFMPEG_URL="https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz"
ARCHIVE_PATH="$CACHE_DIR/ffmpeg.tar.xz"

if [[ ! -x "$BIN_DIR/ffmpeg" || ! -x "$BIN_DIR/ffprobe" ]]; then
  echo "⬇️  Downloading FFmpeg archive..."
  curl -sSL "$FFMPEG_URL" -o "$ARCHIVE_PATH"

  TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t ffmpeg)"
  tar -xf "$ARCHIVE_PATH" -C "$TMP_DIR" --strip-components=1

  cp "$TMP_DIR/ffmpeg" "$BIN_DIR/"
  cp "$TMP_DIR/ffprobe" "$BIN_DIR/"
  chmod +x "$BIN_DIR/ffmpeg" "$BIN_DIR/ffprobe"

  rm -rf "$TMP_DIR" "$ARCHIVE_PATH"
  echo "✅ FFmpeg binaries staged in $BIN_DIR."
else
  echo "✅ FFmpeg already present at $BIN_DIR; skipping download."
fi

"$BIN_DIR/ffmpeg" -version | head -n 1

# ────────────────────────────────────────────────
# 3. Download youtube-dl
# ────────────────────────────────────────────────
echo "📺  Ensuring youtube-dl is available..."
YTDL_PATH="$BIN_DIR/youtube-dl"
YTDL_URL="https://yt-dl.org/downloads/latest/youtube-dl"

if [[ ! -x "$YTDL_PATH" ]]; then
  curl -sSL "$YTDL_URL" -o "$YTDL_PATH"
  chmod +x "$YTDL_PATH"
  echo "✅ youtube-dl saved to $YTDL_PATH."
else
  echo "✅ youtube-dl already present at $YTDL_PATH; skipping download."
fi

"$YTDL_PATH" --version

# ────────────────────────────────────────────────
# 4. Install Streamlink (Python)
# ────────────────────────────────────────────────
echo "🌊  Ensuring Streamlink virtualenv is ready..."
if ! command -v python3 >/dev/null 2>&1; then
  echo "❌ python3 is required to set up Streamlink. Install python3 and rerun."
  exit 1
fi

if [[ ! -x "$STREAMLINK_VENV/bin/streamlink" ]]; then
  python3 -m venv "$STREAMLINK_VENV"
  "$STREAMLINK_VENV/bin/pip" install --upgrade pip
  "$STREAMLINK_VENV/bin/pip" install --upgrade streamlink
  echo "✅ Streamlink installed in $STREAMLINK_VENV."
else
  echo "✅ Streamlink already present in $STREAMLINK_VENV; upgrading..."
  "$STREAMLINK_VENV/bin/pip" install --upgrade streamlink >/dev/null
fi

"$STREAMLINK_VENV/bin/streamlink" --version | head -n 1

# ────────────────────────────────────────────────
# 5. (Optional) Build release or assets
# ────────────────────────────────────────────────
# mix assets.deploy
# mix release

cat <<INSTRUCTIONS
ℹ️  Add the following to your shell profile to use the bundled tooling:
    export PATH="$BIN_DIR:$STREAMLINK_VENV/bin:\$PATH"

🎉 Installation complete!
INSTRUCTIONS
