#!/usr/bin/env bash
# Boot-time services. Postgres and Redis are not left running across a
# snapshot, so this starts them on every agent boot and waits until they
# accept connections. Safe to run again.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/.cursor/dev-passwords.sh"
write_dev_passwords "$ROOT"

PG_BIN="/usr/lib/postgresql/16/bin"
if [ ! -x "$PG_BIN/initdb" ]; then
	echo "PostgreSQL 16 binaries not found at $PG_BIN. Run .cursor/install.sh first." >&2
	exit 1
fi
export PATH="$PG_BIN:$PATH"

STATE="${HOME}/.openbudget"
mkdir -p "$STATE"

start_postgres() {
	name="$1"
	port="$2"
	data="${STATE}/pg-${name}"

	if pg_isready -h 127.0.0.1 -p "$port" -q; then
		echo "postgres already accepting connections on ${port}"
		return 0
	fi

	if [ ! -f "${data}/PG_VERSION" ]; then
		rm -rf "$data"
		mkdir -p "$data"
		pwfile="$(mktemp)"
		printf '%s\n' 'changeme' >"$pwfile"
		initdb \
			-D "$data" \
			--username=postgres \
			--auth-local=trust \
			--auth-host=scram-sha-256 \
			--pwfile="$pwfile" \
			--no-instructions
		rm -f "$pwfile"
		cat >>"${data}/postgresql.conf" <<EOF
listen_addresses = '127.0.0.1'
port = ${port}
unix_socket_directories = '${data}'
EOF
	fi

	if [ -f "${data}/postmaster.pid" ]; then
		pid="$(head -n 1 "${data}/postmaster.pid" || true)"
		if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
			rm -f "${data}/postmaster.pid"
		fi
	fi

	pg_ctl -D "$data" -l "${data}/server.log" -w start
	for _ in $(seq 1 30); do
		if pg_isready -h 127.0.0.1 -p "$port" -q; then
			return 0
		fi
		sleep 1
	done
	echo "postgres on port ${port} did not become ready" >&2
	cat "${data}/server.log" >&2 || true
	exit 1
}

ensure_database() {
	port="$1"
	name="$2"
	exists="$(PGPASSWORD=changeme psql -h 127.0.0.1 -p "$port" -U postgres -d postgres -tAc \
		"SELECT 1 FROM pg_database WHERE datname='${name}'")"
	if [ "$exists" != "1" ]; then
		PGPASSWORD=changeme psql -h 127.0.0.1 -p "$port" -U postgres -d postgres -c \
			"CREATE DATABASE \"${name}\" OWNER postgres"
	fi
}

start_redis() {
	port="$1"
	if redis-cli -p "$port" -a changeme --no-auth-warning ping 2>/dev/null | grep -q PONG; then
		echo "redis already accepting connections on ${port}"
		return 0
	fi
	dir="${STATE}/redis-${port}"
	mkdir -p "$dir"
	if [ -f "${dir}/redis.pid" ]; then
		pid="$(cat "${dir}/redis.pid" || true)"
		if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
			rm -f "${dir}/redis.pid"
		fi
	fi
	redis-server \
		--bind 127.0.0.1 \
		--port "$port" \
		--requirepass changeme \
		--daemonize yes \
		--dir "$dir" \
		--dbfilename dump.rdb \
		--pidfile "${dir}/redis.pid" \
		--logfile "${dir}/redis.log"
	for _ in $(seq 1 30); do
		if redis-cli -p "$port" -a changeme --no-auth-warning ping 2>/dev/null | grep -q PONG; then
			return 0
		fi
		sleep 1
	done
	echo "redis on port ${port} did not become ready" >&2
	cat "${dir}/redis.log" >&2 || true
	exit 1
}

# 9090/9091 match openbudget_server/config/test.yaml and CI.
# 8090/8091 match config/development.yaml and docker-compose.yaml.
start_postgres test 9090
ensure_database 9090 openbudget_test
start_postgres dev 8090
ensure_database 8090 openbudget
ensure_database 8090 openbudget_test
start_redis 9091
start_redis 8091

echo "OpenBudget databases are ready (postgres 9090/8090, redis 9091/8091)."
