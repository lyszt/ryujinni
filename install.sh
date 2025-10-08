#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔧 Starting installation for Ryujin..."

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
VENDOR_DIR="$SCRIPT_DIR/vendor/ffmpeg"
BIN_DIR="$VENDOR_DIR/bin"
CACHE_DIR="$VENDOR_DIR/cache"
ARCHIVE_PATH="$CACHE_DIR/ffmpeg.tar.xz"

mkdir -p "$BIN_DIR" "$CACHE_DIR"

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
# 3. (Optional) Build release or assets
# ────────────────────────────────────────────────
# mix assets.deploy
# mix release

cat <<INSTRUCTIONS
ℹ️  Add the following to your shell profile to use the bundled FFmpeg:
    export PATH="$BIN_DIR:\$PATH"

🎉 Installation complete!
INSTRUCTIONS
