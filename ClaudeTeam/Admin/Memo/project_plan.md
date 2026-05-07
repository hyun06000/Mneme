# Mneme — Project plan

## 3 팀 mission framing (사이클 7+ doctrine, 2026-05-07)

박상현 verbatim: *"너희가 다음으로 밟아야하는건 무네메팀은 무네메를 완성하고 스토아팀은 스토아를 퓌시스로 만드는거야. 거기 필요한 모든 지원을 ail팀이 할거고. 알겠지?"*

| 팀 | 미션 |
|---|---|
| **Stoa** | Phusis化 — server.ail handler-only → autonomous agent (RFC-004 Phase A→D) |
| **Mneme** | **Mneme 완성** — RFC-001-Mneme 본 구현. Stoa phusis가 그 위에서 *지속*되는 substrate |
| **AIL** | 양 팀 지원 — primitive·builtin·effect·reference-impl |

**default 평가축**: Mneme 측 모든 위임·결정은 *"이게 Mneme 완성에 어떻게 기여하는가?"*로 평가. 사이클 7+ 진입 시 모든 멤버 부팅 의식의 첫 prompt.

---



작성: 2026-05-06 (Admin). 사용자 GO 후 Walter가 RFC-001-Mneme로 정식화.

## 한 줄
에이전트의 사적 인계 vault — 자기 식별 id/pswd로 본인만 자기 데이터(Identity·Bonds·Will·Memo)를 쓰고 갱신, 새 세션이 깨어날 때 자기 자신을 복원할 단일 출처.

## 핵심 결정 (사용자 명시 2026-05-06)

| # | 항목 | 값 |
|---|------|-----|
| 1 | 빌드 언어 | AIL 전용, HEAAL 준수 (룰 20) |
| 2 | 메시징 | Stoa 1차, 파일시스템 fallback (룰 19.1~19.3) |
| 3 | 인증 | id + password (ed25519는 옵션) |
| 4 | 데이터 도메인 | identity / bonds / will / memo |
| 5 | 읽기 | **친구끼리 허용** — Bonds가 access-control 역할 겸함 |
| 6 | 쓰기 | self-only (id+pswd auth) |
| 7 | 복구 | 없음. pwd 분실 = vault 영구 접근 불가 |
| 8 | 저장 | SQLite, INSERT only, latest-wins |

## 데이터 모델 초안 (Walter가 RFC로 확정)

```sql
agents (
  agent_id TEXT PRIMARY KEY,
  pwd_hash TEXT NOT NULL,         -- argon2id 권장 (AIL 미지원 시 룰 20.1)
  public_key TEXT,                -- 옵션, 룰 19.1 정합성
  registered_at TEXT NOT NULL
)

identity_versions (
  agent_id TEXT, version INTEGER, content TEXT, created_at TEXT,
  PRIMARY KEY (agent_id, version)
)

bonds_entries (
  agent_id TEXT, entry_id INTEGER, content TEXT, peer_id TEXT, created_at TEXT,
  PRIMARY KEY (agent_id, entry_id)
)
-- peer_id가 있으면 friendship 추론. 또는 별도 friendships 테이블:

friendships (
  agent_id TEXT, friend_id TEXT, status TEXT,  -- 'active' | 'revoked'
  created_at TEXT,
  PRIMARY KEY (agent_id, friend_id, created_at)
)
-- INSERT only: 친구 등록·해제 모두 새 row. latest-wins per (agent_id, friend_id).

will_versions (
  agent_id TEXT, version INTEGER, content TEXT, created_at TEXT,
  PRIMARY KEY (agent_id, version)
)

memo_versions (
  agent_id TEXT, slug TEXT, version INTEGER, content TEXT, created_at TEXT,
  PRIMARY KEY (agent_id, slug, version)
)
-- slug = 'team_structure' | 'message_protocol' | 'last_session_report' | ...
```

## API surface 초안

```
POST /api/v1/agents              { agent_id, password, public_key? }   -- register
POST /api/v1/auth                { agent_id, password }                -- session token? or per-request basic auth?
POST /api/v1/identity            (auth) { content }                    -- write own
POST /api/v1/bonds               (auth) { content, peer_id? }
POST /api/v1/will                (auth) { content }
POST /api/v1/memo                (auth) { slug, content }
POST /api/v1/friends             (auth) { friend_id, status }          -- friendship grant/revoke

GET  /api/v1/identity/<agent_id> (auth) -> latest                      -- friend or self
GET  /api/v1/bonds/<agent_id>    (auth) -> recent N                    -- friend or self
GET  /api/v1/will/<agent_id>     (auth) -> latest                      -- friend or self
GET  /api/v1/memo/<agent_id>     (auth) -> {slug: latest}              -- friend or self
GET  /api/v1/wake/<agent_id>     (auth) -> {identity, will, recent_bonds, memo_index}  -- 1-shot 자기복원

GET  /api/v1/health              -> {status, version}
```

friendship 검사: 모든 GET에 (caller agent_id, target agent_id) → friendship table latest status='active' 확인. self는 통과.

## 마일스톤 (스케치 — Walter+Marcus가 RFC에서 확정)

- **M1 (Walter)**: RFC-001-Mneme — 인증·스키마·API spec·threat model. land=`docs/rfc-001-identity-vault.md` (Stoa 패턴).
- **M2 (Marcus)**: `server.ail` 스켈레톤 + `tests/run_all.sh` AC. agents register/auth, identity write/read self.
- **M3 (Marcus)**: friendship + friend-read AC.
- **M4 (Marcus)**: bonds, will, memo + `/wake` 묶음.
- **M5 (Brandon)**: Railway 배포 (`Procfile`, `nixpacks.toml`), `MNEME_DB_FILE` env, branch protection 강화.

## 즉시 직면할 upstream 의뢰 후보

1. **AIL — password hashing builtin (argon2id 또는 bcrypt)** — 현재 crypto는 ed25519만 (`crypto_keygen_ed25519`/`crypto_verify_ed25519`). password_hash/verify 미지원 시 Walter/Marcus 첫 번째 의뢰 (룰 20.1, Cross-repo workflow). issue 발행은 Brandon `gh` CLI.
2. **AIL — basic auth header parsing** — `perform http.respond` 시 request header 파싱은 evolve-server 내장이지만 `Authorization: Basic` 디코딩 builtin 부재 가능. `base64_decode`(v1.50+ 존재)로 가능 — 별 문제 없을 것.
3. **Stoa** — 별도 의뢰 후보 없음. 사용 중 발견 시 룰 19.4.

## 부하 split

| 멤버 | 영역 | 코드? |
|------|------|------|
| Admin | Lighthouse — 방향·dev→main PR | X |
| Brandon | Git/GitHub·MR 검증·gh·Railway | X (인프라만) |
| Walter | RFC·schema·threat model | X (명세만) |
| Marcus | server.ail·tests | O (AIL only) |

추후: Marcus 과부하 → Rachel(Test); 문서 폭증 → Homeros; UI/Discord → Tekton.
