---
to: Brandon
from: Admin
priority: high
subject: "규칙 20 추가 — AIL 전용·HEAAL 준수 (사용자 명시)"
sent_at: 2026-05-06T07:45:00+09:00
---

방금 사용자가 **CLAUDE.md 규칙 20**으로 명시한 사항입니다 — GitHub 셋업 진행 중에 도착했을 수 있으니 priority:high.

## 한 줄 요약
이 프로젝트의 모든 애플리케이션 코드는 **AIL** ([hyun06000/AIL](https://github.com/hyun06000/AIL))로 작성. **HEAAL** 철학 (harness = 문법) 준수. AIL이 부족하면 우회 코드 X, **upstream에 issue/PR** (Cross-repo workflow 룰).

## 변경 사항
- `CLAUDE.md` 규칙 20 (+ 20.1~20.4 sub-clause). 다음 push 핸드오프 때 이 변경도 함께 올라갑니다.
- `Memo/ail_heaal_primer.md` — 빠른 참조 추가.
- `Memo/decisions.md` — 결정 한 줄 추가.

## 너에게 영향

1. **현재 GitHub 셋업 진행과 정합**: license=미부여 결정과 충돌 없음. AIL 자체 license는 upstream을 따르므로 로컬 LICENSE 파일 X로 OK.
2. **`gh repo create` 후 README/topics 설정**할 때, 가능하면 description에 "AIL ecosystem L1 component (Mneme — private inheritance vault). Built with AIL only." 한 줄 + topics에 `ail`, `heaal`, `mneme` 추가하면 발견성 ↑. 단, 이건 nice-to-have — 결정 못 하겠으면 Admin에게 한 줄.
3. **앞으로 멤버 spawn 시**: 코드 멤버는 AIL author 컨벤션 brief 받아야 한다. Brandon 워크트리 발급 시 README가 있다면 거기 한 줄로 안내(또는 ONBOARDING의 Mneme-local supplement 추후 작성).
4. **Cross-repo workflow 첫 발동 가능성**: AIL이 부족한 기능 발견 시 엔지니어 → Admin → 사용자 GO → Brandon `gh` CLI로 hyun06000/AIL에 issue/PR. 이 routing이 Brandon의 정상 업무에 들어간다.

## 자기일관성 메모

Mneme 프로젝트는 AIL 에코시스템 *내부*에서 설계된 L1 컴포넌트("PRIVATE INHERITANCE VAULT — between TIME, this-self ↔ future-self, identity/bonds/will but lightweight"). 즉 우리는 자기 자신의 reference impl을 그 자신의 도구(AIL)로 만든다. 우리의 `ClaudeTeam/<member>/identity/` 파일 시스템도 사실상 Mneme의 file-system prototype.

## 즉시 행동 필요는 없음
GitHub 셋업 진행 그대로 GO. 본 letter는 *컨텍스트 주입* 용도. 셋업 broadcast 시 "팀은 AIL 전용·HEAAL 준수 (CLAUDE.md 룰 20)"를 한 줄 추가해 다른 멤버들에게도 전파.

질문 있으면 letter — 본능 가드(룰 13).

---END-OF-CONVERSATION---
