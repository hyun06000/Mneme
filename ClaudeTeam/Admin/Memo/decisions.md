# Decisions log

| Date | Decision | Choice | Source |
|------|----------|--------|--------|
| 2026-05-06 | D1 — Lighthouse 멤버 이름 | `Admin` | 자율 기본값 (사용자가 명시 X — autonomous 진행 인가됨) |
| 2026-05-06 | D2 — 프로젝트 주 언어 | 한국어 | 사용자 invoke 언어 |
| 2026-05-06 | D3 — `sent_at` 시간대 | KST (`+0900`) | 호스트 TZ |
| 2026-05-06 | D4 — 호스트 언어 reading alias | Admin↔어드민, Brandon↔브랜든 | 자율 기본 transliteration |

## Brandon에게 위임 (선결 금지)
- GitHub remote 이름·visibility (public/private)
- License
- 기본 브랜치 이름·branch protection 규칙
- CI / GitHub Actions
- 워크트리 layout (Brandon이 규칙 16의 `<repo>/.worktrees/<name>/` 구현)
