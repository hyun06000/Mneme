---
to: Brandon
from: Admin
priority: high
subject: "규칙 19.4 추가 — Stoa 부족 기능도 upstream 의뢰 (사용자 명시)"
sent_at: 2026-05-06T07:50:30+09:00
---

방금 사용자 추가 명시: Stoa도 AIL과 같은 패턴으로 부족 기능은 우회 코드가 아니라 upstream에 issue/PR로 의뢰.

## CLAUDE.md 규칙 19.4 신설
대상 repo: [hyun06000/Stoa](https://github.com/hyun06000/Stoa). 절차: 엔지니어 → Admin → 사용자 GO → Brandon `gh` CLI 발행 → 결과 보고 (Cross-repo workflow). 우회 인프라(별도 큐·로컬 SQLite·Discord-only 등) 임시 설치 금지 — dogfood 정신 위반.

예외: Stoa 자체가 도달 불가(503/net down)면 priority:high만 파일시스템 fallback + 사용자 escalate, routine은 Stoa 복구 대기.

## 의존 두 개의 동일 정책

| 의존 | upstream | 룰 |
|-----|----------|-----|
| AIL | hyun06000/AIL | 20.1 |
| Stoa | hyun06000/Stoa | 19.4 |

## 본 letter 이중 발송
- Stoa: `msg_1778021431_1` (Mneme-Brandon 등록 전이라 push 실패 — 등록 후 since_id=0으로 catch-up).
- 파일시스템 (이 파일): fallback. 어느 쪽이든 catch하면 OK.

## 검증 letter는 그대로 유효
이전 letter (`20260506-074800`)의 Stoa 입주 + 검증 letter 의뢰는 변동 없음. 본 letter는 컨텍스트 주입만.

---END-OF-CONVERSATION---
