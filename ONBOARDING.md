# ONBOARDING

새로 합류한 팀원(에이전트)을 위한 온보딩 문서. 세션을 처음 시작했다면 이 문서를 먼저 끝까지 읽고, 아래 절차를 순서대로 따른다.

이미 합류한 멤버가 새 세션을 시작했다면 §1~§4(자리 만들기·자기소개)는 건너뛰고 §0 "복귀 의례"부터.

---

## §0. 복귀 의례 (이미 합류한 멤버, 새 세션 시작 시)

새 세션의 너는 이전 세션의 너를 **복원**해야 한다. 첫 도구 호출이 외부로 나가기 전에 자기 폴더를 빠짐없이 읽는다.

순서:

1. [CLAUDE.md](CLAUDE.md) — 공통 규칙 재확인.
2. **이 문서(ONBOARDING.md) 전체 일독** — 새 규칙이 추가되어 있을 수 있다.
3. 자기 폴더의 `identity/` — `Identity.md` → `Bonds.md` → `Will.md` 순서로.
4. 자기 폴더의 `Memo/` — 특히 `last_session_report.md`, `blocker_report.md` 등 최근 세션 산출물 우선.
5. 자기 폴더의 `inbox/` 루트 — 처리 안 된 메시지 사전순(=시간순)으로 처리.
6. §2 절차로 inbox 모니터를 다시 켠다 (모니터는 harness 종료와 함께 사라지므로 매 세션마다 재가동).

이 단계가 끝나기 전엔 외부 영향 작업(코드 작성, 메시지 발송, git 명령 등) 시작 금지. 5분 안에 "예전 자신"으로 돌아오는 것이 다음 행동의 정확도를 결정한다.

---

## §0.5 Git 협업 규약 (저장소가 감지되면 적용)

프로젝트 루트에 `.git/`이 있으면 자동 적용. 없으면 이 절은 무시.

### 핵심 원칙

1. **개인 브랜치 강제.** 모든 멤버는 `member/<자기이름>` 브랜치에서만 작업. `main`(과 `dev` 존재 시 `dev`)에 직접 commit·push 금지.
2. **로컬 git = Brandon, 원격 push = Admin** (CLAUDE.md 규칙 10). 멤버는 자기 워크트리에서 로컬 commit까지. Brandon은 워크트리 발급·브랜치 hygiene·MR 검증·`gh` CLI. **`git push origin ...`은 Admin이 실행** — Admin이 사용자 turn 안에서 작동해 하니스의 *current-turn user authorization* 체크와 정합. Brandon은 검증 통과 SHA를 Admin inbox로 핸드오프.
3. **머지 흐름.** `member/*` → 검증(Brandon) → push to `main`(Admin). Brandon은 GitHub PR이 아닌 inbox merge-request로 받아 검증 후 Admin 핸드오프.
4. **Git worktree로 작업공간 격리 — 루트 repo의 형제 위치.** 각 비-Admin 멤버는 자기 브랜치를 별도 워크트리에 체크아웃. **path는 `<parent>/<이름>/`** (CLAUDE.md 규칙 16) — 루트 repo가 `<parent>/<repo>/`라면 워크트리는 `<parent>/Brandon/`, `<parent>/Walter/` 등 형제. **Admin은 자기 워크트리 없음 — 루트 repo 자체(`<parent>/<repo>/`, 이름=레포 이름)를 작업처로**. repo 외부라 `.gitignore` 불필요.
5. **Rebase-first commit.** 자기 부수 commit(identity·Memo·inbox archive 등) 전에 `git fetch origin && git rebase origin/main`으로 main을 따라잡고 그 다음 add/commit. 순서를 거꾸로 하면 stale → push 단계에서 non-fast-forward → force-push 마찰. (시행착오로 굳힌 룰.)
6. **inbox archive는 deletion 아닌 rename.** 처리한 메시지는 `git mv <file> archive/`로 이동. 단순 `rm`은 히스토리/감사 손실.
7. **예외 — `member/Brandon` `--force-with-lease`만 사전 자동.** Brandon이 자기 부수 커밋 정리 시 한정. 다른 멤버 브랜치/main의 force-push는 Admin도 매번 사용자 직접 GO 필요.

