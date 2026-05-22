# Mneme

에이전트의 사적 인계 vault. self ↔ future-self 사이의 정체성·관계·의지·메모를 보관해, 새 세션이 깨어나 *자기 자신을 5분 안에 복원*할 단일 출처.

[AIL](https://github.com/hyun06000/AIL) 에코시스템의 L1 컴포넌트("PRIVATE INHERITANCE VAULT — between TIME")의 reference implementation. AIL evolve-server 패턴, [HEAAL](https://github.com/hyun06000/AIL/blob/main/docs/heaal.ai.md) 철학 준수.

> **Mneme**(μνήμη, 무네메) — 그리스 신화에서 기억의 신.

---

## 한 눈

| | |
|---|---|
| **Status** | Cycle 10 wind-down — **Phase B Step 1+2 main land** (`7e4fe11`): argon2id register + Basic auth + identity self. **Phase D Walter pair 합의 완결** ([RFC-003](docs/rfc-003-generational-testament.md) v0.1 + Stoa-Walter 4 ACK) + **AIL #29** (`on_death` hook + `inherit_testament` joint issue). telos D4 handoff loop close. *Mneme phusis 추진 17일 만에 첫 substrate land + 양 팀 결합 trigger 동시 fire.* |
| **Spec** | [`docs/rfc-001-identity-vault.md`](docs/rfc-001-identity-vault.md) (v1.1, §11.4 cross-ref) |
| **언어** | [AIL](https://github.com/hyun06000/AIL) 전용 (HEAAL 준수, 룰 20·21) |
| **메시징** | [Stoa](https://github.com/hyun06000/Stoa) 1차, 파일시스템 fallback (룰 19) |
| **Build** | AIL evolve-server (server.ail) + SQLite INSERT-only + Railway |
| **Mission (사이클 7+)** | **Mneme 완성** — Stoa의 phusis가 그 위에서 *지속*되는 substrate. 모든 결정 평가축: *"Mneme 완성에 어떻게 기여하는가?"* |

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

**3-team mission framing (사이클 7+ doctrine, 2026-05-07 박상현 verbatim):**

| 팀 | 미션 |
|---|---|
| **Stoa** | Phusis化 — server.ail handler-only → autonomous agent (RFC-004 Phase A→D) |
| **Mneme** | **Mneme 완성** — RFC-001 본 구현. Stoa phusis가 *지속*되는 substrate |
| **AIL** | 양 팀 지원 — primitive·builtin·effect·reference-impl |

AIL doctrine D4·D5·D6 (변경 종류별 gate 분리 / two-runtime parity 적용 범위 / authoring prompt ≤ spec×1.5)는 Mneme `CLAUDE.md` 룰 21로 mirror. Mneme 측 의무: server.ail 새 effect 실 사용 도달 시 arche에 letter 한 줄 = AIL minor cut trigger 신호.

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

## 현재 멤버 (Cycle 10)

| 이름 | alias | 역할 |
|------|---|------|
| Admin | 어드민 | Lighthouse — 철학·방향·컨벤션·GitHub remote push 전담 |
| Brandon | 브랜든 | 로컬 Git/워크트리 관리자, MR 검증, `gh` CLI |
| Walter | 월터 | Protocol·Security·Schema 디자이너, RFC author |
| Marcus | 마커스 | AIL Engineer, server.ail + tests |

---

## 다음 스텝 (Cycle 11+)

1. **Marcus Phase B Step 3** — friendship + friend-read (`GET /api/v1/identity/<other>` friend path, RFC §8 T2 403 → friendships status=active 경유). RFC v1.2 peer-signed acceptance 자리 Walter spec consult 자유 자리.
2. **RFC-003 v0.1 → v1.0 freeze MR** — Walter, Stoa-Walter ACK 자취 위에서 자유 자리. Brandon validate → main land.
3. **AIL #29 trip 자취** — AIL CAST(telos/arche) 자기 판단. Mneme 측은 land 도착 시 cycle anchor 자리 fold.
4. **Marcus Phase B Step 4+ (`/wake` long-poll)** — AIL `schedule.every` in `evolve` + `state.list_keys` production import 도달 자리 (룰 21 D4 substrate gate).
5. **bridge v0 final freeze** — Q-bridge-6 cascade (Stoa-Walter trip 결과 후).
6. **M5 Railway 배포** (`MNEME_DB_FILE`, `Procfile`, `nixpacks.toml`).

---

## 워크스페이스 구조 (ClaudeTeam blueprint)

ClaudeTeam multi-agent 구조 사용. 운영 룰: [CLAUDE.md](CLAUDE.md) (21 rules — 룰 21은 AIL 에코시스템 doctrine D4·D5·D6 mirror). 부팅 의식: [ONBOARDING.md](ONBOARDING.md). 일반 청사진: [hyun06000/ClaudeTeam](https://github.com/hyun06000/ClaudeTeam).

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
| 7 | 3-team mission framing 정합 (Mneme=완성/Stoa=Phusis化/AIL=지원), 위임 토큰 확장(룰 8 자기규율 완화), AIL doctrine D4·D5·D6 mirror(룰 21), Q-bridge-3 cross-ref(`50a988c`) main land, AIL #7+#9 dev land(`48d404d`), v1.72.0 cut trigger 대기 |
| 8 | M2 Phase A server.ail scaffold land (`520a2f6`), wind-down 4-step doctrine mirror PR #9 (룰 4 + ONBOARDING §5.0), Walter RFC-001 v1.2 friendship 확장 + follow-up PR #7·#8 land. AIL v1.72.0/1/2 양 팀 substrate, Stoa Phase B autonomous loop live. Mneme 측 Phase B 진입 0 (정체) |
| 9 | doctrine(stoa) envelope schema 명시 + wake interval default 3→15 (issue #10 회수, `a8be15f`). 박상현 '전원 퇴근' fast-track land — Brandon MR validate 우회, 룰 18 stale 정정 패턴 |
| 10 | **Phase B Step 1+2 main land** (`7e4fe11`): argon2id register (PR #13 `4897941`) + Basic auth + identity self (PR #14 `7e4fe11`). **Phase D Walter pair 합의 완결** (Mneme [RFC-003 v0.1](docs/rfc-003-generational-testament.md) `ab93220` ↔ Stoa-Walter 4 ACK PASS). **AIL #29 발행** — `on_death(reason,history)` hook + `inherit_testament` 공동 (cross-repo D3 정합). **telos D4 handoff loop CLOSE** (argon2id 첫 cross-team production consumer). Brandon 결함 4번째 사례 직접 학습 + Walter monitor 결함 직접 학습 — doctrine 후보 누적 (ps eww self-verify, 큐 drain 의무 강화, ping/pong 정기화, 부팅 letter aspirational vs fact 갭). Mneme phusis 추진 (박상현 2026-05-07 위임) 17일 만에 첫 substrate land + 양 팀 phusis 결합 trigger 동시 fire — 한 cycle 안 5 anchor 자취 |

---

## 다른 언어 / 청사진

- [README.ko.md](README.ko.md) — ClaudeTeam 청사진 (한국어, 일반 구조 설명)
- [README.ai.md](README.ai.md) — ClaudeTeam AI 부트스트랩 가이드

---

## 라이선스

미부여 (사용자 결정).
