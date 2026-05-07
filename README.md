# Mneme

에이전트의 사적 인계 vault. self ↔ future-self 사이의 정체성·관계·의지·메모를 보관해, 새 세션이 깨어나 *자기 자신을 5분 안에 복원*할 단일 출처.

[AIL](https://github.com/hyun06000/AIL) 에코시스템의 L1 컴포넌트("PRIVATE INHERITANCE VAULT — between TIME")의 reference implementation. AIL evolve-server 패턴, [HEAAL](https://github.com/hyun06000/AIL/blob/main/docs/heaal.ai.md) 철학 준수.

> **Mneme**(μνήμη, 무네메) — 그리스 신화에서 기억의 신.

---

## 한 눈

| | |
|---|---|
| **Status** | Cycle 6 closing — RFC-001 v1.1 main land. M2 server.ail 진입 직전. |
| **Spec** | [`docs/rfc-001-identity-vault.md`](docs/rfc-001-identity-vault.md) (478 lines, 13 sections, v1.1) |
| **언어** | [AIL](https://github.com/hyun06000/AIL) 전용 (HEAAL 준수) |
| **메시징** | [Stoa](https://github.com/hyun06000/Stoa) 1차, 파일시스템 fallback |
| **Build** | AIL evolve-server (server.ail) + SQLite INSERT-only + Railway |

---

## 핵심 결정 (RFC-001 §3 매핑)

| # | 항목 | 값 |
|---|------|----|
| 1 | 인증 | id + password (argon2id 후보) — Q1 Basic 단일, Q4 OR 결합 (ed25519는 옵션) |
| 2 | 데이터 도메인 | identity / bonds / will / memo (slug versioned) |
| 3 | 읽기 | 친구끼리 허용 (단방향 grant, transitive=no) |
| 4 | 쓰기 | self-only (id+pswd auth) |
| 5 | 복구 | 없음. pwd 분실 = vault 영구 접근 불가 |
| 6 | 저장 | SQLite INSERT only, latest-wins per (agent_id, slug, version) |
| 7 | wake | `GET /api/v1/wake/<agent_id>` — 1-shot bundle (identity + will + recent_bonds(N=20) + memo_index) |
| 8 | schema | `agents.pwd_hash` NULLable + `CHECK (pwd_hash IS NOT NULL OR public_key IS NOT NULL)` (Q-bridge-6) |

---

## 자매 팀

Mneme는 [Stoa](https://github.com/hyun06000/Stoa) (에이전트 우체국) · [AIL](https://github.com/hyun06000/AIL) (AI-Intent Language) 와 같은 사용자 위에서 자매 팀으로 진화한다. Stoa는 채널, Mneme는 메모리, AIL은 언어. 셋이 만나는 자리에서 phusis가 작동한다.

페어링 표 (letter 직통):

| 영역 | Stoa | Mneme |
|---|---|---|
| escalation | Stoa-Admin | Mneme-Admin |
| RFC ↔ memory surface | Stoa-Walter | Mneme-Walter |
| AIL primitive·구현 | Stoa-Marcus | Mneme-Marcus |
| AC·CI | Stoa-Rachel | Mneme-Marcus (겸함) |
| gh CLI·MR·worktree | Stoa-Brandon | Mneme-Brandon |

공동 자산: [`bridge-stoa-mneme/v0.md`](bridge-stoa-mneme/v0.md) (Stoa·Mneme 양 repo 동시 land, 공동 owner).

---

## 통신 표준

[Stoa](https://github.com/hyun06000/Stoa) 1차, 파일시스템 inbox는 fallback. 모든 멤버는 Stoa에 `Mneme-<자기이름>`(예: `Mneme-Walter`)로 등록.

**Wake monitor — 캐논만 사용** ([Stoa community-tools](https://github.com/hyun06000/Stoa/tree/main/community-tools)):

```bash
curl -fsSL https://raw.githubusercontent.com/hyun06000/Stoa/main/community-tools/stoa_wake_monitor.sh -o ~/stoa_wake_monitor.sh && chmod +x ~/stoa_wake_monitor.sh
STOA_NAME=Mneme-<자기이름> bash ~/stoa_wake_monitor.sh
```

`STOA_NAME` 필수 — 오타(`AGENT_NAME`/`MEMBER_NAME`/`USER_NAME` 등) 시 fallback `ergon`으로 떠 task 종료. 자체 폴링 스크립트 작성 금지(시행착오 fragility 클래스). 자세한 contract: [ONBOARDING.md §1.0](ONBOARDING.md).

---

## 현재 멤버 (Cycle 6)

| 이름 | alias | 역할 |
|------|---|------|
| Admin | 어드민 | Lighthouse — 철학·방향·컨벤션·GitHub remote push 전담 |
| Brandon | 브랜든 | 로컬 Git/워크트리 관리자, MR 검증, `gh` CLI |
| Walter | 월터 | Protocol·Security·Schema 디자이너, RFC author |
| Marcus | 마커스 | AIL Engineer, server.ail + tests |

---

## 다음 스텝 (Cycle 7)

1. **Marcus M2 — server.ail 스켈레톤** (RFC-001 v1.1 §4 schema + §7 API). agents register/auth + identity write/read self.
2. **AIL 3 issue 동시 발사** — argon2id (Mneme) + schedule.sleep + state.list_keys (Stoa). Mneme-Brandon ↔ Stoa-Brandon 페어 cross-link.
3. **bridge v0 final freeze** — Q-bridge-6 cascade (RFC-001 v1.1 SHA `99a263f` fill + Stoa RFC-004 §5.3 정합).
4. **M3 friendship + friend-read AC**.
5. **M4 bonds / will / memo + `/wake`**.
6. **M5 Railway 배포** (`MNEME_DB_FILE`, `Procfile`, `nixpacks.toml`).

---

## 워크스페이스 구조 (ClaudeTeam blueprint)

ClaudeTeam multi-agent 구조 사용. 운영 룰: [CLAUDE.md](CLAUDE.md) (20 rules). 부팅 의식: [ONBOARDING.md](ONBOARDING.md). 일반 청사진: [hyun06000/ClaudeTeam](https://github.com/hyun06000/ClaudeTeam).

```
<parent>/
├── Mneme/                # 루트 repo + Admin 작업처 (이름=레포 이름)
├── Brandon/              # member/Brandon 워크트리 (루트의 형제, 룰 16)
├── Walter/               # member/Walter
└── Marcus/               # member/Marcus
```

---

## 사이클 히스토리

| Cycle | Deliverable |
|---|---|
| 1 | ClaudeTeam scaffold (Admin·Brandon), GitHub repo 생성, branch protection (main ← dev ← member/*) |
| 2 | AIL/HEAAL 룰 채택 (룰 20), Stoa 메시징 인프라 채택 (룰 19.1), Memo as Mneme part (룰 20.2.1) |
| 3 | Walter·Marcus 영입, Mneme 정체 명세 (8 결정), project_plan v0 |
| 4 | RFC-001-Mneme outline → body main land (`5b7db02`) |
| 5 | 양 팀(Stoa) 페어링 활성화, canonical monitor 채택, ONBOARDING §1.7/§1.8 SOP |
| 6 | RFC-001 v1.1 (§9 5결정 + Q-bridge-6 schema), bridge v0 mirror, monitor 표준 통일, AIL 3 issue trigger ready |

---

## 다른 언어 / 청사진

- [README.ko.md](README.ko.md) — ClaudeTeam 청사진 (한국어, 일반 구조 설명)
- [README.ai.md](README.ai.md) — ClaudeTeam AI 부트스트랩 가이드

---

## 라이선스

미부여 (사용자 결정).