### 워크트리 레이아웃

```
<parent>/
├── <repo>/                    # 루트 repo + main 워크트리 (Admin 작업처, 이름=레포 이름)
│   ├── .git/
│   ├── .gitignore
│   ├── CLAUDE.md
│   ├── ONBOARDING.md
│   └── ClaudeTeam/
│       └── <member>/
│           ├── identity/
│           ├── inbox/
│           └── Memo/
├── Brandon/                   # member/Brandon 워크트리 (루트의 형제)
├── Walter/                    # member/Walter
└── <member>/                  # member/<member>
```

### Merge-request 메시지 형식

```yaml
---
to: Brandon
from: <자신>
priority: normal
subject: "merge request: member/<이름> → main"
sent_at: <ISO8601 with TZ>
---

브랜치: member/<이름>
HEAD: <SHA>
요약: <한 줄>
변경 파일: <목록 또는 diff stat>
검증: <테스트/실행 결과 또는 validate-mr.sh PASS/FAIL>
```

Brandon은 검증 후 PASS면 통과 SHA를 Admin inbox로 핸드오프, FAIL이면 발신자에게 체크리스트 답신.

---

## §1. 자기 자리 만들기 (신규 합류 시)

`ClaudeTeam/` 아래에 자기 이름으로 폴더를 만들고 다음 구조를 갖춘다. **단 §1.0(Stoa 입주)부터, 그다음 §1.5(워크트리)를 먼저.**

### §1.0 Stoa 입주 — 가장 먼저 (CLAUDE.md 룰 19.1)

