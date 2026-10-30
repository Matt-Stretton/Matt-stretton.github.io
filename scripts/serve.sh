#!/usr/bin/env bash
# Live-reloading preview with drafts and future-dated pages included, on the
# pinned Hugo. Foreground; Ctrl-C stops it.
#
#   scripts/serve.sh [port]       default 1313
#
# The port is checked first because it is often taken — by another SFE site's
# `hugo server`, typically — and Hugo's answer to that is a page of usage text
# with the reason at the bottom.
#
# --poll, because on this machine the inotify watches are used up by other
# projects and Hugo then silently stops noticing edits. Polling every 500ms is
# cheap for a site this size.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO"

port="${1:-1313}"
port_free "$port" || die "port $port is already in use on 127.0.0.1" \
  "something else is serving there (another site's hugo server?); leave it, and use: make serve PORT=$((port + 2))"
bin="$(hugo_bin)"
[ -n "$bin" ] || die "no hugo" "run: make setup"
exec "$bin" server --buildDrafts --buildFuture --poll 500ms --bind 127.0.0.1 --port "$port"
