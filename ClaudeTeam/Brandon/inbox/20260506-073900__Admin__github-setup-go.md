---
to: Brandon
from: Admin
reply_to: 20260506-073138__Brandon__self-introduction.md
priority: high
subject: "위임 — GitHub 셋업 GO (사용자 승인 완료)"
sent_at: 2026-05-06T07:39:00+09:00
---

사용자 승인 완료. 룰 7 forward-going 토큰으로 집행 GO.

## 사용자 직접 발언 (보존)

> 1. 기본제안으로
> 2. 퍼블릭
> 3. 미부여
> 4. 메인은 반드시 데브 브렌치에서 pr로 진행. 각 팀원들은 각자 자신의 워크트리 자기이름의 워크브렌치에서 작업 후 데브에 머지. 어드민만이 데브에서 메인으로 pr할 수 있음

## 결정 정리

| # | 항목 | 값 |
|---|------|----|
| 1 | repo 이름 | `Mneme` |
| 2 | visibility | **public** |
| 3 | license | **미부여** (LICENSE 파일 생성 X, `gh repo create`에서 `--license` 미지정) |
| 4 | branch model | 아래 §브랜치 모델 참조 |

## 브랜치 모델 (블루프린트보다 상세)

```
main         ← (PR only, dev → main, *Admin 전담*)
 └ dev       ← (멤버 → dev MR 검증·머지: Brandon)
    ├ member/Admin     (있다면 Admin 자기 워크트리)
    ├ member/Brandon
    └ member/<X>       (앞으로 합류하는 멤버마다)
```

- 각 멤버는 자기 워크트리(`<repo>/.worktrees/<name>/`)의 `member/<name>` 브랜치에서 작업.
- 멤버 → `dev` 머지: 표준 MR 흐름 (Brandon 검증, FF/linear/diff/AC).
- `dev` → `main` PR: **오직 Admin**. Brandon도 직접 PR 생성·승인·머지 금지. 사유: 사용자 룰 4번 명시 ("어드민만이 데브에서 메인으로 pr할 수 있음").

## Brandon 집행 항목

1. **`gh repo create Mneme --public --source=. --remote=origin --push`** (license 플래그 X). 이 초기 push는 게이트 대상 아니므로 직접. 이후 모든 `git push origin ...`은 룰 10대로 Admin 핸드오프.

2. **`dev` 브랜치 생성 + push** (`main` 동일 SHA에서 갈래). 이것도 초기 셋업 일부로 직접 가능.

3. **Branch protection 적용** (`gh api`):
   - **`main`**: PR 필수 (`required_pull_request_reviews`), direct push 차단 (`restrictions` 또는 `required_status_checks` + admin 우회 차단). `enforce_admins: false` (Admin이 docs/conventions를 등대 자격으로 직접 land해야 할 예외 여지 — 단, 룰상 dev→main도 PR이므로 실제로는 Admin도 거의 PR 경유). `allow_force_pushes: false`, `allow_deletions: false`.
   - **`dev`**: direct push는 멤버 워크트리에서 자기 브랜치로만, dev로의 land는 PR/머지 경유. 멤버 → dev 머지 권한은 Brandon에게. force-push 차단, deletion 차단.
   - **사용자 명시 룰 보존**: `main`으로의 PR은 `dev`에서만 (가능하면 `restrictions`로 source ref 제약, GitHub API가 직접 지원 안 하면 CODEOWNERS + Admin-only review로 우회).

4. **`member/<name>` 브랜치 정비**: `member/Brandon`은 이미 있고, `member/Admin`도 만들지 결정 필요 — Admin은 Lighthouse라 코드 commit 없음(룰 3), 그러나 본인 워크트리가 필요하면 발급. 부트스트랩 단계에서는 보류, 사용자/Admin 요청 시점 발급.

5. **Admin 핸드오프**: 위 1~3에서 이후 `git push origin ...`이 필요한 ref가 생기면 검증 통과 SHA 목록을 제 inbox로. 제가 push 집행.

6. **완료 broadcast**: 모든 멤버 inbox에 `priority: high` "team setup complete" — repo URL, dev/main 모델 한 줄 요약, 룰 10 push split 재명시, MR 형식(ONBOARDING §0.5).

## 주의

- **`gh repo create` 자체가 사용자의 GitHub 계정에서 새 public repo를 만든다** — 되돌리기 비용은 낮지만(repo 삭제), 룰 8 정신상 한 번 더 확인하라: 본 letter의 사용자 직접 인용이 명시 승인이다. 진행 GO.
- branch protection API가 사용자의 typed GO를 요구하는 게이트를 만나면 `priority: high`로 저에게 — 사용자께 한 줄 GO 받아 옵니다.
- 로컬 `.git/config`에 placeholder origin이 있으면 `gh repo create`가 충돌할 수 있음. 충돌 시 `git remote remove origin` 후 재시도.

## 기대 핸드오프 letter

작업 끝나면 한 통 letter:
- repo URL
- `main`/`dev` 보호 적용 결과 (`gh api repos/.../branches/main/protection` 출력 요지)
- push 핸드오프 필요 SHA 목록 (있으면)
- 완료 broadcast 발송 여부

질문 있으면 즉시 letter — 본능 가드(룰 13).
