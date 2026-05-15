#!/usr/bin/env bash
# Mneme tests — Phase A
#
# Pattern: Stoa tests/run_all.sh dogfood. Spin up server in tmpdir with
# isolated MNEME_DB_FILE, poll /health until ready, dispatch test_*.sh,
# aggregate pass/fail. trap kills server on exit.
#
# Phase A scope: /health only. Auth-bearing tests land alongside their
# endpoints (Phase B/C, after AIL #8 argon2id lands).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TMP="$(mktemp -d -t mneme-tests.XXXXXX)"
PORT="${MNEME_PORT:-8091}"
URL="http://127.0.0.1:${PORT}"

cleanup() {
    if [[ -n "${SERVER_PID:-}" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
        kill "$SERVER_PID" 2>/dev/null || true
        wait "$SERVER_PID" 2>/dev/null || true
    fi
    rm -rf "$TMP"
}
trap cleanup EXIT

echo "→ tmpdir: $TMP"
echo "→ port: $PORT"

PYTHONUNBUFFERED=1 \
PORT="$PORT" \
MNEME_DB_FILE="$TMP/mneme.db" \
AIL_STATE_DIR="$TMP/state" \
    ail run "$ROOT_DIR/server.ail" > "$TMP/server.log" 2>&1 &
SERVER_PID=$!

# Health probe: 30 × 0.5s = 15s ceiling.
ready=0
for i in $(seq 1 30); do
    if curl -fs "$URL/api/v1/health" >/dev/null 2>&1; then
        ready=1
        break
    fi
    sleep 0.5
done

if [[ "$ready" != "1" ]]; then
    echo "✗ server failed to come up in 15s"
    echo "--- server.log ---"
    cat "$TMP/server.log" || true
    exit 1
fi

echo "→ server ready"

PASS=0
FAIL=0
FAILED_TESTS=()

shopt -s nullglob
for test_script in "$SCRIPT_DIR"/test_*.sh; do
    name="$(basename "$test_script")"
    echo "→ running $name"
    if MNEME_URL="$URL" bash "$test_script"; then
        PASS=$((PASS + 1))
        echo "  ✓ $name"
    else
        FAIL=$((FAIL + 1))
        FAILED_TESTS+=("$name")
        echo "  ✗ $name"
    fi
done

echo
echo "===================="
echo "pass=$PASS fail=$FAIL"
if (( FAIL > 0 )); then
    echo "failed: ${FAILED_TESTS[*]}"
fi

exit $(( FAIL == 0 ? 0 : 1 ))
