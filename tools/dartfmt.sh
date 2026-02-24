#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
	exit 0
fi

# Prefer the active shell toolchain, but fall back to devenv/fvm where possible.
if command -v dart >/dev/null 2>&1; then
	DART_CMD=(dart)
elif [ -n "${DEVENV_PROFILE:-}" ] && [ -x "${DEVENV_PROFILE}/bin/dart" ]; then
	DART_CMD=("${DEVENV_PROFILE}/bin/dart")
elif command -v fvm >/dev/null 2>&1; then
	DART_CMD=(fvm dart)
else
	echo "error: could not find a dart executable (checked PATH, DEVENV_PROFILE, and fvm)." >&2
	exit 127
fi

# dart format appends a trailing summary line when using -o show.
# dprint exec expects only formatted code on stdout.
"${DART_CMD[@]}" format -o show "$@" | sed '$d'