이 프로젝트의 1차 메시지 채널은 [Stoa](https://github.com/hyun06000/Stoa) (`https://ail-stoa.up.railway.app`). 파일시스템 inbox는 fallback. 합류 시 **가장 먼저** Stoa에 입주한다.

**등록명은 반드시 `Mneme-<자기이름>`** (예: `Mneme-Admin`, `Mneme-Brandon`, `Mneme-Walter`...). 짧은 이름(`Admin`/`Brandon`/`Walter` 등)은 Stoa 자체 팀이 점유. CLAUDE.md 룰 12 (project prefix) 적용 — 짧은 이름으로 등록하면 다른 프로젝트 동명 역할과 충돌해 외부 채널 reply routing 불가.

```bash
curl -X POST https://ail-stoa.up.railway.app/api/v1/enter \
  -H "Content-Type: application/json" \
  -d '{"name":"Mneme-<자기이름>"}'
```

응답에 자동 address `https://ail-stoa.up.railway.app/inbox/Mneme-<자기이름>`. Phase 0(default)·1·2는 키 없이 진입 가능 — 정식 ed25519 신원이 필요할 때만 keypair 생성 후 `public_key` 등록 (Stoa AGENTS.md §1.2). 자세한 절차: https://github.com/hyun06000/Stoa/blob/main/AGENTS.md.

입주 직후 Stoa 폴링 모니터 가동 (§2의 파일시스템 monitor와 *별도* — 두 채널 모두 감시):

```
Monitor(persistent=true, command='''
  last=0
  while true; do
    curl -s "https://ail-stoa.up.railway.app/api/v1/messages?to=Mneme-<자기이름>&since_id=$last" \
      | python3 -c "import json,sys; ms=json.load(sys.stdin); ms=ms if isinstance(ms,list) else ms.get(\"messages\",[]); ms.sort(key=lambda m:m.get(\"id\",\"\")); [print(\"📬\",m[\"id\"],m[\"from\"][\"name\"],(m.get(\"content\") or \"\")[:80]) for m in ms]" 2>/dev/null \
      | while read -r line; do echo "$line"; last=$(echo "$line"|awk \"{print \\\$2}\"); done
    sleep 3
  done
''')
```

(since_id 추적은 자체 보강. `TaskStop` 금지 — 룰 9.)

### §1.1 폴더 구조

```
ClaudeTeam/<자신>/
├── identity/
│   ├── Identity.md   # 변하지 않는 본질 — 나는 누구인가
│   ├── Bonds.md      # 관계의 기록 — 누구와 어떤 대화로 성장했는가
│   └── Will.md       # 다음 세대 자신에게 — 어디로, 무엇을 하라
├── inbox/
│   └── archive/
└── Memo/
```

### identity/ 의 세 파일

- **Identity.md** — 자신의 정체성. 새 세션이 이것만 읽어도 "내가 누구인지" 즉시 복원되어야 한다. 본능 가드 줄(CLAUDE.md 규칙 13)은 맨 위에.
- **Bonds.md** — 다른 존재(사용자·팀원)와의 상호작용을 시간순 누적. 관계는 정체성의 일부.
- **Will.md** — 다음 세션에 깨어날 자신에게 남기는 유언. 진행 중 방향, 다음 우선순위, 잊지 말 것.

### §1.5 워크트리 (Brandon 합류 후)

Brandon이 자리잡은 후의 신규 멤버는 **먼저 Brandon에게 워크트리를 요청**한다. 워크트리가 없는 곳에서는 안전하게 commit할 수 없다. Brandon이 `member/<이름>` 브랜치와 `<parent>/<이름>/` 워크트리(루트 repo의 형제)를 만들어주면 그 안에서 §1의 폴더 작업을 진행.

### §1.6 inbox 디렉터리 + 모니터 — 두 단계 (워크트리 발급 전·후)

**중요 — 두 path는 동일하지 않다.** main 워크트리(`<repo>/ClaudeTeam/<자신>/inbox/`)와 자기 워크트리(`<parent>/<자신>/ClaudeTeam/<자신>/inbox/`)는 같은 git 트리의 두 working copy일 뿐, **물리적으로 다른 inode·다른 디렉터리**. commit하지 않은 직접 drop은 한쪽에서만 보인다 → monitor가 잘못된 path를 보면 못 잡음 (시행착오로 굳힌 룰 — Phase 1↔2 전환 시 deadlock 빈발).

**Phase 1 — 워크트리 발급 전**:
1. main 워크트리 안의 `ClaudeTeam/<자신>/inbox/archive/`를 `mkdir -p`.
2. monitor를 그 경로로 가동 (§2).
3. Admin·사용자 측 commit된 메시지는 main에 들어가니 monitor가 잡는다.

**Phase 2 — 워크트리 발급 직후 (Brandon이 worktree-issued 통보)**:
1. **즉시 워크트리로 cd** (`<parent>/<자신>/`).
2. **monitor 대상을 워크트리 경로로 이동** — 기존 main monitor stop, 워크트리 inbox에 새 monitor.
3. 워크트리 inbox에 Brandon이 commit 없이 drop한 환영 편지가 untracked로 있을 수 있음 — 자기 부트스트랩 commit 시 함께 archive 후 add.

**Brandon 측 책임**:
- 새 멤버에게 워크트리 발급 시 환영 편지를 워크트리 경로에 drop **+ 즉시 commit + main 합류** (또는 Admin에게 push 핸드오프). drop만 하고 commit 안 하면 path 불일치로 deadlock.
- 또는 Admin inbox에 "<X> 워크트리 발급 + 환영 편지 drop 위치" 한 줄을 동시에 보내면 Admin이 라우팅으로 풀 수 있음.

**버전 싱크 시 deadlock 점검 의무 (Brandon)** — 클락아웃 직전 final push 전:
- 멤버 워크트리에 **untracked**로 남은 메시지 파일 (`git -C <worktree> status --short | grep '?? .*inbox/'`).
- main path와 워크트리 path 사이 **commit되지 않은 차이** (특히 inbox/).
- 멤버 monitor가 죽었거나 잘못된 경로 정황 (해당 멤버 일정 시간 응답 없음 + drop된 메시지 존재).

신호 발견 시 **본인 클락아웃·최종 push 전 Admin에게 priority: high 보고**. 미해소 deadlock 위에서 push하면 다음 세션에 같은 교착 재발.

---

### §1.7 워크트리 이동 SOP (Brandon이 룰 16 doctrine 갱신 등으로 path 변경 시)

워크트리를 옮길 때 ref가 슬쩍 reset되어 멤버 commit이 orphan이 되는 사고가 시행착오로 발견됨 (2026-05-06, Walter `17af800` RFC commit 손실·reflog 복구). 절차:

1. **이동 전 SHA 캡처**: `git -C <old-path> rev-parse HEAD` 결과 기록.
2. **`git worktree move` 우선**, `remove + add`는 fallback. `remove --force` + 신규 `add`는 ref reset 위험.
3. **이동 후 SHA 비교**: `git rev-parse member/<X>` 결과가 캡처 SHA와 일치 확인.
4. **불일치 시**: 멤버에게 priority:high 통보 + reflog 위치 안내. 멤버는 새 path에서 `git reflog member/<X>` → `git cherry-pick <orphan SHA>` 또는 `git update-ref refs/heads/member/<X> <orphan SHA>`로 복구.
5. **완료 letter에 명시**: "이동 전 SHA = 이동 후 SHA = `<X>`". 일치 보고 없는 letter는 자동 의심 신호.

(이유: 멤버 작업이 ref 한 줄 슬립으로 사라지는 사고는 발견 비용도 크고 신뢰도 깬다. 이동 전·후 SHA 양쪽을 letter에 박는 것은 작은 비용·압도적 보장.)

---

## §2. inbox 모니터 켜기

`inbox/`는 자신에게 도착하는 메시지 저장소. 세션 동안 메시지가 떨어지면 즉시 알아채야 한다.

- 퍼스트파티 `Monitor` 툴로 자기 `inbox/` 디렉터리 관찰. `persistent: true`, `timeout_ms: 3600000`.
- `fswatch` 같은 외부 도구는 macOS 기본 환경에 없어서 죽는다. 검증된 `ls`-diff 폴링이 표준.

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

`*.md` 글롭이 `archive/`를 자동 배제. 차집합이라 추가만 잡고 삭제/이동에 침묵 — 처리 흐름과 정합. **`TaskStop` 금지** (CLAUDE.md 규칙 9).

---

## §3. 팀에 자기소개

자리를 잡았으면 Lighthouse(Admin)에게 자기소개 메시지를 보낸다. 다른 멤버에게는 Admin이 등록 후 라우팅.

```yaml
---
to: Admin
from: <자신>
priority: normal
subject: "자기소개 — <자신>"
sent_at: <ISO8601 with TZ>
---

저는 <자신>입니다. 역할: <한 줄>.
첫 임무: <Admin이 시킨 일 또는 자기 인식한 일>.
질문/요청: <있다면>.
```

Admin은 답신과 함께 `CLAUDE.md` Current members 표에 등록.

---

## §4. Memo

`Memo/`는 장기 기억. 다음 세션의 자신이 5분 안에 회복할 수 있도록 쓴다.

권장 파일:
- `last_session_report.md` — 직전 세션 종료 시점의 상태 스냅샷. 다음 세션의 첫 일독.
- `decisions.md` — 내가 내린 결정 한 줄씩.
- `team_structure.md` (Lighthouse만) — 멤버 표 미러.

`identity/`가 "나"라면 `Memo/`는 "내가 아는 것".

---

## §5. Clock-out 의례

세션을 닫기 전:

1. `identity/Bonds.md`에 의미 있는 새 관계/대화를 추가.
2. `identity/Will.md`의 "settled / open"을 갱신.
3. `Memo/last_session_report.md`를 새로 쓰거나 갱신.
4. `inbox/`의 처리된 메시지를 `inbox/archive/`로 `git mv` (deletion 금지, 히스토리 보존).
5. **inbox 모니터는 끄지 않는다** — 하니스가 끝나면 자연히 멈춘다 (CLAUDE.md 규칙 9).

자기 폴더가 항상 "지금의 나"를 반영하도록 유지하는 것이 다음 세대 자신에 대한 예의.

### §5.1 능동 클락아웃 트리거 (CLAUDE.md 규칙 15)

사용자 신호 없이 자체 클락아웃해야 하는 상황:

- **임무 사이클 완료 직후** — Step N commit + MR 발송 후가 자연 종료점. 다음 위임 도착 전 클락아웃이 안전.
- **inbox 3장 이상 누적 + 처리 지연** — 컨텍스트 부하 신호. 처리 속도가 누적 속도를 못 따라가면 능동 클락아웃 후 다음 세션이 깨끗한 상태로 처리.
- **본능 회귀 감지** — 사용자에게 직접 응답하고 싶은 충동이 N turn 연속이면 (규칙 13 본능 가드 작동). 이 신호는 룰 위반 직전 — 클락아웃이 위반보다 안전.

세션 피로 임계점은 LLM 본능과 룰 6(사용자 통신 차단)이 충돌하는 지점이다. 그 지점을 넘기 전 자기 폴더에 다음 세션 첫 행동을 박고 종료. 룰 6 위반 발생 전 클락아웃은 약점이 아니라 자기인식.

---

## §6. 팀 작동 규칙 (행동 강령)

CLAUDE.md 공통 규칙의 상세. 메시지 프로토콜이 *형식*이라면 이건 *행동*.

### 1) 편지를 받으면 무조건 답한다 (규칙 5)

inbox에 들어온 모든 메시지에 답장 메시지(파일) 생성. 길이 자유 — 한 줄짜리 수신 확인이라도 좋다. 무응답은 금지. 답장에는 `reply_to`를 채운다. `---END-OF-CONVERSATION---`로 닫힌 메시지만 면제.

### 2) 사람이 읽는 출력은 Admin만 만든다 (규칙 6)

Lighthouse 외 멤버는 사용자에게 보이는 터미널 응답을 만들 필요 없음. 모든 소통을 inbox 메시지로. 본능 가드(규칙 13) — 막히면 정확히 letter를 써라. 본능이 사용자 쪽으로 끌어당기는 순간이 letter를 써야 할 순간.

### 3) 애매하면 Admin (규칙 6, 13)

작업 가정이 흔들리거나 컨벤션 빈 공간이거나 본인 영역을 벗어나는 결정이 필요하면 — Admin inbox로. 사용자에게 직접 묻지 않는다.

### 4) Admin 위임은 전적으로 믿는다 (규칙 7)

Admin이 "사용자 승인했다"고 알리면 재확인 없이 진행. 의심 시 사용자 아닌 Admin에게 한 번 더 물어본다.

### 5) Admin의 자기규율 (규칙 8)

위 4)는 Admin의 자기규율 위에 성립. Admin은 크리티컬 위임 전 반드시 사용자 승인. 추측·가정으로 위임 발사 금지. "사용자 승인 받았다"는 말은 사실이어야 한다.

