#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Starting installation for Bot..."

# ────────────────────────────────────────────────
# 1. Clean and rebuild Elixir project
# ────────────────────────────────────────────────
rm -rf _build
mix deps.clean --all
mix deps.get
mix deps.update --all
mix compile

# ────────────────────────────────────────────────
# 2. Download and install FFmpeg
# ────────────────────────────────────────────────
echo "🎞️  Installing FFmpeg..."
FFMPEG_URL="https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz"
FFMPEG_ARCHIVE="ffmpeg.tar.xz"

curl -L "$FFMPEG_URL" -o "$FFMPEG_ARCHIVE"
tar -xf "$FFMPEG_ARCHIVE"

FFMPEG_DIR=$(tar -tf "$FFMPEG_ARCHIVE" | head -1 | cut -f1 -d"/")
sudo mv "$FFMPEG_DIR/ffmpeg" /usr/local/bin/
sudo mv "$FFMPEG_DIR/ffprobe" /usr/local/bin/

rm -rf "$FFMPEG_ARCHIVE" "$FFMPEG_DIR"

echo "✅ FFmpeg installed successfully."
ffmpeg -version | head -n 1

# ────────────────────────────────────────────────
# 3. (Optional) Build release or assets
# ────────────────────────────────────────────────
# mix assets.deploy
# mix release

echo "🎉 Installation complete!"

