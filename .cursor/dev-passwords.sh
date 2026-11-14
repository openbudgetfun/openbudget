#!/usr/bin/env bash
# Local-only Serverpod passwords. Matches the placeholders CI writes and the
# docker-compose defaults. Never overwrite a file the developer already has.
write_dev_passwords() {
	root="$1"
	file="${root}/openbudget_server/config/passwords.yaml"
	if [ -f "$file" ]; then
		return 0
	fi
	mkdir -p "$(dirname "$file")"
	cat >"$file" <<'EOF'
development:
  database: 'changeme'
  redis: 'changeme'
  serviceSecret: 'ci-service-secret'
  emailSecretHashPepper: 'ci-email-pepper'
  jwtHmacSha512PrivateKey: 'ci-jwt-key-must-be-long-enough-32chars'
  jwtRefreshTokenHashPepper: 'ci-jwt-refresh-pepper'
test:
  database: 'changeme'
  redis: 'changeme'
  serviceSecret: 'ci-service-secret'
  emailSecretHashPepper: 'ci-email-pepper'
  jwtHmacSha512PrivateKey: 'ci-jwt-key-must-be-long-enough-32chars'
  jwtRefreshTokenHashPepper: 'ci-jwt-refresh-pepper'
EOF
}
