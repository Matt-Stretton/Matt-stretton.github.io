#!/usr/bin/env bash
# Serve exactly what a production build produces (no drafts, no future pages,
# minified, the pinned Hugo) into .test/preview, served as plain files — not
# `hugo server`, which renders differently: the theme switches to an
# unminified, source-mapped stylesheet when it detects the dev server.
# Foreground; Ctrl-C stops it.
#
#   scripts/preview.sh [port]     default 1314 (make serve uses 1313)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO"

port="${1:-1314}"
port_free "$port" || die "port $port is already in use on 127.0.0.1" "use: make preview PORT=$((port + 2))"
bin="$(hugo_bin)"
[ -n "$bin" ] || die "no hugo" "run: make setup"
production_env
rm -rf .test/preview
"$bin" "${BUILD_FLAGS[@]}" --destination .test/preview --quiet
echo "production preview (Hugo $(hugo_version_of "$bin")): http://127.0.0.1:$port/  — Ctrl-C to stop"
exec python3 -m http.server --bind 127.0.0.1 --directory .test/preview "$port"
