# matt-stretton.github.io — a Hugo site, copied from necksurgery.co.nz to become
# Matt Stretton's. Not yet his, and not deployed anywhere: see CLAUDE.md.
#
# New checkout? One command (your machine needs git, make, curl, tar, sha256sum
# and python3; Hugo itself is downloaded at the pinned version):
#
#   make setup      get the Hugo scripts/lib.sh pins into .tools/ and check
#                   that make will use it
#
# Then day to day:
#
#   make serve      live-reloading preview with drafts, http://127.0.0.1:1313/
#   make preview    the production build exactly, http://127.0.0.1:1314/
#                   (PORT=… moves either one)
#   make test       production build + site checks
#   make build      production build into public/
#   make status     what is set up and what is running
#
# Everything runs on this machine: no container, no database. Every target uses
# the Hugo version pinned in scripts/lib.sh, never the one on your PATH — use
# scripts/hugo.sh, not bare `hugo`, for anything else.

SHELL        := /bin/bash
PORT         ?= 1313
PREVIEW_PORT ?= 1314

.DEFAULT_GOAL := help
.PHONY: setup check serve preview build test test-strict status help

# ── setup ───────────────────────────────────────────────────────────────────

setup: ## Set this checkout up (idempotent — safe to re-run)
	@scripts/setup.sh

check: ## Check setup and the Hugo version make uses, change nothing
	@scripts/setup.sh --check

# ── day to day ──────────────────────────────────────────────────────────────

serve: ## Live-reloading preview, drafts and future pages included (polls)
	@scripts/serve.sh $(PORT)

preview: ## Serve the production build exactly (no drafts), as plain files
	@scripts/preview.sh $(if $(filter command line,$(origin PORT)),$(PORT),$(PREVIEW_PORT))

build: ## Production build into public/ (--gc --minify, as the old deploy did)
	@scripts/hugo.sh --production --cleanDestinationDir

test: ## Production build + site checks, excusing scripts/known-defects.txt
	@scripts/test.sh

test-strict: ## The same with no baseline: every known defect fails
	@scripts/test.sh --strict

status: ## What is set up and what is running
	@. scripts/lib.sh; pin="$$(pinned_version)"; bin="$$(hugo_bin)"; \
	printf '  hugo pin      Hugo %s (scripts/lib.sh)\n' "$$pin"; \
	printf '  make uses     '; if [ -n "$$bin" ]; then v="$$(hugo_version_of "$$bin")"; \
		if [ "$$v" = "$$pin" ]; then echo "Hugo $$v  ($$bin)"; else echo "Hugo $$v  ($$bin)  MISMATCH → make setup"; fi; \
		else echo 'no hugo      → make setup'; fi; \
	printf '  serve         '; ! port_free $(PORT) && echo "something is listening on :$(PORT)" || echo "not running  → make serve"; \
	printf '  preview       '; ! port_free $(PREVIEW_PORT) && echo "something is listening on :$(PREVIEW_PORT)" || echo "not running  → make preview"; \
	printf '  git           '; git remote | grep -q . && echo "remote: $$(git remote | paste -sd' ')" || echo 'no remote yet (see CLAUDE.md, Not done yet)'

# ── help ────────────────────────────────────────────────────────────────────

help: ## List these targets
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN{FS=":.*?## "}{printf "  make %-13s %s\n", $$1, $$2}'
