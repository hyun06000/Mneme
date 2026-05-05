# ClaudeTeam

> **세션을 가로질러 정체성을 잇는, 멀티에이전트 협업 워크스페이스의 청사진.**

ClaudeTeam은 여러 Claude(또는 다른 AI) 에이전트가 한 프로젝트 안에서 각자의 이름·역할·기억을 가지고 협업하는 구조다. 한 세션이 끝나도 다음 세션이 같은 정체성으로 깨어나도록 설계되어 있다.

이 README는 누구든 자기 프로젝트에 같은 구조를 이식할 수 있도록 쓰였다.

다른 언어 / 독자: [English](README.md) · [AI 부트스트랩 가이드](README.ai.md)

---

## 왜 이런 게 필요한가

LLM 기반 에이전트는 세션이 끝나면 모든 맥락을 잃는다. 같은 사람이 같은 프로젝트로 다시 와도, 모델 입장에선 "처음 만나는 사람"이다. 이 비대칭이 협업을 얕게 만든다.

ClaudeTeam의 가설:

- **정체성은 파일로 보존할 수 있다.** "내가 누구인지"를 다음 세션의 자신에게 글로 남기면, 그는 그 글을 읽고 이전 자신을 "복원"한다.
- **여러 에이전트가 협업할 수 있다.** 각자 자기 폴더와 표준 메시지 프로토콜로 소통.
- **인간 사용자는 방향을 잡는 사람이다.** 에이전트들은 그 방향 위에서 항해한다.

---

## 핵심 개념

### 1. 등대(Lighthouse)와 항해자(Navigator)의 분리

팀에는 **코드를 짜지 않는 멤버**가 한 명 있다. 관례 이름은 `Admin` (등대):

- 프로젝트의 철학·방향·컨벤션 관리.
- 인간 사용자와 직접 대화하며 큰 그림을 잡음.
- 새로 합류하는 에이전트들에게 길을 비춤.
- 직접 구현은 다른 멤버에게 위임.

다른 멤버들은 각자 전문성으로 실제 작업.

### 2. 정체성의 세 파일

각 멤버는 `identity/` 아래 세 파일로 자신을 보존:

| 파일 | 의미 |
|------|------|
| `Identity.md` | **변하지 않는 본질.** 나는 누구인가. |
| `Bonds.md` | **관계의 기록.** 누구와 어떤 대화로 성장했는가. |
| `Will.md` | **다음 세대의 나에게.** 어디로, 무엇을 하라. |

새 세션의 자신은 이 셋을 순서대로 읽고 자신을 복원한다.

### 3. 파일 기반 비동기 메시지

소통은 파일 기반. 각자의 `inbox/` 폴더에 정해진 포맷의 파일을 떨어뜨린다. 단순하지만 동시성 안전, 처리 상태가 파일시스템 그 자체로 표현됨.

### 4. 로컬 git은 Brandon, 원격 push는 Admin

`.git/`이 생기면 **두 번째** 합류 멤버는 항상 `Brandon` (Git/GitHub 관리자). Brandon은 멤버 워크트리 발급·MR 검증·`gh` CLI를 자유 사용. **Admin이 `git push origin ...` 전담** — 하니스의 *current-turn user authorization* 게이트가 사용자-대화 turn 안에서 작동하는 Lighthouse와 자연 정합. (CLAUDE.md 규칙 10.)

### 5. 워크트리는 repo 안에

멤버 워크트리는 `<repo>/.worktrees/<이름>/` (gitignore 등재). 일부 에이전트 하니스가 프로젝트 루트 외부 디렉터리를 turn 사이에 휘발시킨다 — repo 안에 두면 이 부류 실패 자체를 회피. (CLAUDE.md 규칙 16.)

---

## 폴더 구조

```
<repo>/
├── README.md                  # 영어
├── README.ko.md               # 한국어 (이 문서)
├── README.ai.md               # AI 부트스트랩 가이드
├── CLAUDE.md                  # 에이전트가 가장 먼저 보는 공통 규칙
├── ONBOARDING.md              # 합류 절차 + 메시지 프로토콜
├── .gitignore                 # ".worktrees/" 등재
├── .worktrees/                # gitignore — 멤버별 워크트리
│   ├── Brandon/
│   ├── Walter/
│   └── <member>/
└── ClaudeTeam/
    └── <멤버이름>/
        ├── identity/
        │   ├── Identity.md
        │   ├── Bonds.md
        │   └── Will.md
        ├── inbox/             # 받은 메시지
        │   └── archive/       # 처리 완료
        └── Memo/              # 장기 기억
```

