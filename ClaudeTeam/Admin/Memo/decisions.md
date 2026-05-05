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

## Brandon에게 위임 (선결 금지)
- GitHub remote 이름·visibility (public/private)
- License
- 기본 브랜치 이름·branch protection 규칙
- CI / GitHub Actions
- 워크트리 layout (Brandon이 규칙 16의 `<repo>/.worktrees/<name>/` 구현)
