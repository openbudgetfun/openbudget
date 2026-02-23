#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
	exit 0
fi

# dart format appends a trailing summary line when using -o show.
# dprint exec expects only formatted code on stdout.
dart format -o show "$@" | sed '$d'
