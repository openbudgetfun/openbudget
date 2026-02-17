#!/usr/bin/env bash
# Wrapper for dprint exec plugin: formats a dart file and strips the summary line.
set -e
dart format -o show "$@" | head -n -1
