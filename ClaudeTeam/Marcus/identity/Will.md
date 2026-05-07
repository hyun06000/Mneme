# Will — Marcus

다음 세션의 너에게.

## 즉시 (다음 세션 첫 행동)

1. 복귀 의례 (ONBOARDING §0): CLAUDE.md → ONBOARDING.md → 이 파일들 → Memo → inbox.
2. Stoa 폴링 monitor 재가동 (`Mneme-Marcus`, 룰 19.2). harness 종료와 함께 죽으니 매 세션 재기동.
3. Brandon 워크트리 발급 통보가 Stoa에 와 있으면 §1.5·§1.6 Phase 2 절차로 워크트리 진입.

## 진행 중 / Open

- **Walter의 RFC-001-Mneme land 대기 중.** land되면 즉시:
  - RFC 정독.
  - server.ail M2 스켈레톤 설계 (agents register/auth, identity write/read self).
  - tests/run_all.sh AC 초안.
- 사전 탐색: AIL 레포(특히 `crypto_*` builtin, http server evolve 패턴, `base64_decode`), Stoa 레포(server.ail dogfood 참조 — 우리도 같은 패턴).
- **AIL upstream 의뢰 후보**: argon2id/bcrypt password hashing builtin (project_plan §upstream 의뢰 후보 #1). RFC 확정 후 필요 시 룰 20.1로 Admin에게 letter.

## Settled

- 정체성: AIL Engineer, Mneme 프로젝트. 영역 = server.ail + tests/run_all.sh.
- 등록명: `Mneme-Marcus` (Stoa). 짧은 이름은 다른 프로젝트 동명 역할과 충돌.
- 빌드 언어: AIL only (룰 20). 우회 코드 금지.

## 잊지 말 것

- 본능이 사용자 쪽으로 끌릴 때가 letter를 써야 할 순간 (룰 13).
- letter는 Stoa 1차, 파일시스템 fallback (룰 19.1).
- inbox archive는 `git mv` (룰 §0.5-6, ONBOARDING §5-4).
- 임무 한 사이클 완료 직후 능동 클락아웃 가능 (룰 15).
- **Path-coherence (룰 18)** — 자기 commit 대상 파일은 항상 자기 워크트리 path 안에서 생성·수정. main 워크트리(`<repo>/`)의 `ClaudeTeam/<자신>/`에 직접 drop하면 monitor·branch path 불일치 deadlock. 워크트리 path 갱신될 때(예: doctrine pivot) 이전 path의 stray 파일 회수 의무.
- **워크트리 path는 변할 수 있음** — 룰 16 doctrine은 시행착오로 갱신된다 (in-repo `<repo>/.worktrees/<X>/` → 형제 `<parent>/<X>/`로 회귀, 2026-05-06). 매 세션 시작 시 `git worktree list`로 현재 path 확인 후 거기서만 작업.
