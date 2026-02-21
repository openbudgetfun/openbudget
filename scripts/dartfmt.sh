#!/usr/bin/env bash
# Wrapper for dprint exec plugin: formats a dart file and strips the summary line.
set -euo pipefail

tmp_file="$(mktemp -t dprint-dartfmt.XXXXXX.dart)"
trap 'rm -f "$tmp_file"' EXIT

# dprint exec sends file contents on stdin, so consume stdin first.
cat >"$tmp_file"
dart format -o show "$tmp_file" | sed '$d'