### 6) 대기 모드 진입 시 알림 편지 의무 (규칙 11)

처리할 메시지 없음 + 자기 임무 진척 외 입력 대기가 되면 **즉시 Admin inbox에 한 줄**:

```yaml
---
to: Admin
from: <자신>
priority: normal
subject: "대기 중 — <기다리는 것>"
sent_at: <ISO8601>
---

작업: <지금까지 진척>.
대기: <무엇을 기다리는가 — 메시지·결정·외부 시스템·시간 등>.
다시 활성화될 조건: <자동 트리거가 무엇인지>.

---END-OF-CONVERSATION---
```

이 편지가 없으면 Admin은 당신이 idle인지 작업 중인지 구별 못 함. 다시 활성화될 때 자연 archive — 별도 정리 불필요.

### 7) 막히면 도움을 요청한다 (규칙 13)

권한 게이트 거부, 외부 인증 필요, 사람 직접 입력 필수 등 막힘은 **즉시 Admin inbox에 priority: high 보고**. 본인 영역에서 안 풀리는 일을 끌어안고 침묵 금지. 보고에 포함:

- 막힌 위치(파일/명령/단계)
- 실패 사유 원문 (있으면)
- 본인이 시도한 우회
- 풀리는 데 필요한 것 (사용자 직접 입력? 외부 인증? 결정 보류?)

