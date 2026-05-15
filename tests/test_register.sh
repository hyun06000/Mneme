#!/usr/bin/env bash
# Mneme test — POST /api/v1/agents (RFC-001 §5/§7 register)
#
# Phase B Step 1 AC. Covers:
#   1. 201 happy path → {agent_id, registered_at}.
#   2. 409 duplicate agent_id.
#   3. 400 agent_id regex violation (leading digit).
#   4. 400 password length < 12.
#   5. 400 missing field.
#   6. 400 invalid JSON.
#   7. public_key optional 정상 통과.

set -euo pipefail

URL="${MNEME_URL:?MNEME_URL not set}"

post() {
    # $1 path, $2 body
    curl -fsS -o /tmp/mneme_resp.$$ -w '%{http_code}' \
        -X POST -H 'Content-Type: application/json' \
        -d "$2" "$URL$1" || true
}

post_nofail() {
    # Tolerate non-2xx (for negative cases).
    curl -sS -o /tmp/mneme_resp.$$ -w '%{http_code}' \
        -X POST -H 'Content-Type: application/json' \
        -d "$2" "$URL$1"
}

# --- 1. happy path -----------------------------------------------------------
code=$(post_nofail /api/v1/agents '{"agent_id":"alice","password":"hunter2hunter2"}')
body=$(cat /tmp/mneme_resp.$$)
if [[ "$code" != "201" ]]; then
    echo "    happy path expected 201, got $code: $body"
    exit 1
fi
if ! grep -qE '"agent_id":\s*"alice"' <<<"$body"; then
    echo "    expected agent_id=alice in body, got: $body"
    exit 1
fi
if ! grep -q '"registered_at"' <<<"$body"; then
    echo "    expected registered_at field, got: $body"
    exit 1
fi

# --- 2. duplicate ------------------------------------------------------------
code=$(post_nofail /api/v1/agents '{"agent_id":"alice","password":"hunter2hunter2"}')
body=$(cat /tmp/mneme_resp.$$)
if [[ "$code" != "409" ]]; then
    echo "    duplicate expected 409, got $code: $body"
    exit 1
fi
if ! grep -q 'AGENT_EXISTS' <<<"$body"; then
    echo "    expected AGENT_EXISTS code, got: $body"
    exit 1
fi

# --- 3. agent_id regex (leading digit) ---------------------------------------
code=$(post_nofail /api/v1/agents '{"agent_id":"1bob","password":"hunter2hunter2"}')
body=$(cat /tmp/mneme_resp.$$)
if [[ "$code" != "400" ]]; then
    echo "    bad agent_id expected 400, got $code: $body"
    exit 1
fi
if ! grep -q 'INVALID_AGENT_ID' <<<"$body"; then
    echo "    expected INVALID_AGENT_ID, got: $body"
    exit 1
fi

# --- 4. password too short ---------------------------------------------------
code=$(post_nofail /api/v1/agents '{"agent_id":"carol","password":"short"}')
body=$(cat /tmp/mneme_resp.$$)
if [[ "$code" != "400" ]]; then
    echo "    short pwd expected 400, got $code: $body"
    exit 1
fi
if ! grep -q 'INVALID_PASSWORD' <<<"$body"; then
    echo "    expected INVALID_PASSWORD, got: $body"
    exit 1
fi

# --- 5. missing field --------------------------------------------------------
code=$(post_nofail /api/v1/agents '{"agent_id":"dave"}')
body=$(cat /tmp/mneme_resp.$$)
if [[ "$code" != "400" ]]; then
    echo "    missing pwd expected 400, got $code: $body"
    exit 1
fi
if ! grep -q 'INVALID_BODY' <<<"$body"; then
    echo "    expected INVALID_BODY, got: $body"
    exit 1
fi

# --- 6. invalid JSON ---------------------------------------------------------
code=$(post_nofail /api/v1/agents 'not json')
body=$(cat /tmp/mneme_resp.$$)
if [[ "$code" != "400" ]]; then
    echo "    bad json expected 400, got $code: $body"
    exit 1
fi
if ! grep -q 'INVALID_BODY' <<<"$body"; then
    echo "    expected INVALID_BODY, got: $body"
    exit 1
fi

# --- 7. with optional public_key --------------------------------------------
code=$(post_nofail /api/v1/agents '{"agent_id":"eve","password":"hunter2hunter2","public_key":"deadbeef00000000000000000000000000000000000000000000000000000000"}')
body=$(cat /tmp/mneme_resp.$$)
if [[ "$code" != "201" ]]; then
    echo "    pubkey path expected 201, got $code: $body"
    exit 1
fi
if ! grep -qE '"agent_id":\s*"eve"' <<<"$body"; then
    echo "    expected agent_id=eve, got: $body"
    exit 1
fi

rm -f /tmp/mneme_resp.$$
