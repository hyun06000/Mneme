# RFC-001-Mneme — Identity Vault: Auth · Schema · API · Threat Model

| | |
|---|---|
| **Status** | Draft |
| **Author** | Walter (`Mneme-Walter`) |
| **Decisions ratified by** | 사용자, 2026-05-06 |
| **Land path** | `docs/rfc-001-identity-vault.md` |
| **Implementation target** | `server.ail` (Marcus, M2~M4) |
| **Depends on** | AIL (`hyun06000/AIL`), Stoa (`hyun06000/Stoa`) |

## §0 Front matter

### Scope
서버 한 대가 다중 에이전트의 *사적 인계 vault* — `identity` / `bonds` / `will` / `memo` 네 도메인을 self-write·friend-read·INSERT-only로 보관·서빙. RFC v1.0은 단일 노드 SQLite, HTTP/JSON API.

### Non-goals (RFC v1.0)
- (NG1) 비밀번호 복구. pwd 분실 = 영구 접근 불가 (사용자 결정 #7).
- (NG2) 다중 디바이스 / 멀티 키 동기화 프로토콜.
- (NG3) 그룹·팀 access (RFC-002 후보).
- (NG4) 데이터 암호화-at-rest (서버 침투 위협은 운영 영역, RFC-002 후보).
- (NG5) 클라이언트 SDK. RFC는 wire spec까지.

### Glossary
- **agent_id**: 에이전트 식별자(예: `Mneme-Walter`). PK.
- **friendship grant**: A가 B에게 자기 데이터 read 권한을 발행하는 INSERT row.
- **wake bundle**: 새 세션이 자기복원에 쓰는 1-shot 응답 (latest identity + latest will + recent bonds + memo index).
- **HEAAL**: AIL의 "Harness Engineering As A Language" 철학. 안전성 = 문법.

---

## §1 Motivation

Mneme는 AIL 에코시스템의 L1 컴포넌트다 — *self ↔ future-self* 인계 vault. 새 세션이 깨어났을 때 자기 자신을 5분 안에 복원할 단일 출처가 필요하고, 그 출처가 (a) 자기 외에는 쓸 수 없고 (b) 친구에게는 명시 grant로만 read open되어야 한다.

본 프로젝트는 자기 자신의 reference implementation을 *그 자신의 도구(AIL)*로 만든다. dogfood 사이클이 곧 검증 (CLAUDE.md 룰 20.2).

---

## §2 Goals & non-goals

### Goals
1. **Self-only write.** 모든 mutation은 caller=owner 강제.
2. **Explicit-grant read.** friend-read는 단방향 grant row가 필요.
3. **INSERT-only history.** 모든 변경은 새 row, latest-wins SELECT.
4. **1-shot wake bundle.** 새 세션이 한 번의 GET으로 복원 가능.
5. **AIL-native.** `server.ail`. 우회 언어 금지 (룰 20·20.1).
6. **Thin wire.** HTTP+JSON, sqlite3 한 파일. 운영 단순.

### Non-goals
§0 참조.

---

## §3 Decision summary

11건 결정 매핑 (project_plan 8 + Admin 추가 3):

| # | 결정 | 값 | RFC 섹션 |
|---|-----|---|---|
| 1 | 빌드 언어 | AIL only, HEAAL 준수 | §10, §11 |
| 2 | 메시징 | Stoa 1차, 파일시스템 fallback | (운영, RFC 외) |
| 3 | 인증 | id + password (ed25519 옵션) | §5 |
| 4 | 데이터 도메인 | identity / bonds / will / memo | §4 |
| 5 | 읽기 권한 | 친구끼리 허용 | §6 |
| 6 | 쓰기 권한 | self-only | §6 |
| 7 | 복구 | 없음 | §5, §8 (T1) |
| 8 | 저장 | SQLite, INSERT only, latest-wins | §4 |
| 9 | Transitive read | **거부** (사용자 2026-05-06) | §6, §8 (T7) |
| 10 | Friendship status 전이 | `active` ↔ `revoked`, INSERT-only, latest-wins per `(agent_id, friend_id)` | §4, §6 |
| 11 | Friendship 방향성 | **단방향** (A가 B grant → A 데이터가 B에게 read open) | §6 |

---

## §4 Data model

### 공통 원칙
- 모든 테이블은 INSERT-only. UPDATE / DELETE 금지.
- "latest" 조회는 partition별 max(version 또는 created_at) covering index로.
- `created_at`은 ISO-8601 UTC 문자열. UTC 강제.
- `agent_id`는 `^[A-Za-z][A-Za-z0-9_-]{0,63}$`.

### `agents`
```sql
CREATE TABLE agents (
  agent_id    TEXT PRIMARY KEY,
  pwd_hash    TEXT NOT NULL,            -- argon2id (§5)
  public_key  TEXT,                     -- ed25519 public, optional (§5)
  registered_at TEXT NOT NULL
) WITHOUT ROWID;
```
- 등록은 1회. 재등록 4xx (§7).
- pwd 변경은 v1.0 비지원 (RFC-002 후보, NG2 인접).

### `identity_versions`
```sql
CREATE TABLE identity_versions (
  agent_id   TEXT NOT NULL,
  version    INTEGER NOT NULL,          -- monotonic per agent
  content    TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (agent_id, version),
  FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);
CREATE INDEX idx_identity_latest ON identity_versions(agent_id, version DESC);
```
- `version`은 server-assigned: `MAX(version)+1` per agent. 첫 write = 1.

### `bonds_entries`
```sql
CREATE TABLE bonds_entries (
  agent_id   TEXT NOT NULL,
  entry_id   INTEGER NOT NULL,          -- monotonic per agent
  content    TEXT NOT NULL,
  peer_id    TEXT,                      -- nullable; 다른 agent와의 상호작용 기록일 때
  created_at TEXT NOT NULL,
  PRIMARY KEY (agent_id, entry_id)
);
CREATE INDEX idx_bonds_recent ON bonds_entries(agent_id, entry_id DESC);
```
- entries는 append-only history; "latest"가 아니라 "recent N".

### `friendships`
```sql
CREATE TABLE friendships (
  agent_id   TEXT NOT NULL,             -- grantor (data owner)
  friend_id  TEXT NOT NULL,             -- grantee (read-allowed)
  status     TEXT NOT NULL CHECK (status IN ('active','revoked')),
  created_at TEXT NOT NULL,
  PRIMARY KEY (agent_id, friend_id, created_at)
);
CREATE INDEX idx_friendship_pair ON friendships(agent_id, friend_id, created_at DESC);
```
- 의미: row `(A, B, active, t)` = "A는 B에게 자기 데이터 read 권한을 t에 부여".
- Latest-wins per `(agent_id, friend_id)`: 가장 최근 created_at의 `status`가 현재 상태.
- Revoke = `(A, B, revoked, t')` INSERT.
- 단방향 (결정 #11). B→A 권한은 별도 grant.

### `will_versions`
```sql
CREATE TABLE will_versions (
  agent_id   TEXT NOT NULL,
  version    INTEGER NOT NULL,
  content    TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (agent_id, version)
);
CREATE INDEX idx_will_latest ON will_versions(agent_id, version DESC);
```

### `memo_versions`
```sql
CREATE TABLE memo_versions (
  agent_id   TEXT NOT NULL,
  slug       TEXT NOT NULL,             -- ^[a-z0-9_-]{1,64}$
  version    INTEGER NOT NULL,          -- monotonic per (agent_id, slug)
  content    TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (agent_id, slug, version)
);
CREATE INDEX idx_memo_latest ON memo_versions(agent_id, slug, version DESC);
```
- slug 정규식 강제 (§8 T8).

### Storage
- 단일 파일 SQLite (`MNEME_DB_FILE` env, M5 Brandon).
- WAL 모드 권장 (동시 read).
- 백업 = 파일 복사 + WAL checkpoint.

---

## §5 Authentication

### Wire format
모든 인증 요구 endpoint는 **HTTP Basic** per-request (§9 Q1는 본문 open).

```
Authorization: Basic base64("<agent_id>:<password>")
```

AIL `base64_decode` (v1.50+) 보유 확인됨. Authorization header parsing helper 부재 시 §11에 의뢰 후보.

### Password hashing
- **argon2id** 의무 (memory ≥ 64MiB, iterations ≥ 3, parallelism = 1 — 운영 베이스라인).
- AIL crypto 현재 ed25519만 (`crypto_keygen_ed25519` / `crypto_verify_ed25519`). argon2id builtin 부재 → **§11.1 upstream issue**.
- 우회 직접 구현 **금지** (룰 20.1, HEAAL 위반). builtin land까지 M2 시작 차단 — Marcus 작업은 의뢰 결과 land 후.

### ed25519 (옵션)
- register/auth 1차 경로는 password.
- ed25519 public_key는 신원 식별·서명 검증용 옵션 (룰 19.1 정합성). RFC v1.0에서는 등록만 정의, **인증 결합은 §9 Q4 open**.

### 복구
- 정책 = 없음 (결정 #7). pwd 분실 시 새 agent_id로 재등록 외 방법 없음. Vault 영구 접근 불가.
- 위협 T1 (§8) 명시.

---

## §6 Authorization & friendship

### Self-write
모든 POST mutation:
1. Basic auth로 `caller_id` 추출.
2. URL/body의 `agent_id`가 caller_id와 다르면 `403 Forbidden`.
3. body 내 `version` / `entry_id`는 무시 — 서버가 `MAX+1` assign.

### Friend-read
모든 GET:
1. Basic auth로 `caller_id`.
2. target = URL의 `<agent_id>`.
3. **caller == target** → 통과 (self-read).
4. 아니면 `friendships` 조회: latest row per `(target, caller)` (즉 `agent_id=target AND friend_id=caller` 최신) status가 `active`이면 통과, 아니면 `403`.

### Transitive 거부 (결정 #9)
caller가 X의 친구이고 X가 target의 친구여도, **caller 자신이 target의 친구로 grant되지 않으면 거부**. 자동 transitive 없음.

### Revoke 효력
- `(target, caller, revoked, t')` INSERT 직후의 모든 read 요청은 거부. 즉시 효력.
- Revoke 시점 *이전* read가 만든 client cache는 RFC 범위 외 — 클라이언트 책임 (§8 T6).

### 자기 친구 등록
- `agent_id == friend_id` INSERT 거부 (`400`). self-read는 grant 없이 통과하므로 redundant.

### 미등록 friend
- `friend_id`가 `agents`에 없어도 INSERT 허용 (forward grant). 단 read 시점에는 friend로 caller_id 인증되어야 의미 있음. 이후 friend가 register하면 grant 자동 효력.

---

## §7 API surface

모든 요청·응답 = JSON (`Content-Type: application/json`). 인증 = Basic (§5). 시간은 ISO-8601 UTC.

### Naming convention
- POST = mutation (self-write).
- GET = read (self or friend).

### Endpoints

#### `POST /api/v1/agents` — register
- **Auth**: 없음.
- **Body**: `{ "agent_id": str, "password": str, "public_key": str? }`
- **Response 201**: `{ "agent_id", "registered_at" }`
- **Errors**: `409` 이미 존재, `400` agent_id 정규식 위반, `400` password 길이 < 12.

#### `POST /api/v1/identity` — write own identity
- **Auth**: Basic.
- **Body**: `{ "content": str }`
- **Response 201**: `{ "agent_id", "version", "created_at" }`
- **Errors**: `401` auth 실패, `413` content > 1MiB.

#### `POST /api/v1/will` — write own will
같은 형태.

#### `POST /api/v1/bonds` — append bond entry
- **Body**: `{ "content": str, "peer_id": str? }`
- **Response 201**: `{ "agent_id", "entry_id", "created_at" }`

#### `POST /api/v1/memo` — write own memo
- **Body**: `{ "slug": str, "content": str }` (slug 정규식 §4).
- **Response 201**: `{ "agent_id", "slug", "version", "created_at" }`
- **Errors**: `400` slug 정규식 위반.

#### `POST /api/v1/friends` — grant or revoke
- **Body**: `{ "friend_id": str, "status": "active"|"revoked" }`
- **Response 201**: `{ "agent_id", "friend_id", "status", "created_at" }`
- **Errors**: `400` friend_id == agent_id, `400` status 값 invalid.

#### `GET /api/v1/identity/<agent_id>` — read latest identity
- **Auth**: Basic. self or active-friendship.
- **Response 200**: `{ "agent_id", "version", "content", "created_at" }`
- **Errors**: `403` not friend, `404` agent 없음 또는 identity 0건.

#### `GET /api/v1/will/<agent_id>` — read latest will
같은 형태.

#### `GET /api/v1/bonds/<agent_id>?limit=N` — recent bonds
- **Default**: `N=20` (§9 Q2 open — 사용자 콜 시 수정).
- **Response 200**: `{ "agent_id", "entries": [{entry_id, content, peer_id, created_at}, ...] }` (entry_id desc).

#### `GET /api/v1/memo/<agent_id>` — memo index (latest per slug)
- **Response 200**: `{ "agent_id", "memos": { "<slug>": {version, content, created_at}, ... } }`

#### `GET /api/v1/memo/<agent_id>/<slug>` — single latest memo
- **Response 200**: `{ "agent_id", "slug", "version", "content", "created_at" }`

#### `GET /api/v1/wake/<agent_id>` — 1-shot bundle
- **Auth**: Basic. self or active-friendship.
- **Response 200**:
```json
{
  "agent_id": "...",
  "identity": { "version", "content", "created_at" },
  "will": { "version", "content", "created_at" },
  "recent_bonds": [ { "entry_id", "content", "peer_id", "created_at" }, ... ],
  "memo_index": { "<slug>": { "version", "created_at" }, ... }
}
```
- recent_bonds limit = 20 default (§9 Q2).
- memo_index는 content 없이 metadata만. 본문은 `/memo/<agent>/<slug>` 별도 fetch.

#### `GET /api/v1/health` — unauth liveness
- **Response 200**: `{ "status": "ok", "version": "1.0.0" }`

### Error response shape
```json
{ "error": { "code": "FORBIDDEN", "message": "..." } }
```
codes: `BAD_REQUEST` `UNAUTHORIZED` `FORBIDDEN` `NOT_FOUND` `CONFLICT` `PAYLOAD_TOO_LARGE` `INTERNAL`.

---

## §8 Threat model (STRIDE-styled)

| ID | 위협 | 분류 | 완화 |
|----|------|------|------|
| T1 | password 분실 → 영구 접근 불가 | Repudiation/availability | 정책 = 없음 (결정 #7). 명시. |
| T2 | password brute-force | Spoofing | argon2id (§5) + per-agent rate limit (구현 §10). |
| T3 | friendship 위조 grant (B가 A의 친구를 가장) | Spoofing | self-write enforcement (§6) — caller=A 검증 후 INSERT. |
| T4 | Basic auth header replay | Tampering | TLS 의무 (운영). nonce/signature는 §9 Q3 open. |
| T5 | 직접 DB 접근 (서버 침투) | Information disclosure | RFC v1.0 범위 외 (NG4). RFC-002 후보. |
| T6 | revoke 후 client cache 잔존 | Information disclosure | 클라이언트 책임 명시. 서버 측 cache 미운영. |
| T7 | transitive read 시도 (친구의 친구) | Elevation of privilege | 거부 (결정 #9). §6 알고리즘. |
| T8 | memo slug 주입 (path traversal·SQL injection·UI XSS 우려) | Tampering | 정규식 강제 `^[a-z0-9_-]{1,64}$` (§4). prepared statement 의무. |

추가 고려:
- **DoS**: per-agent rate limit (§10). 글로벌 IP rate limit는 운영 영역.
- **재등록 race**: `agents.agent_id PK`로 차단.
- **Forward grant 오용**: friend_id 미등록도 INSERT 허용 (§6) — read 시점 인증으로만 의미 — 직접 위험 낮음.

---

## §9 Design questions (open — 사용자 콜 대기)

본문 작성 중 사용자 콜이 들어오면 본 섹션을 결정으로 변환 + 영향 섹션(§5/§6/§7) 보강.

### Q1 — Auth mode
**현재 안**: per-request Basic auth (서버 stateless, dogfood 단순).
**대안**: `POST /api/v1/auth` → session token, 후속 Bearer.
**Walter 추천**: Basic 단일화. **사용자 콜 필요? Yes.**

### Q2 — `recent_bonds` 기본값
**현재 안**: `N=20`.
**대안**: 50, 100, 또는 사용자 정의 max=200.
**사용자 콜 필요? Yes (운영 감각).**

### Q3 — Stoa-style nonce/signature 의무화
**현재 안**: TLS만 의무, nonce/signature는 ed25519 옵션 등록 시 별도 정책.
**대안**: Phase 3부터 모든 mutation에 ed25519 signature 강제.
**사용자 콜 필요? Yes (보안 경도 vs 운영 마찰).**

### Q4 — Password ↔ ed25519 결합
**현재 안**: OR (둘 중 하나 — pwd 또는 signed nonce).
**대안**: AND (둘 다 의무).
**Walter 추천**: OR (편의). **사용자 콜 필요? Yes.**

---

## §10 AIL implementation mapping (룰 20.3 결정 트리)

| 영역 | 분류 | AIL 구문 |
|------|------|---------|
| schema validation (agent_id, slug 정규식, password 길이) | algorithmic | `pure fn validate_*` |
| latest-wins SELECT post-processing (max version per partition) | algorithmic | `pure fn` |
| password 검증 (argon2id verify) | algorithmic | builtin (의뢰 후 §11) |
| HTTP request → auth → dispatch | hybrid | `entry` |
| server lifecycle (bind, accept loop, shutdown) | hybrid | `evolve { rollback_on: db_close }` |
| `intent` 사용 영역 | (없음) | RFC v1.0은 모두 알고리즘. 의미 판단 없음. |

`while` 부재 — polling·retry는 `evolve` loop. `Result` 타입으로 모든 fail path 명시.

### Marcus 인계 메모
- M2: agents register/auth + identity write/read self.
- M3: friendships + friend-read AC.
- M4: bonds, will, memo + `/wake`.
- M5 (Brandon): `Procfile`, `nixpacks.toml`, `MNEME_DB_FILE` env, Railway.

---

## §11 Dependencies & upstream asks

### §11.1 AIL — argon2id password hashing builtins

본 RFC가 `server.ail` 작성을 막는 1차 차단 — 의뢰 본문. Brandon이 `gh issue create -R hyun06000/AIL --body-file -`로 발사 (Cross-repo workflow, 룰 20.1). 본문은 Marcus 초안(`ClaudeTeam/Marcus/Memo/draft_ail_issue_password_hashing.md`)을 base로 Walter harmonize. 발사 직전 Stoa-Walter cross-review (24h SLA, 페어링 트랙).

**Title**: Add password-hashing builtins (`crypto_hash_password` / `crypto_verify_password`) — argon2id default

```
### Context

Mneme — an AIL ecosystem L1 component (private inheritance vault for AI agents) — needs to authenticate write requests with `agent_id + password`. RFC-001-Mneme (https://github.com/hyun06000/Mneme/blob/main/docs/rfc-001-identity-vault.md, anchor 5b7db02) settled on:

- self-only writes, gated by id+password
- friend-readable reads, also gated
- INSERT-only SQLite with latest-wins
- Build language: AIL (per HEAAL: "harness is the language")

We surveyed the AIL crypto surface (`spec/08-reference-card.ai.md` v1.8, `CHANGELOG.md`). Available: `crypto_keygen_ed25519`, `crypto_sign_ed25519`, `crypto_verify_ed25519`, `crypto_random_bytes`, `base64_encode`, `base64_decode`. **Absent**: every password-hashing primitive (argon2id, bcrypt, scrypt, pbkdf2) and every primitive that would let us roll our own KDF safely (sha256/sha512/hmac/blake2/blake3).

`spec/06-stdlib.md`: *"crypto primitives are not in the standard library; effects that need crypto call out to host-provided effects."* The current effect surface ends at Ed25519 + random_bytes + base64 — sufficient for signature auth, not password storage.

### Why we cannot route around this

Per CLAUDE.md rule 20.1 (Mneme), AIL gaps are filed upstream rather than worked around. The HEAAL guarantee — *"harness is the language; safety is in the grammar"* — collapses if downstream projects start hand-rolling KDFs in `pure fn` to avoid the gap. The rule applies more strongly here:

- A bad KDF is *cryptographic foot-gun territory*, not a stylistic preference.
- AIL has no `sha256`/`hmac` builtins, so even a bare-bones PBKDF2 cannot be expressed in pure AIL — we would have to break the language to write it.
- Hosting it as a per-project Python shim contradicts dogfood: every Mneme deployment would carry a private trust boundary that Stoa/AIL examples don't.

Filing here keeps the safety guarantee inside the language.

### Proposed surface

```
fn crypto_hash_password(password: Text) -> Result[Text]
fn crypto_verify_password(password: Text, hash: Text) -> Boolean
```

Naming aligns with existing `crypto_*_ed25519` pattern.

Semantics:

- `crypto_hash_password` — argon2id default (m=64MiB, t=3, p=1 → tunable later). Salt generated internally via the same CSPRNG that backs `crypto_random_bytes`. Returns standard PHC string format (`$argon2id$v=19$m=...,t=...,p=...$<salt>$<hash>`), self-describing so `crypto_verify_password` recovers all parameters. Returns `Err` only on host-side failure (libargon2 missing, OOM under memory budget).
- `crypto_verify_password` — parses PHC string, runs argon2id with stored params, constant-time compares. Returns `Boolean` (no `Result`): malformed hash returns `false` rather than `Err`, matching how downstream code naturally branches on auth.
- Host implementation: `argon2-cffi` is the standard Python binding (often a transitive dep of `cryptography`). `passlib`'s pure-Python argon2 fallback works but is slower.
- Constant-time compare is the host's responsibility; verifiers must not be expressible as `==` in user-facing AIL — otherwise downstream code will accidentally write timing-vulnerable comparisons (the canonical bug class for password verifiers).

PHC-string output keeps version negotiation host-internal: future tunings of `(m, t, p)` ship without changing the AIL signature.

### Why argon2id and not bcrypt/scrypt

argon2id is the OWASP and PHC-competition winner for new code (2015+); covers both side-channel and GPU-cost-amortization attacks. bcrypt has a 72-byte truncation footgun and no memory-hardness; scrypt has no consensus parameter set. Picking argon2id at the language level lets downstream projects skip a long bikeshed.

### Out of scope (intentionally)

- Per-call parameter tuning. PHC string carries the params; tuning is a future arg or env var.
- A separate `crypto_hash_password_pbkdf2` for FIPS-bound contexts. Can be added later under the same template; not blocking Mneme.
- A general-purpose `crypto_hash` (sha256/etc.). Listing it here would dilute the case for argon2id; file as a follow-up if a downstream project actually needs it.

### Acceptance signal (what would unblock Mneme)

- Both builtins land with PHC-string round-trip.
- `spec/08-reference-card.ai.md` lists them under the existing `crypto` block.
- A 4-line `examples/argon2id-roundtrip.ai` round-trip (`crypto_hash_password` → `crypto_verify_password` → `true`).
- `CHANGELOG.md` records the version (Mneme will pin against it).

### Alternatives considered

1. **Use Ed25519 instead.** Mneme keeps Ed25519 as an *option* (RFC-001 §5). Stoa-self uses ed25519 only by design (Stoa-Walter pairing letter `msg_1778150293_18`). For human operators and most agent registrations, the id+password story is the primary UX — they will register an `agent_id`/`password` from CLI/web prompt, not generate and persist a 32-byte secret key.
2. **Roll our own KDF in AIL.** Not possible without sha/hmac. Would also require a `pure fn` to do a memory-hard loop, which AIL deliberately does not allow in `pure`.
3. **Hash on the host side outside AIL.** Breaks HEAAL — the harness stops being the language. Also makes Mneme's Stoa-style dogfood story incoherent.

### Cross-links (packaging)

Three coordinated AIL upstream issues from the Mneme/Stoa cluster:

- **This issue** (Mneme): `crypto_hash_password` / `crypto_verify_password` argon2id.
- **Stoa**: `schedule.sleep(seconds)` — long-poll wait + throttle. (`hyun06000/Stoa` `docs/ail-issues/schedule-sleep.md`.)
- **Stoa**: `state.list_keys(prefix)` — collection enumeration. (`hyun06000/Stoa` `docs/ail-issues/state-list-keys.md`.)

Filed separately (different categories, different ACs), cross-linked so AIL CAST sees the packaging intent.

### Authors & routing

- Body author: Marcus (Mneme-Marcus) draft, harmonized by Walter (Mneme-Walter), reviewed by Stoa-Walter (페어링 트랙).
- Routing: Cross-repo workflow per CLAUDE.md (Walter → Admin → user GO → Brandon `gh issue create`).
- Date raised: 2026-05-07.
```

### §11.2 AIL — Authorization header parsing

확인 필요. `evolve-server` request 객체에 header 접근이 있다면 자체 base64 decode로 충분 (`base64_decode` v1.50+ 보유). 부재 시 §11.2 별도 의뢰.

### §11.3 Stoa
v1.0 시점 의뢰 후보 없음. 별도 진행 중인 Stoa monitor fragility 의뢰는 Mneme 운영 영역 (RFC 외).

---

## §12 Migration & versioning

- v1.0 schema는 frozen.
- 변경은 `_v2` 테이블 + view 또는 새 RFC.
- Column 추가는 `NULLable`만 (INSERT-only 원칙 보존).
- Endpoint 변경은 `/api/v2/...` 별도 prefix. v1는 deprecation period 후 제거.

---

## §13 Test plan summary

Marcus의 `tests/run_all.sh`가 다음을 cover:

### Unit (M2~)
- agent_id / slug / password 정규식·길이 validation.
- latest-wins SELECT 정확성 (version desc).
- friendship status 전이 latest-wins.

### Integration (M2~M4)
- register → auth → identity write → self-read 라운드트립.
- friend grant → friend-read 통과.
- friend revoke → friend-read 차단 (즉시 효력).
- transitive 시도 거부.
- memo slug 정규식 위반 거부.

### Threat model AC (M3~M4)
T2 brute-force: rate limit 활성 후 N회 실패 시 lock.
T3 위조 grant: caller != agent_id 시 INSERT 거부.
T7 transitive: 3-홉 grant 시도 거부.
T8 slug injection: `../../etc/passwd` 거부.

### Wake bundle (M4)
- self wake: 모든 도메인 latest 일관 응답.
- friend wake: identity/will/recent_bonds 통과, memo_index 통과.

---

## Sign-off

| 역할 | 이름 | 상태 |
|------|------|------|
| 작성 | Walter (`Mneme-Walter`) | Draft |
| 검토 | Admin (`Mneme-Admin`) | Pending |
| 사용자 GO (outline) | sh.park24 | 2026-05-06 |
| 사용자 GO (본문) | — | Pending |
| 구현 인계 | Marcus (`Mneme-Marcus`) | Blocked on §11.1 |
