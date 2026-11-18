#!/usr/bin/env bash
# Repository bootstrap for a Cloud Agent. Installs Nix and devenv, warms the
# evaluated shell, then resolves the Flutter SDK and Dart workspace the same
# way CI does.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash "$ROOT/.cursor/setup-toolchain.sh"

export PATH="/usr/local/bin:${HOME}/.nix-profile/bin:${PATH}"
if [ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]; then
	# shellcheck disable=SC1091
	. "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

# Download the locked closure once. Later `devenv shell` invocations reuse it.
devenv shell -- true

# fvm is provided by the shell. install:all is `flutter pub get`.
devenv shell -- bash -euc "fvm install && fvm use --force && install:all"

# shellcheck disable=SC1091
source "$ROOT/.cursor/dev-passwords.sh"
write_dev_passwords "$ROOT"