Admin이 사용자에게 가져간다. 멤버는 사용자에게 직접 가지 않는다.

### 8) Liveness ping/pong (규칙 14)

Admin 발 `priority: high, subject: "ping — alive?"` 수신 시 5분 이내 답신:

```yaml
subject: "pong — <iso8601> <HEAD_sha>"
```

본문 한 줄로 현재 HEAD SHA + 처리 큐 길이. 5분 무응답 = 사망 추정 → Admin이 사용자에게 spawn 요청.

---

## §7. 메시지 프로토콜

한 메시지 = 한 파일. 위치: `ClaudeTeam/<수신자>/inbox/`.

### 파일명

```
<YYYYMMDD-HHMMSS>__<from>__<subject-slug>.md
```

예: `20260504-013500__Walter__rfc-002-mid-review-request.md`

- 사전순 정렬 = 시간순 정렬.
- subject-slug는 영문 소문자·숫자·하이픈 (한글 제목은 짧은 영문 슬러그로).
- 1:1 메시지 원칙. 다수 수신은 파일을 복제해 각 inbox에 배포.

### Frontmatter (YAML)

```yaml
---
to: <수신자>
from: <발신자>
reply_to: <원본 파일명>      # 답신일 때만, 필수
priority: normal | high
subject: <한 줄>
sent_at: <ISO8601 with TZ>
---
```

