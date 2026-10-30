#!/usr/bin/env bash
# Run Hugo — the version scripts/lib.sh pins, from .tools/ — instead of whatever
# `hugo` is on PATH. Use it wherever you would type `hugo`:
#
#   scripts/hugo.sh version
#   scripts/hugo.sh new content <name>.html
#   scripts/hugo.sh --production …   in the production environment, with the
#                                    build's --gc --minify (what make build runs)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO"

bin="$(hugo_bin)"
[ -n "$bin" ] || die "no hugo" "run: make setup"
if [ "${1:-}" = "--production" ]; then production_env; shift; set -- "${BUILD_FLAGS[@]}" "$@"; fi
exec "$bin" "$@"
