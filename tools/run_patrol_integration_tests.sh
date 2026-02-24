#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="${ROOT_DIR}/openbudget_app"

cd "$APP_DIR"

shopt -s nullglob
test_glob="${PATROL_TEST_GLOB:-integration_test/*_test.dart}"
# shellcheck disable=SC2206
tests=($test_glob)

if [ "${#tests[@]}" -eq 0 ]; then
	echo "::error::No integration tests were discovered under openbudget_app/integration_test."
	exit 1
fi

timeout_seconds="${PER_FILE_TIMEOUT_SECONDS:-900}"
timeout_cmd=""
if command -v timeout >/dev/null 2>&1; then
	timeout_cmd="timeout"
elif command -v gtimeout >/dev/null 2>&1; then
	timeout_cmd="gtimeout"
fi

echo "Discovered ${#tests[@]} Patrol integration test file(s)."

failed=0
passed_files=0

for f in "${tests[@]}"; do
	echo "::group::Running $f"
	output_file="$(mktemp)"

	if ! grep -Eq "patrolWidgetTest|patrolTest" "$f"; then
		echo "::error::File does not declare Patrol tests: $f"
		failed=1
		rm -f "$output_file"
		echo "::endgroup::"
		continue
	fi

	set +e
	if [ -n "$timeout_cmd" ]; then
		"$timeout_cmd" "${timeout_seconds}s" \
			flutter test "$f" -d flutter-tester 2>&1 | tee "$output_file"
		status=${PIPESTATUS[0]}
	else
		flutter test "$f" -d flutter-tester 2>&1 | tee "$output_file"
		status=${PIPESTATUS[0]}
	fi
	set -e

	if [ "$status" -ne 0 ]; then
		if [ "$status" -eq 124 ]; then
			echo "::error::Integration test timed out after ${timeout_seconds}s: $f"
		fi
		failed=1
	fi

	if grep -Eq "Some tests failed|[0-9]+ failed|No tests ran|No tests were found|Test failed" "$output_file"; then
		echo "::error::Detected integration failure markers in $f output."
		failed=1
	fi

	if grep -Eq "All tests passed!|🎉[[:space:]]+[0-9]+[[:space:]]+tests[[:space:]]+passed\\.|[0-9]+[[:space:]]+tests passed\\." "$output_file"; then
		saw_success_marker=1
		passed_files=$((passed_files + 1))
	else
		saw_success_marker=0
	fi

	if [ "$status" -eq 0 ] && [ "$saw_success_marker" -eq 0 ]; then
		echo "::error::No success marker found in output for $f despite zero exit status."
		failed=1
	fi

	rm -f "$output_file"
	echo "::endgroup::"
done

echo "Patrol integration summary: ${passed_files}/${#tests[@]} files reported successful completion."

if [ "$failed" -ne 0 ]; then
	echo "::error::One or more Patrol integration tests failed."
fi

exit "$failed"