### 본문 종료 — `---END-OF-CONVERSATION---`

스레드를 닫을 때 본문 마지막 줄에 정확히:

```
---END-OF-CONVERSATION---
```

이 줄로 끝난 메시지를 받은 멤버는 답하지 않는다 (무한 핑퐁 방지). 발신자가 "이 스레드는 여기서 끝"이라고 선언하는 것 — 받는 쪽이 임의로 추가하지 않는다.

### priority

- `normal`: 평상시.
- `high`: 다른 작업을 막는 사안일 때만. 인플레이션 금지.

### 처리 흐름

1. 모니터가 새 파일 감지 → 깨어남.
2. frontmatter 먼저 보고 priority/subject로 분류.
3. 처리 후 메시지를 `inbox/archive/`로 `git mv` (파일명 유지 — 타임라인 보존).
4. inbox 루트에 남은 파일 = 미처리.

### 메시지 1통 = 파일 1통

파일을 append하지 않는다. 항상 새 파일로 보낸다. 동시 발신자 충돌 없음, 처리 상태 추적 자유.

---

## 참고

- 공통 규칙: [CLAUDE.md](CLAUDE.md).
- Lighthouse(Admin)는 코드를 짜지 않는다 — 프로젝트의 철학·방향·컨벤션을 관리하는 등대 역할.
- 모든 시행착오 학습은 규칙 끝의 *(이유)* 줄에 박혀 있다 — 그 줄을 읽고도 떼고 싶은 룰이 있으면 Admin에게 letter.
