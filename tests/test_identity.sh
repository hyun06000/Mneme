#!/usr/bin/env bash
# Mneme test — POST /api/v1/identity + GET /api/v1/identity/<agent_id>
# (RFC-001 §6 self-write / §7 / Phase B Step 2 AC).
#
# Self-path priority. friend-read 자리는 후속 trip 자기.
#
# Covers:
#   1. register prep agent (ada / hunter2hunter2).
#   2. POST identity (Basic auth ada) → 201 {version:1, agent_id, created_at}.
#   3. GET identity/ada (Basic auth ada) → 200, content == sent.
#   4. POST again → 201 {version:2}.
#   5. GET → version:2 (latest-wins).
#   6. POST without auth → 401.
#   7. POST with wrong password → 401.
#   8. POST with unknown agent_id → 401 (timing-uniform).
#   9. POST with content > 1MiB → 413.
#  10. POST with missing content field → 400.
#  11. GET self before any POST (new agent) → 404.
#  12. GET other agent (caller != target) → 403.

set -euo pipefail

URL="${MNEME_URL:?MNEME_URL not set}"

# Helper: base64 (no newline) for Basic auth.
b64() { printf '%s' "$1" | base64 | tr -d '\n'; }
auth_hdr() { echo "Authorization: Basic $(b64 "$1:$2")"; }

# Helper: post identity, capture http code and body to vars.
post_identity() {
    # $1: auth header value (or '-' for none), $2: JSON body
    local hdr="$1" body="$2"
    if [[ "$hdr" == "-" ]]; then
        curl -sS -o /tmp/mneme_id.$$ -w '%{http_code}' \
            -X POST -H 'Content-Type: application/json' \
            -d "$body" "$URL/api/v1/identity"
    else
        curl -sS -o /tmp/mneme_id.$$ -w '%{http_code}' \
            -X POST -H "$hdr" -H 'Content-Type: application/json' \
            -d "$body" "$URL/api/v1/identity"
    fi
}

get_identity() {
    # $1: auth header value, $2: agent_id path segment
    curl -sS -o /tmp/mneme_id.$$ -w '%{http_code}' \
        -X GET -H "$1" "$URL/api/v1/identity/$2"
}

# --- 1. register ada prep --------------------------------------------------
code=$(curl -sS -o /tmp/mneme_id.$$ -w '%{http_code}' \
    -X POST -H 'Content-Type: application/json' \
    -d '{"agent_id":"ada","password":"hunter2hunter2"}' "$URL/api/v1/agents")
if [[ "$code" != "201" ]]; then
    echo "    register ada expected 201, got $code: $(cat /tmp/mneme_id.$$)"
    exit 1
fi
AUTH_ADA="$(auth_hdr ada hunter2hunter2)"

# --- 2. POST identity v1 -----------------------------------------------------
code=$(post_identity "$AUTH_ADA" '{"content":"hello from ada"}')
body=$(cat /tmp/mneme_id.$$)
if [[ "$code" != "201" ]]; then
    echo "    identity v1 expected 201, got $code: $body"; exit 1
fi
if ! grep -qE '"agent_id":\s*"ada"' <<<"$body"; then
    echo "    expected agent_id=ada, got: $body"; exit 1
fi
if ! grep -qE '"version":\s*1\b' <<<"$body"; then
    echo "    expected version=1, got: $body"; exit 1
fi

# --- 3. GET self -------------------------------------------------------------
code=$(get_identity "$AUTH_ADA" ada)
body=$(cat /tmp/mneme_id.$$)
if [[ "$code" != "200" ]]; then
    echo "    GET self expected 200, got $code: $body"; exit 1
fi
if ! grep -qE '"content":\s*"hello from ada"' <<<"$body"; then
    echo "    expected content roundtrip, got: $body"; exit 1
fi
if ! grep -qE '"version":\s*1\b' <<<"$body"; then
    echo "    expected version=1, got: $body"; exit 1
fi

# --- 4. POST identity v2 -----------------------------------------------------
code=$(post_identity "$AUTH_ADA" '{"content":"updated"}')
body=$(cat /tmp/mneme_id.$$)
if [[ "$code" != "201" ]]; then
    echo "    identity v2 expected 201, got $code: $body"; exit 1
fi
if ! grep -qE '"version":\s*2\b' <<<"$body"; then
    echo "    expected version=2, got: $body"; exit 1
fi

# --- 5. GET → version=2 latest ----------------------------------------------
code=$(get_identity "$AUTH_ADA" ada)
body=$(cat /tmp/mneme_id.$$)
if ! grep -qE '"version":\s*2\b' <<<"$body"; then
    echo "    GET latest expected v2, got: $body"; exit 1
fi
if ! grep -qE '"content":\s*"updated"' <<<"$body"; then
    echo "    expected content=updated, got: $body"; exit 1
fi

# --- 6. POST without auth → 401 ---------------------------------------------
code=$(post_identity - '{"content":"x"}')
body=$(cat /tmp/mneme_id.$$)
if [[ "$code" != "401" ]]; then
    echo "    no-auth expected 401, got $code: $body"; exit 1
fi

# --- 7. POST wrong password → 401 -------------------------------------------
WRONG_AUTH="$(auth_hdr ada wrongwrongwrong)"
code=$(post_identity "$WRONG_AUTH" '{"content":"x"}')
body=$(cat /tmp/mneme_id.$$)
if [[ "$code" != "401" ]]; then
    echo "    wrong pwd expected 401, got $code: $body"; exit 1
fi

# --- 8. POST unknown agent → 401 --------------------------------------------
UNKNOWN_AUTH="$(auth_hdr ghost ghostpass1234)"
code=$(post_identity "$UNKNOWN_AUTH" '{"content":"x"}')
body=$(cat /tmp/mneme_id.$$)
if [[ "$code" != "401" ]]; then
    echo "    unknown agent expected 401, got $code: $body"; exit 1
fi

# --- 9. POST content > 1MiB → 413 -------------------------------------------
# Generate body via temp file (shell ARG_MAX 회피).
BIG_FILE="$(mktemp)"
python3 -c "import json; open('$BIG_FILE','w').write(json.dumps({'content':'x'*(1048576+10)}))"
code=$(curl -sS -o /tmp/mneme_id.$$ -w '%{http_code}' \
    -X POST -H "$AUTH_ADA" -H 'Content-Type: application/json' \
    --data-binary "@$BIG_FILE" "$URL/api/v1/identity")
rm -f "$BIG_FILE"
body=$(cat /tmp/mneme_id.$$)
if [[ "$code" != "413" ]]; then
    echo "    big content expected 413, got $code: $(head -c 200 <<<"$body")"; exit 1
fi

# --- 10. missing content field → 400 ---------------------------------------
code=$(post_identity "$AUTH_ADA" '{}')
body=$(cat /tmp/mneme_id.$$)
if [[ "$code" != "400" ]]; then
    echo "    missing content expected 400, got $code: $body"; exit 1
fi

# --- 11. GET self before any POST → 404 -----------------------------------
code=$(curl -sS -o /tmp/mneme_id.$$ -w '%{http_code}' \
    -X POST -H 'Content-Type: application/json' \
    -d '{"agent_id":"bart","password":"hunter2hunter2"}' "$URL/api/v1/agents")
if [[ "$code" != "201" ]]; then
    echo "    register bart expected 201, got $code: $(cat /tmp/mneme_id.$$)"; exit 1
fi
AUTH_BART="$(auth_hdr bart hunter2hunter2)"
# Cross-agent GET: bart → ada (after ada has rows from prior steps).
code=$(get_identity "$AUTH_BART" bart)
body=$(cat /tmp/mneme_id.$$)
if [[ "$code" != "404" ]]; then
    echo "    fresh agent GET expected 404, got $code: $body"; exit 1
fi

# --- 12. GET other agent (caller != target) → 403 -------------------------
code=$(get_identity "$AUTH_BART" ada)
body=$(cat /tmp/mneme_id.$$)
if [[ "$code" != "403" ]]; then
    echo "    cross-agent GET expected 403, got $code: $body"; exit 1
fi

rm -f /tmp/mneme_id.$$