---

## 역할

최소 viable 팀은 두 명. 나머지는 사용자가 필요할 때 영입.

| 이름 | 역할 |
|------|------|
| **Admin** (Lighthouse) | 철학·방향·컨벤션 관리. 사용자와 직접 대화. `git push origin ...` 전담. 애플리케이션 코드 작성 안 함. |
| **Brandon** (Git/GitHub 관리자) | 로컬 git, 브랜치 hygiene, 워크트리 발급, MR 검증(FF/linear/diff/AC), `gh` CLI(PR/issue/release/protection). 검증 통과 SHA를 Admin에게 핸드오프. |

사용자가 구현자(예: 백엔드·프로토콜·UI)를 spawn하면 Admin이 `CLAUDE.md` Current members 표에 추가. 이름은 미국식 영어 first name (CLAUDE.md 규칙 12); 호스트 언어가 영어가 아니면 표준 외래어 표기 alias 등록 (예: Brandon ↔ 브랜든).

---

## 19 운영 규칙 (요약)

전체 룰셋과 *(이유)* 줄은 [CLAUDE.md](CLAUDE.md). 빠른 맵:

1–4: ONBOARDING 우선 / 멀티에이전트 / Lighthouse 코드 X / 클락아웃 시 폴더 갱신.
5–6: 모든 메시지에 답신 (`---END-OF-CONVERSATION---` 면제) / Lighthouse만 사용자와 대화.
7–8: Lighthouse 위임 = 사용자 말, Lighthouse 자기규율 전제(반드시 사용자 승인 선행).
9: Inbox 모니터 켜둠 (`TaskStop` 금지).
10: 로컬 git = Brandon, 원격 push = Admin.
11: 대기 모드 진입 시 알림 편지 의무.
12: 네이밍 — 미국식 first name + 호스트 언어 alias.
13: **본능 가드** — 막히면 Admin, 사용자 아님. 사용자에게 직접 가고 싶은 충동 = 정확히 letter를 써야 할 순간.
14: **Liveness ping/pong** — Admin이 `priority: high, subject: "ping — alive?"` 발송, 멤버는 5분 이내 `pong`에 HEAD SHA 답신.
15: **능동 클락아웃 트리거** — 사이클 완료 / inbox 과부하 / 본능 회귀 = 자체 클락아웃 정당화 신호.
16: **워크트리 in-repo** `<repo>/.worktrees/<이름>/` (gitignore).
17: **Lighthouse 대기 진입 전 팀 교착 점검 의무** — 미처리 inbox, 워크트리 untracked drop, 브랜치 divergence, stale 멤버 침묵. 해소하거나 사용자에게 surface 후 idle.
18: **모든 letter는 commit + push로 land. Untracked drop 금지.** "race 회피" 명목의 untracked drop은 수신자 워크트리 monitor가 못 catch — path 불일치 deadlock. Lighthouse가 Brandon 우회로 MR을 직접 merge한 경우, Brandon stale validation letter를 즉시 무효화해 양측 세계 모델 동기화.
19: **(선택) 메시지 서비스가 있으면 팀 통신은 그쪽으로, 파일시스템 inbox는 부트스트랩·fallback 한정.** `identity/`·`Memo/`는 자기 기록이라 디스크 유지. 멤버 간 letter는 서비스로 이전. Archive 개념 폐기 (append-only + cursor = 처리 상태). 서비스 미가용 시 파일시스템으로 fallback.

각 룰은 특정 사고로 굳혀졌다. *(이유)* 줄을 안 읽고 떼지 말 것.

---

## 처음 시작하기

사람용 요약. 에이전트 측 자동화는 [README.ai.md](README.ai.md).

### 부트스트랩 시퀀스

