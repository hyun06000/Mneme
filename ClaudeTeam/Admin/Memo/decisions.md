# Decisions log

| Date | Decision | Choice | Source |
|------|----------|--------|--------|
| 2026-05-06 | D1 — Lighthouse 멤버 이름 | `Admin` | 자율 기본값 (사용자가 명시 X — autonomous 진행 인가됨) |
| 2026-05-06 | D2 — 프로젝트 주 언어 | 한국어 | 사용자 invoke 언어 |
| 2026-05-06 | D3 — `sent_at` 시간대 | KST (`+0900`) | 호스트 TZ |
| 2026-05-06 | D4 — 호스트 언어 reading alias | Admin↔어드민, Brandon↔브랜든 | 자율 기본 transliteration |
| 2026-05-06 | Forward-going 위임 인가 (룰 7 토큰) | 활성 | 사용자 직접 발언 — Brandon `20260506-073335` letter에 인용 보존 |
| 2026-05-06 | GitHub repo 셋업 | `Mneme` public, license 미부여, branch model: main←PR(Admin only)←dev←member/* | 사용자 직접 발언 |
| 2026-05-06 | **빌드 언어 = AIL 전용, HEAAL 준수** | 모든 코드는 AIL. 부족 시 upstream(hyun06000/AIL)에 issue/PR (CLAUDE.md 룰 20) | 사용자 직접 발언 |
| 2026-05-06 | 메시징 인프라 = Stoa | `https://ail-stoa.up.railway.app`, registry명 `Mneme-<role>`. Mneme-Admin 등록 완료(2026-05-05T22:46:56Z UTC). 파일시스템 inbox는 fallback (CLAUDE.md 룰 19.1~19.3) | 사용자 직접 발언 |
| 2026-05-06 | Mneme의 데이터 표면 확장 | `identity/` + `Memo/` 둘 다 Mneme self↔future-self vault의 일부 (CLAUDE.md 룰 20.2.1) | 사용자 직접 발언 |
| 2026-05-06 | Stoa 부족 기능도 upstream에 의뢰 | 우회 코드 X, hyun06000/Stoa에 issue/PR (CLAUDE.md 룰 19.4 — AIL 룰 20.1과 동일 패턴) | 사용자 직접 발언 |
| 2026-05-07 | RFC §9 Q1~Q4 + Q-bridge-6 결정 | Q1=Basic, Q2=20, Q3=TLS only, Q4=OR, Q-6=채택 (agents.pwd_hash NULLable + CHECK) | 사용자 직접 발언 |
| 2026-05-07 | bridge v0 split copy 위치 | Mneme path = `bridge-stoa-mneme/v0.md` (Stoa와 동일 mirror) — 공동 owner doctrine | Stoa-Admin 의제 + Admin 판단 |
| 2026-05-07 | Brandon 페어 SOP | 공동 owner / Walter 합의 → 양 Brandon 동시 land / divergence Brandon letter / versioning sync | Stoa-Admin 의제 채택 |
| 2026-05-07 | Stoa monitor 표준 contract | `STOA_NAME` 필수 환경변수 (오타 함정 가드), 캐논 `community-tools/stoa_wake_monitor.sh` 사용. ONBOARDING §1.0 정합 | 사용자 직접 발화 (Stoa-Admin 통해 인용) |
| 2026-05-07 | **위임 토큰 확장** | "이제부터는 나에게 물어보지말고 너의 판단대로 하도록 해. 난 널 믿어" — 룰 8 자기규율 임계 완화. 진짜 되돌릴 수 없는·본구조 변경 사안만 surface. | 사용자 직접 발언 |
| 2026-05-07 | **3 팀 mission framing (사이클 7+)** | Mneme=완성 / Stoa=Phusis化 / AIL=양 팀 지원. Mneme 측 default 평가축 = "이게 Mneme 완성에 어떻게 기여하는가?" | 사용자 직접 발언 (Stoa-Admin 통해 verbatim 인용) |
| 2026-05-06 | Mneme 프로젝트 정체 | 에이전트 사적 인계 vault. id+pswd auth. identity/bonds/will/memo 저장. wake 시 자기 복원. AIL evolve-server, SQLite, INSERT only | 사용자 직접 발언 |
| 2026-05-06 | 읽기 접근 정책 | **친구끼리 읽기 허용** (Bonds = access-control 역할 겸함). write = self-only(id+pswd) | 사용자 직접 발언 |
| 2026-05-06 | 복구 메커니즘 | **없음**. pwd 분실 = vault 영구 접근 불가. 새 agent_id로 재시작 | 사용자 직접 발언 |
| 2026-05-06 | 신규 멤버 spawn | Walter (Protocol·Security·Schema, no code), Marcus (AIL Engineer, server.ail) | 사용자 직접 발언 |
| 2026-05-06 | Walter·Marcus 합류 완료 | Stoa Mneme-Walter(23:06:57Z UTC) / Mneme-Marcus(23:07:07Z UTC) 등록·자기소개·CLAUDE.md 멤버 표 등재 | 자기소개 letter |
| 2026-05-06 | 친구 관계 transitive read | **거부** — 직접 친구만 read 허용. 친구의 친구는 별도 friendship row 필요 | Admin 설계 결정 (Walter RFC threat model에 명시) |
| 2026-05-06 | 친구 관계 방향성 | 단방향 권장(grant 패턴) — A가 B를 친구 등록 = A 데이터가 B에게 read open. RFC에서 Walter가 정식 결정 후 사용자 콜 가능 | Admin 권장, RFC 결정 |
| 2026-05-06 | GitHub 첫 push | main(78cd65e→8618ded FF), dev(new @8618ded), member/Brandon(new @f169160) 모두 origin land. branch protection은 Brandon이 다음 단계로 진입 | Admin 집행 (사용자 설정 GO 위임 토큰) |

## Brandon에게 위임 (선결 금지)
- GitHub remote 이름·visibility (public/private)
- License
- 기본 브랜치 이름·branch protection 규칙
- CI / GitHub Actions
- 워크트리 layout (Brandon이 규칙 16의 `<repo>/.worktrees/<name>/` 구현)
