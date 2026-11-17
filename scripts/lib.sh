# Shared by scripts/*.sh. Source it; do not run it.
#
# One job above all: decide WHICH hugo every command uses, so that `make build`,
# `make test` and `make serve` all build with one known version and not
# whatever happens to be on PATH.

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The Hugo this site is built with, extended edition. The one place the
# version is written down: the Pages workflow (.github/workflows/pages.yml)
# installs Hugo through `make setup` rather than naming a version of its own. 0.168.0 is the newest release and builds the theme; the
# old GitHub Pages workflow used 0.162.1, which gives the same deprecation
# warnings (see CLAUDE.md), so there was nothing to gain by going back.
HUGO_PIN="0.168.0"

die()  { printf '\033[31m✗\033[0m %s\n' "$1" >&2; shift; for l in "$@"; do printf '  \033[2m%s\033[0m\n' "$l" >&2; done; exit 1; }
say()  { printf '\033[2m%s\033[0m\n' "$*" >&2; }

pinned_version() { printf '%s' "$HUGO_PIN"; }

# Where `make setup` puts the pinned hugo. Inside the checkout, gitignored, and
# per-version, so a pin change never runs a stale binary. Nothing is installed
# system-wide.
pinned_bin() { printf '%s/.tools/hugo-%s/hugo' "$REPO" "$(pinned_version)"; }

# The hugo every script uses: $HUGO if you set it, else the pinned download,
# else whatever is on PATH (which `make check` will tell you is wrong).
hugo_bin() {
  if [ -n "${HUGO:-}" ]; then printf '%s' "$HUGO"
  elif [ -x "$(pinned_bin)" ]; then pinned_bin
  else command -v hugo 2>/dev/null || true
  fi
}

# "0.168.0" from "hugo v0.168.0-e27a676…+extended linux/amd64 …"
hugo_version_of() { "$1" version 2>/dev/null | sed -nE 's/^hugo v([0-9]+\.[0-9]+\.[0-9]+).*/\1/p'; }
hugo_is_extended() { "$1" version 2>/dev/null | grep -q '+extended'; }

# The build flags the old GitHub Pages workflow used (`hugo --gc --minify`),
# minus its --baseURL, which comes from the Pages deployment: the Pages
# workflow adds it to the same flags. make build and make test share them so
# that what is tested is what is shipped.
BUILD_FLAGS=(--gc --minify)
production_env() { export HUGO_ENVIRONMENT=production; }

# True if nothing is listening on 127.0.0.1:$1. bash's /dev/tcp, so it needs no nc.
port_free() { ! (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }
