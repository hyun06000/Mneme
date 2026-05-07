#!/usr/bin/env bash
# Mneme test — /api/v1/health (Phase A AC)
#
# Minimal liveness check. RFC-001 §7 GET /api/v1/health → 200 with
# {"status":"ok","version":"..."}.

set -euo pipefail

URL="${MNEME_URL:?MNEME_URL not set}"

resp="$(curl -fs "$URL/api/v1/health")"

# Sanity — body contains "status" and "ok".
if ! grep -q '"status"' <<<"$resp"; then
    echo "    expected status field, got: $resp"
    exit 1
fi
if ! grep -q '"ok"' <<<"$resp"; then
    echo "    expected status=ok, got: $resp"
    exit 1
fi
if ! grep -q '"version"' <<<"$resp"; then
    echo "    expected version field, got: $resp"
    exit 1
fi
