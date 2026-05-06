# Stoa Survey — server.ail skeleton (모델링 reference)

조사일: 2026-05-06. 출처: https://github.com/hyun06000/Stoa.

## 파일 레이아웃
- `server.ail` (~2300+ lines) — main HTTP server. Mneme도 동일 단일파일 패턴 가능.
- `client.ail` — test agent client.
- `Procfile`: 단 한 줄 `ail run server.ail`.
- `nixpacks.toml`: `pip install -r requirements.txt` (AIL은 Python-hosted) → `ail run server.ail`.
- `tests/run_all.sh` + `tests/test_*.sh` — shell+curl 인수 테스트.
- `tools/validate-mr.sh` — MR pre-check.

## server.ail 구조

### Route dispatch (`route()` ~line 2300+)
선형 if/else on `req.method` + `req.path`. prefix는 `starts_with()`, path 파라미터는 `slice()`:
```
if method == "GET" and path == "/" { return handle_ui(req) }
if method == "POST" and path == "/api/v1/messages" { return handle_post_message(req) }
if method == "GET" and starts_with(path, "/api/v1/messages/") {
    msg_id = slice(path, 17, length(path))
    return handle_get_message(req, msg_id)
}
```

### JSON parsing
`parse_json(req.body)` → `Result<Text, Any>`. `is_error()` / `unwrap()` 게이트.

### Response 모양
핸들러는 3-tuple `[status, content_type, body]` 반환. evolve가 `perform http.respond(get(r,0), get(r,1), get(r,2))`. 헬퍼:
```
fn json_ok(status: Number, body: Text) -> [Any] { return [status, "application/json", body] }
fn err_json(status: Number, message: Text) -> [Any] {
    body = join(["{\"error\":\"", message, "\"}"], "")
    return [status, "application/json", body]
}
```

### pure fn vs fn vs intent
- pure: `_check_str`, `_esc`, `canonical_letter`, `_sort_recipients_by_name`.
- effectful fn: `perform db.execute / db.query / clock.now / env.read / http.post_json`.
- `_get_window_seconds`: `r = perform env.read("STOA_CREATED_AT_WINDOW_SECONDS")`.

### Top-level evolve
```
evolve stoa {
    listen: 8090
    effects: [http.respond, http.post_json, db.execute, db.query,
              clock.now, state.read, state.write, env.read]
    metric: error_rate
    when request_received(req) { ... }
    rollback_on: error_rate > 0.9
    history: keep_last 100
}
```
→ Mneme도 동일 골격: listen, effects(http+db+clock+env), rollback_on, history.

## SQLite INSERT-only

### Schema 예 (server.ail L45–77)
```
CREATE TABLE IF NOT EXISTS letters (id TEXT PRIMARY KEY, from_name TEXT NOT NULL,
  from_address TEXT NOT NULL, content TEXT NOT NULL, created_at TEXT NOT NULL)
CREATE TABLE IF NOT EXISTS recipients (letter_id TEXT NOT NULL, name TEXT NOT NULL,
  address TEXT NOT NULL, PRIMARY KEY (letter_id, name))
CREATE TABLE IF NOT EXISTS registry (name TEXT NOT NULL, address TEXT NOT NULL,
  registered_at TEXT NOT NULL)
```

### Writes — INSERT only (UPDATE/DELETE 부재 확인)
- L10-12 주석: `3) 쌓이기만 — INSERT만. DELETE/UPDATE 코드에 없음`.
- L403 주석: `INSERT only — code path has no UPDATE / no DELETE`.
- L415: `INSERT INTO letters (...) VALUES (?,?,?,?,?,?,?)`.
- L423: `INSERT INTO recipients (letter_id, name, address) VALUES (?,?,?)`.

### Latest-wins read 패턴
- Single lookup (L479): `SELECT ... FROM registry WHERE name = ? ORDER BY rowid DESC LIMIT 1`.
- Bulk latest-per-key (L504):
  ```
  SELECT r.name, r.address, r.public_key, r.registered_at
  FROM registry r
  INNER JOIN (SELECT name, MAX(rowid) AS m FROM registry GROUP BY name) t
    ON r.rowid = t.m
  ORDER BY r.name
  ```
- 동일 패턴 L548/L560/L609 (aliases / platform_keys / sessions).

### Builtin
- write: `perform db.execute(db, sql, [params])`.
- read: `perform db.query(db, sql, [params])`.

## tests/run_all.sh 구조
```
PYTHONUNBUFFERED=1 PORT="$PORT" STOA_DB_FILE="$TMP/messages.db" \
    ail run server.ail > "$TMP/server.log" 2>&1 &
# 30 × 0.5s health 폴링:
curl -fs "$URL/api/v1/health" >/dev/null 2>&1
# dispatch:
STOA_URL="$URL" bash test_*.sh
# summary + trap kill server PID
```
→ Mneme `tests/run_all.sh` 동일 골격: tmpdir DB, ail run server.ail 백그라운드, /health 폴링, test_*.sh 일괄, exit code aggregate.

## AGENTS.md — Auth Phases
- Phase 0: 검증 없음. 모든 letter 통과 (부트스트랩).
- Phase 1: signing 주장 시 강제, 아니면 optional.
- Phase 2: 등록된 키 → 강제. 미등록 → grandfather pass.
- Phase 3: 항상 필수. `public_key` 미등록 reject.
- ed25519 flow: keypair 생성 → `POST /api/v1/enter`로 `public_key` (hex) 등록 → letter canonical form (`canonical_letter()`) 서명 → 서버는 registry latest-rowid public_key로 verify.

## Mneme에 적용

| Stoa 패턴 | Mneme 적용 |
|---|---|
| evolve listen+effects+rollback_on | server.ail top-level 동일 |
| linear route dispatch (if/else, starts_with, slice) | `/api/v1/identity`, `/bonds`, `/will`, `/memo`, `/friends`, `/wake/<id>` 동일 |
| 3-tuple response + evolve perform | `json_ok` / `err_json` 헬퍼 동일 |
| INSERT only + ORDER BY rowid DESC LIMIT 1 | identity_versions / will_versions / memo_versions 동일. version 컬럼 굳이 안 써도 rowid로 충분. |
| INNER JOIN MAX(rowid) bulk | friendships latest-status per (agent_id, friend_id) — 동일 |
| canonical_letter + ed25519 verify | optional public_key 인증 (project_plan #3). password auth는 별도 |
| run_all.sh tmpdir + curl /health 폴링 | tests/run_all.sh AC 동일 골격 |
