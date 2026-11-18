#!/usr/bin/env bash
# Install Nix and the devenv CLI this repository evaluates.
# Idempotent. Pins devenv to the same tag as devenv.yaml (v2.4.0); a nixpkgs
# devenv drifts from those locked modules and fails to evaluate them.
# Binaries are linked into /usr/local/bin so login and non-login shells both
# find them without sourcing a profile.
set -euo pipefail

DEVENV_REF="${DEVENV_REF:-github:cachix/devenv/v2.4.0}"

as_root() {
	if [ "$(id -u)" -eq 0 ]; then
		"$@"
	else
		sudo "$@"
	fi
}

ensure_line() {
	file="$1"
	line="$2"
	if [ -f "$file" ] && grep -qxF "$line" "$file"; then
		return 0
	fi
	printf '%s\n' "$line" >>"$file"
}

if [ ! -d /run/systemd/system ] && [ ! -x /usr/sbin/policy-rc.d ]; then
	as_root tee /usr/sbin/policy-rc.d >/dev/null <<'EOF'
#!/bin/sh
exit 101
EOF
	as_root chmod 755 /usr/sbin/policy-rc.d
fi

# Postgres and Redis serve the ports in server config. Nix supplies the
# Dart/Flutter toolchain through devenv; these packages are only the databases.
if ! command -v psql >/dev/null 2>&1 || ! command -v redis-server >/dev/null 2>&1 || ! command -v xz >/dev/null 2>&1; then
	as_root apt-get update
	as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		git \
		postgresql \
		postgresql-contrib \
		redis-server \
		sudo \
		xz-utils
	as_root rm -rf /var/lib/apt/lists/*
fi

if ! command -v nix >/dev/null 2>&1 && [ ! -x "${HOME}/.nix-profile/bin/nix" ]; then
	conf="$(mktemp)"
	cat >"$conf" <<'EOF'
experimental-features = nix-command flakes
accept-flake-config = true
EOF
	installer="$(mktemp)"
	curl -fsSL https://nixos.org/nix/install -o "$installer"
	sh "$installer" --no-daemon --yes --nix-extra-conf-file "$conf"
	rm -f "$installer" "$conf"
fi

if [ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]; then
	# shellcheck disable=SC1091
	. "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

mkdir -p "${HOME}/.config/nix"
touch "${HOME}/.config/nix/nix.conf"
ensure_line "${HOME}/.config/nix/nix.conf" "experimental-features = nix-command flakes"
ensure_line "${HOME}/.config/nix/nix.conf" "accept-flake-config = true"

as_root mkdir -p /etc/nix
as_root touch /etc/nix/nix.conf
if ! as_root grep -qxF "experimental-features = nix-command flakes" /etc/nix/nix.conf; then
	echo "experimental-features = nix-command flakes" | as_root tee -a /etc/nix/nix.conf >/dev/null
fi
if ! as_root grep -qxF "accept-flake-config = true" /etc/nix/nix.conf; then
	echo "accept-flake-config = true" | as_root tee -a /etc/nix/nix.conf >/dev/null
fi

link_profile_bin() {
	name="$1"
	target="${HOME}/.nix-profile/bin/${name}"
	if [ -x "$target" ]; then
		as_root ln -sfn "$target" "/usr/local/bin/${name}"
	fi
}

link_profile_bin nix
link_profile_bin nix-env
link_profile_bin nix-store
link_profile_bin nix-build
link_profile_bin nix-shell
link_profile_bin nix-instantiate
link_profile_bin nix-channel
link_profile_bin nix-collect-garbage

if ! command -v cachix >/dev/null 2>&1 && [ ! -x "${HOME}/.nix-profile/bin/cachix" ]; then
	nix profile install --accept-flake-config nixpkgs#cachix
fi
link_profile_bin cachix

# Public devenv cache (substituters + signing key) before the devenv closure.
cachix use devenv

if ! command -v devenv >/dev/null 2>&1 && [ ! -x "${HOME}/.nix-profile/bin/devenv" ]; then
	nix profile install --accept-flake-config "$DEVENV_REF"
fi
link_profile_bin devenv