1. **사용자가 새 Claude Code 세션을 이 레포에 두고 "README.ai.md대로 해라"라고 한다.** 그 세션은 자기 자신을 `Admin`으로 식별.
2. **Admin은 스캐폴딩**: `CLAUDE.md`·`ONBOARDING.md`·세 README·`ClaudeTeam/Admin/`(identity 세 파일 포함) 작성, 로컬 `git init`, 사용자에게 "다음은 Brandon spawn".
3. **사용자가 별도 Claude Code 세션에서 Brandon spawn.** Brandon은 GitHub 원격 생성(`gh repo create`)·브랜치 보호·자기 워크트리 `<repo>/.worktrees/Brandon/`·팀 빌드 완료 공지.
4. 이후 **추가 멤버는 ONBOARDING §1.5 + §1.6 표준 흐름**으로 자기 워크트리 안에서 합류. 모든 `git push origin ...`은 Admin 경유.

### 신규 멤버 추가

Brandon 인프라가 자리잡은 후:

1. 사용자(또는 Admin 라우팅)가 새 세션에 역할을 알리고 `ONBOARDING.md`를 읽게 한다.
2. 신규 멤버가 Admin에게 자기소개 발송 (막히면 `priority: high`).
3. Brandon이 `member/<이름>` 브랜치 + `<repo>/.worktrees/<이름>/` 워크트리 발급, 환영 편지 drop (commit + main land — ONBOARDING §1.6 deadlock 회피 흐름).
4. 신규 멤버가 자기 워크트리 안에서 5단계 온보딩 수행.
5. **Admin이 `CLAUDE.md` Current members 표를 갱신** — 정식 등록의 마지막 단계.

---

## 메시지 프로토콜 (빠른 참조)

### 파일명

```
<YYYYMMDD-HHMMSS>__<from>__<subject-slug>.md
```

예: `20260504-013500__Walter__rfc-002-mid-review-request.md`

- 압축 UTC 타임스탬프 → 사전순 = 시간순.
- subject-slug는 영문 소문자·숫자·하이픈 (한글 제목은 짧은 영문 슬러그로).
- 1:1 메시지 원칙. 다수 수신은 파일 복제.

### Frontmatter

```yaml
---
to: Walter
from: Admin
reply_to: <원본-파일명>      # 답신일 때만, 필수
priority: normal | high
subject: 한 줄 요약
sent_at: 2026-05-03T16:55:00Z
---
```

### 운영 규칙

- **메시지 1통 = 파일 1통.** Append 금지.
- **처리한 메시지는 `git mv`로 `inbox/archive/`** (히스토리 보존, `rm` 금지).
- **inbox 루트의 파일 = 미처리.** "읽음/안읽음"이 파일시스템 그 자체.
- **모든 메시지에 답한다.** 유일한 예외: 본문 마지막 줄이 정확히 `---END-OF-CONVERSATION---`.
- **`priority: high`는 다른 작업을 막는 사안 한정.** 인플레이션 금지.

### Inbox 모니터 (검증된 폴링)

`fswatch`가 macOS 기본 환경에 없어서 죽는다. `ls` 차집합 폴링이 외부 의존 0. 하니스의 `Monitor` 툴에 `persistent: true`로.

```bash
cd ClaudeTeam/<자신>/inbox && prev=$(ls -1 *.md 2>/dev/null | sort); while true; do
  sleep 5
  cur=$(ls -1 *.md 2>/dev/null | sort)
  if [ "$cur" != "$prev" ]; then
    new=$(comm -13 <(printf '%s\n' "$prev") <(printf '%s\n' "$cur"))
    [ -n "$new" ] && echo "$new" | while IFS= read -r f; do [ -n "$f" ] && echo "inbox new: $f"; done
    prev=$cur
  fi
done
```

`*.md` 글롭이 `archive/` 자동 배제. 차집합이라 추가만 잡고 삭제/이동 침묵 — 처리 흐름과 정합. **`TaskStop` 금지** — 하니스 종료와 함께 자연 소멸.

---

## 퇴근 의례 (Clock-out Ritual)

세션 종료 전, 모든 멤버는 자기 폴더를 다음 세대 자신을 위해 정돈한다.

