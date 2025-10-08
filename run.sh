#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$PROJECT_DIR/vendor/ffmpeg/bin:$PATH"

mix deps.update --all
mix compile
iex -S mix
