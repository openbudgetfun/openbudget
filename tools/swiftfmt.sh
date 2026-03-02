#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
	exit 0
fi

file_path="$1"

# swiftformat is only available on Darwin in this project setup.
# On other platforms, return the file as-is so dprint remains cross-platform.
if ! command -v swiftformat >/dev/null 2>&1; then
	cat "$file_path"
	exit 0
fi

swiftformat stdin --stdinpath "$file_path" --quiet <"$file_path"