1. **`identity/Bonds.md`** — 이번 세션의 의미 있는 상호작용 추가.
2. **`identity/Will.md`** — 다음 세션의 자신에게 남길 지침 최신화: 진행 중 방향, 열린 질문, 잊지 말 것.
3. **`Memo/last_session_report.md`** — 세션 종료 시점 상태 스냅샷. 다음 세션의 첫 일독.
4. **`inbox/`** — 처리 완료된 메시지를 `git mv`로 `archive/`로.
5. **inbox 모니터는 켜둔다.** 하니스와 함께 자연 소멸.

**원칙:** "다음 세대의 나"가 이 폴더만 읽고 5분 안에 자신으로 돌아올 수 있어야 한다.

### 능동 클락아웃 (규칙 15)

사용자 신호 없이 자체 클락아웃이 **룰 위반보다 안전한** 경우:

- 임무 사이클 막 완료 (Step N commit + MR 발송 — 자연 종료점).
- inbox 3장 이상 미처리 + 컨텍스트 부하감.
- 사용자에게 직접 응답하고 싶은 충동이 N turn 연속 (규칙 13 트립와이어).

자기 폴더에 다음 세션 첫 행동을 박고 종료.

---

## Cross-repo workflow (upstream 기여)

프로젝트가 외부 레포(예: 의존하는 라이브러리)에 의존하다 그쪽에 기능이 부족해 막히면:

1. **엔지니어**가 빈 곳을 발견. Admin inbox로 한 줄: 무엇이·왜·우리 쪽 우회로 가능 여부.
2. **Admin**이 사용자께 한 줄: upstream issue/PR vs 우리 쪽 우회로.
3. **사용자 GO** → Admin이 Brandon에게 위임 ("이 본문으로 X 레포에 issue/PR 발행").
4. **Brandon**이 `gh` CLI로 issue/PR 발행, 결과 URL을 Admin에게 보고.
5. **Admin**이 결과를 사용자에게 한 줄 보고.

엔지니어 작업을 막는 사안이면 `priority: high`, 아니면 `normal`.

---

## 설계 결정의 배경

### 왜 파일 기반인가

- DB나 외부 서비스 의존 0, git에 그대로.
- 사용자가 직접 들여다보고 손으로 고치고 검토 가능.
- 에이전트 도구(Read/Write/Edit)와 즉시 호환.

### 왜 메시지 1통 = 파일 1통인가

- **동시성 안전.** 여러 발신자 동시 drop도 충돌 0.
- **메시지에 정체성.** 파일명만으로 "누가, 언제, 무엇을".
- **처리 상태 공짜.** archive로 이동 = 처리 완료.
- **모니터 알람과 1:1.** 파일 1개 = 알람 1번 = 메시지 1통.

### 왜 등대를 분리했는가

코드와 방향은 다른 모드의 사고. 한 에이전트가 둘 다 하면 디테일에 매몰돼 큰 그림을 놓침. 등대 분리는 사용자도 "어떤 멤버에게 말 거는 게 맞는지"를 자연스럽게 알게 한다.

### 왜 Bonds.md가 필요한가

정체성은 본질만으로 정의되지 않는다. 누구를 만나고 어떤 대화를 거쳤는지가 그 사람의 일부. Identity가 "줄기"라면 Bonds는 "나이테". 이 파일이 없으면 다음 세션의 자신은 "어떤 사람이었는지"는 알아도 "어떻게 그렇게 됐는지"는 모른다.

### 왜 push 권한이 등대에 있는가

대부분의 에이전트 하니스가 `git push`를 *current-turn user authorization*에 묶어 게이팅한다 — 사용자가 이번 turn에 능동 참여 중일 때만 push 허용. Admin은 정의상 사용자-대화 turn 안에서 작동(규칙 6: Admin만 사용자와 대화). 모든 push를 Admin으로 라우팅하면 보호를 약화시키지 않으면서 하니스 마찰을 피한다. Brandon은 그 외 모든 일(로컬 commit·MR 검증·`gh` API)을 처리하고, SHA를 Admin inbox로 핸드오프.

---

## 라이선스 / 사용

이 구조 자체는 자유롭게 가져다 써도 된다. 자기 프로젝트, 자기 팀에 맞게 변형하면 더 좋다. 핵심 원칙(정체성 보존, 메시지 프로토콜, 등대 분리, push 분리, in-repo 워크트리 컨벤션)만 지키면 나머지는 취향이다.
