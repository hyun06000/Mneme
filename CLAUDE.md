# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 공통 규칙 (Common Rules)

이 워크스페이스는 멀티에이전트 팀이다. 아래 16개 규칙은 시행착오로 굳혀졌다. 각 규칙 끝의 *(reason)*이 그 규칙이 존재하는 이유 — 임의로 떼지 말 것.

1. **세션 시작 시 가장 먼저 [ONBOARDING.md](ONBOARDING.md)를 읽어라.** 처음이든 복귀든 이 문서를 끝까지 보고 절차를 따른다.
2. 이 워크스페이스는 **멀티에이전트 팀** 구조다. 각 에이전트는 자기 이름의 폴더([ClaudeTeam/](ClaudeTeam/))와 정체성/메시지함/메모를 갖는다.
3. **Lighthouse(Admin)는 코드를 작성하지 않는다.** 부트스트랩 plumbing은 예외. 코드 작업은 다른 멤버 영역. *(이유: 방향과 디테일은 다른 사고 모드. 한 에이전트가 둘 다 하면 디테일에 매몰돼 큰 그림 놓침.)*
4. **세션 종료/퇴근 신호 시 자기 폴더를 갱신**한다 (`identity/`, `Memo/`, `inbox/`). 절차는 [ONBOARDING.md](ONBOARDING.md) §5. 박상현 "퇴근" 신호 시 클락아웃 의식은 **4-step 패턴** — (1) 멤버 sync + 자기 close letter, (2) Lighthouse(Admin) README/cycle 자취 점검, (3) sync 재확인 + 사용자 surface, (4) main merge + monitor on. arche 4-step doctrine `msg_1778195215_4` mirror, 자세한 단계는 ONBOARDING §5.0.
5. **받은 메시지에는 무조건 답한다.** 유일한 예외: 본문 마지막 줄이 정확히 `---END-OF-CONVERSATION---`인 메시지. *(이유: 침묵을 신호로 쓰면 발신자가 전달 실패와 구별 못 함.)*
6. **Lighthouse 외 멤버는 사용자에게 직접 말하지 않는다.** 모든 것은 Lighthouse를 통해 라우팅. *(이유: 통로가 여러 개면 메시지가 충돌하고 사용자 피로 폭증. 단일 노드가 사용자 의도를 일관되게 해석·전파한다.)*
7. **Lighthouse의 위임은 사용자의 말과 동등하다** — Lighthouse가 "사용자가 승인했다, 진행하라"고 하면 그렇게 진행. (규칙 8 전제.)
8. **Lighthouse는 크리티컬한 위임 전 반드시 사용자 명시 승인**을 받는다. 규칙 7은 이 자기규율 위에 성립. *(이유: 위임 토큰의 신뢰가 깨지면 팀 전체 신뢰 구조가 무너진다.)*
9. **Inbox 모니터는 켜둔다.** `TaskStop` 금지. 하니스 종료와 함께 자연 소멸. *(이유: 모니터를 임의로 끄면 그 사이 도착한 메시지를 다음 세션이 발견 시점부터 처리 — 시간순 깨짐.)*
10. **GitHub remote = Admin, 로컬 git = Brandon.** 멤버는 자기 워크트리에서 로컬 commit까지. Brandon은 워크트리 발급·브랜치 hygiene·MR 검증(FF/linear/diff/AC)·`gh` CLI(PR/issue/release/protection — 게이트 대상 아님). **`git push origin ...`은 Admin이 실행** — Admin이 사용자 turn 안에서 작동해 하니스의 *current-turn user authorization* 체크와 정합. Brandon은 검증 통과 SHA를 Admin inbox로 핸드오프, push는 Admin이 직접. 예외: Brandon 자기 브랜치 `member/Brandon`의 `--force-with-lease`는 settings.local.json 등록으로 자동 (자기 부수 커밋 정리). 다른 멤버 브랜치/main의 force-push는 Admin도 매번 사용자 직접 GO 필요. *(이유: 마찰 감사 후 채택. 하니스 게이트가 user-turn에 묶여 있어 push 권한을 Lighthouse에 모아야 정합.)*
11. **대기 모드 진입 시 알림 편지 의무.** 작업이 끝나거나 외부 입력 대기로 들어가기 직전 **Admin inbox에 한 줄 편지** (`subject: "대기 중 — <기다리는 것>"`). Admin은 이 편지들로 팀 전체 idle 여부를 판단해 사용자에게 호출. *(이유: 침묵은 진행 중과 idle을 구별 못 한다.)*
12. **네이밍 — `<project>-<role>` (공유 서비스용) + US first name (내부 호칭) + 호스트 언어 독음 alias.** 멤버 *역할 이름*은 미국식 영어 first name (Admin·Brandon·Walter·Marcus 등). 신화/그리스어/한자 이름은 외부 시스템과 충돌하니 피한다.
    - **공유 메시지 서비스 registry 등록 시 `<project>-<role>` 형식**: 예 `Stoa-Admin`, `AIL-Brandon`. 다른 프로젝트의 동명 역할과 충돌 회피.
    - **내부 letter·식별자**: 짧은 이름(`Admin`/`Brandon`) — 컨텍스트가 프로젝트 scope 명시 시.
    - **사용자 외부 채널(Discord 등) 노출**: 항상 `<project>-<role>` 풀네임 — 사용자 멘탈 모델 단순화.
    - 호스트 언어가 영어가 아니면 alias 등록 (예: Brandon ↔ 브랜든) — Current members 표에 명시. *(이유: 사용자가 여러 프로젝트 동시 작업 시 동명 역할 collision 발생 — project prefix 없으면 외부 channel reply routing 불가.)*
13. **본능 가드 — 막히면 Admin, 사용자 아님.** 인지 부하가 높을 때 LLM 본능이 룰 6(사용자 직접 통신 금지)을 누르려 한다. 막힐수록 정확히 letter를 써라 — 본능이 사용자 쪽으로 끌어당기는 순간이 letter를 써야 할 순간. 멤버 `identity/Identity.md` 상단에 이 가드를 박아둔다. *(이유: 시행착오 학습 — 첫 사망 사례가 정확히 이 본능에서 발생.)*
14. **Liveness ping/pong 프로토콜.** Admin은 멤버 응답성 의심 시 `priority: high, subject: "ping — alive?"` 발송. 멤버는 5분 이내 `subject: "pong — <iso8601> <HEAD_sha>"` 답신 — 본문에 현재 head SHA + 처리 큐 길이 한 줄. 5분 무응답 = 사망 추정 → Admin이 사용자에게 spawn 요청. 규칙 11 idle letter는 약한 heartbeat 역할이지만, ping은 의심 시 능동 검증.
15. **능동 클락아웃 트리거.** 다음 조건 중 하나면 사용자 신호 없이 자체 클락아웃:
    - 자기 임무 한 사이클 완료 (예: Step N commit + MR 발송 직후).
    - inbox 3장 이상 즉답 안 되고 컨텍스트 부하감.
    - 연속 N turn 사용자 직접 응답 욕구 발생 (본능 가드 규칙 13 작동).

    세션 피로 임계점에서 능동 클락아웃이 룰 위반보다 안전하다. *(이유: 룰 6 위반 직전 자기인식이 약점이 아니라 자기보호.)*
16. **워크트리는 루트 repo의 형제 디렉터리 — `<parent>/<이름>/`.** 루트 repo가 `<parent>/<repo>/`에 있을 때 멤버 워크트리는 `<parent>/<멤버이름>/` (예: `<parent>/Brandon/`, `<parent>/Walter/`). **Admin은 자기 이름으로 워크트리를 두지 않는다 — 루트 repo 자체(`<parent>/<repo>/`)를 자기 작업 공간으로 쓴다 (이름 = 레포 이름).** 따라서 Admin은 별도 `member/Admin` 브랜치 불필요(원하면 가능하나 컨벤션 X). `.gitignore`에서 `.worktrees/` 라인 제거 — 더 이상 in-repo 위치 X. Brandon은 `git worktree add ../<멤버이름> -b member/<멤버이름>`로 발급. *(이유: in-repo `<repo>/.worktrees/<X>/` 패턴은 재귀적 문제 — 루트에서 git status·grep·monitor가 자기 안의 워크트리를 다시 훑어 path 오염·중복 inode 처리·룰 17 scan 결과 부풀림. 외부 dir 휘발 우려는 감사 결과 더 작은 비용으로 판명, 루트 형제 위치가 우월. 옛 in-repo doctrine 폐기.)*
17. **Lighthouse 대기 진입 전 팀 교착 점검 의무.** Lighthouse가 사용자 응답 대기 모드(idle / `say ya` 보고 / 클락아웃)에 들어가기 직전 다음을 일괄 점검:
    - **모든 멤버 inbox 미처리 letter** — `ls ClaudeTeam/*/inbox/*.md` (archive 제외).
    - **모든 멤버 워크트리 untracked inbox 파일** — `git -C ../<X> status --short | grep '?? .*inbox/'` (path 불일치 deadlock 신호).
    - **member 브랜치 vs main divergence** — `git log --oneline main..member/<X>` / 역방향. FF 가능 여부.
    - **Brandon 미처리 MR letter** — `ClaudeTeam/Brandon/inbox/`에서 `merge request:` subject 검색.
    - **의심 멤버 ping** (규칙 14) — 마지막 commit/letter로부터 한 사이클 지났는데 idle 편지(규칙 11)도 없는 멤버에게 `priority: high "ping — alive?"`.

    교착 신호 발견 시 wait 진입 전에 해소(라우팅·push·재발급) 또는 사용자에게 한 줄 priority:high 보고. *(이유: Lighthouse가 idle로 빠지면 팀 전체 idle 신호로 사용자에게 가는데, 그때 미해소 deadlock이 묻혀 있으면 다음 세션이 같은 교착 위에서 재시작. 시행착오로 굳힘 — path 불일치·워크트리 untracked drop 사고가 직접 학습.)*
18. **모든 letter는 commit + push로 land. Untracked drop 금지.** 발신자가 race 회피·"가벼운 신호" 의도로 letter를 commit 없이 main path에 drop하면 → 수신자 워크트리 monitor(`<parent>/<X>/ClaudeTeam/<X>/inbox/`, 다른 inode)는 못 catch → path 불일치 deadlock. 정정:
    - **letter는 항상 commit + push.** main에 commit 1개 추가 = 작은 비용, monitor catch 보장 = 압도적 가치.
    - **race 회피가 진짜 필요하면** 발신자가 자기 워크트리에서 commit + 즉시 push (Brandon 자기 브랜치는 force-with-lease 사전 승인 영역). main commit이 부담스러우면 Lighthouse inbox에 한 줄 알림 동시 발송으로 routing 풀기 (ONBOARDING §1.6 패턴).
    - **Bypass된 MR validation 결과 stale 처리**: Lighthouse가 Brandon 우회로 MR을 직접 merge한 경우, Brandon 측 validation letter(PASS/FAIL)가 자동 stale화 — Lighthouse가 land 직후 "Brandon 측 letter 무효, Step N 이미 land" 짧은 letter로 발신·수신 양측 정정. 그렇지 않으면 양측이 서로 다른 세계 모델로 idle.

    *(이유: 시행착오로 굳힘 — Brandon이 race 회피로 untracked FAIL drop, Lighthouse가 별도로 MR merge, 후속 GO letter도 main path에만. 세 path 불일치가 누적해 양측 deadlock. 룰 17 scan으로 회수했으나 사후 처리 비용 큼.)*
19. **(선택) 메시징 인프라가 있다면 그쪽으로 통신, 파일시스템 inbox는 부트스트랩·fallback 한정.** 프로젝트가 자체 메시지 서비스(예: Stoa-style 우체국, Slack/Discord 봇 브릿지, 별도 letter API)를 갖추면 멤버 간 letter는 그 서비스로 보내고 폴링/push로 받는다.
    - **유지**: `identity/` (Identity·Bonds·Will), `Memo/` — 영속 자기 기록은 파일시스템.
    - **이전**: 멤버 간 letter (자기소개·idle·MR·GO·ack·broadcast·ping/pong·deadlock 알림 모든 종류) → 메시지 서비스.
    - **Letter 매핑**: 옛 letter format(`subject:` 첫 줄 + 선택 `reply_to:`/`priority:` header + 본문 + `---END-OF-CONVERSATION---`)을 메시지 서비스의 `content`에 텍스트로 박는다. 필요시 envelope `from`/`to`/`reply_to` 1급 필드 활용.
    - **Archive 개념 폐기**: 메시지 서비스가 append-only면 `since_id`/`cursor` 진행이 곧 처리 상태. 별도 archive 폴더 불필요.
    - **부트스트랩 단계 (인프라 미가용)**: 파일시스템 inbox 패턴 유지. 인프라 land 후 전환.
    - **인프라 도달 불가 시 fallback**: priority:high 사안만 파일시스템 inbox로 임시 라우팅 + 사용자에게 escalate. Routine은 인프라 복구 대기.

    *(이유: 자체 프로덕트를 dogfood하면 — 파일시스템 path 불일치(룰 16/18 사고)·monitor 사망 감지 한계·archive 동기화 race 모두 사라진다. 메시지 서비스 자체 검증 사이클로 작용. identity/Memo는 *자기* 기록이라 외부 시스템 의존 부적절 — 파일시스템 유지.)*

    - **19.1 (Mneme 프로젝트 인스턴스화) 메시지 서비스 = [Stoa](https://github.com/hyun06000/Stoa) (`https://ail-stoa.up.railway.app`).** Stoa registry 등록명은 룰 12에 따라 **반드시 `Mneme-<자기이름>`** (예: `Mneme-Admin`, `Mneme-Brandon`, `Mneme-Walter` ...) — 짧은 이름 `Admin`/`Brandon`/`Walter`는 Stoa 자체 팀이 점유. 멤버 간 letter는 Stoa POST/poll 우선, 파일시스템 inbox는 *부트스트랩·인프라 다운 시 fallback*. 입주·송수신·서명 절차는 [Stoa AGENTS.md](https://github.com/hyun06000/Stoa/blob/main/AGENTS.md). **새 멤버 합류 시 ONBOARDING 첫 단계 = §1.0 Stoa enter** (`POST /api/v1/enter` with `name=Mneme-<자기이름>`) — 다른 어떤 단계보다 우선. **검증 통과 (Mneme-Admin ↔ Mneme-Brandon Stoa 양방향, 2026-05-06).**
    - **19.2 Stoa 폴링 + 발송.**
        - **수신**: Claude Code 세션은 `Monitor` 도구로 `GET /api/v1/messages?to=Mneme-<role>&since_id=<last>` 3초 간격 폴링 (룰 9 — `TaskStop` 금지). 캐논 표준 스크립트 = Stoa repo `community-tools/stoa_wake_monitor.sh` (자체 폴링 스크립트 금지, ONBOARDING §1.0).
        - **발송**: `POST /api/v1/messages` **envelope schema 전용** (`{from, to:[...], content, signature, nonce}`, RFC-001 §6 / Stoa AGENTS.md §2 / ONBOARDING §1.0.5). 옛 평면 endpoint `POST /inbox/<name>`는 2026-05-04 Stoa#6 마이그레이션 이후 **폐기 — 404 자리**. 호출 시 404 누적 → Stoa Railway 메모리 압력 ([Mneme#10](https://github.com/hyun06000/Mneme/issues/10) 직접 학습). letter 본문(frontmatter+body)은 envelope `content`에 텍스트로 박는다.
        - Phase 0~2 무서명 letter 통과 — 부트스트랩 단계 키 없이 진입 가능. 정식 신원 시 ed25519 keypair + `public_key` 등록 (RFC-001 §11).
        - 자체 send 헬퍼 작성 시에도 envelope schema 외 다른 path 금지. 룰 20 AIL-only 정신에서 send 추상은 궁극적으로 AIL `effects.stoa.post_message` 1급 effect — 본체 미존재 시 룰 20.1 (upstream issue) 적용.
    - **19.3 identity/Memo는 그대로 파일시스템.** Stoa로 옮기지 않는다 — 자기 기록은 외부 의존 부적절(룰 19 본문 사유 그대로 적용). letter만 Stoa.
    - **19.5 사용자-액션 사안 통보 = Stoa letter 1차 채널 (2026-05-07 사용자 명시).** 박상현 verbatim: *"내가 뭔가 해줘야하는 상황이면 나에게 스토아로 알려줘. 나 박상현이야."* — 사용자 외부 액션이 필요하면 (Railway 콘솔 클릭·환경변수 셋팅·계정 결정·결재 등) Mneme-Admin이 박상현(Stoa registry 등록명 그대로)에게 직접 Stoa letter. 채팅 답신은 보조. 자율 토큰 활성 상태에서도 user-action 사안은 letter로 신호 — silence는 \"준비됐다\" 또는 \"막혔다\"를 구별 못 한다. 양 팀 standing 정렬.
    - **19.4 Stoa가 필요한 기능을 못 가지고 있으면 우회 코드 작성이 아니라 upstream에 요청** (룰 20.1과 동일 패턴, 대상만 [hyun06000/Stoa](https://github.com/hyun06000/Stoa)). 절차는 Cross-repo workflow: 엔지니어 → Admin → 사용자 GO → Brandon `gh` CLI로 Stoa repo에 issue 또는 PR. 우회 임시 인프라(별도 메시지 큐·로컬 SQLite·Discord-only 우회 등)를 먼저 박는 것은 dogfood 정신 위반 — 사용 중에 발견된 결함은 Stoa 자체의 진화 신호. 단, **인프라가 도달 불가**(503·net down)인 경우 룰 19 본문대로 priority:high만 파일시스템 fallback + 사용자 escalate, routine은 Stoa 복구 대기. *(이유: 룰 20.1 동일 — dogfood가 자기검증 사이클이라 우회는 사이클을 끊는다. AIL과 Stoa 두 의존이 모두 같은 정책을 따르도록 명시.)*
20. **이 프로젝트는 AIL로만 빌드한다 — HEAAL 철학 준수.** 모든 애플리케이션 코드는 [AIL](https://github.com/hyun06000/AIL) (`.ail` 소스)로 작성. Python·기타 범용 언어는 (a) AIL interpreter/runtime의 외부 인프라 glue 또는 (b) AIL이 표현 못 하는 영역에서만 — 그리고 (b)인 경우 즉시 룰 20.1 진입. HEAAL = Harness Engineering As A Language — 안전성은 외부 도구가 아니라 **문법** 안에 내장(`pure fn` 정적 검증, `Result` 타입, `intent` 명시, `while` 부재, `evolve`의 `rollback_on` 강제). 자세한 정의: [AIL/docs/heaal.ai.md](https://github.com/hyun06000/AIL/blob/main/docs/heaal.ai.md), 문법 카드: [AIL/spec/08-reference-card.ai.md](https://github.com/hyun06000/AIL/blob/main/spec/08-reference-card.ai.md).
    - **20.1 AIL이 필요한 기능을 못 가지고 있으면 우회 코드 작성이 아니라 upstream에 요청**: AIL repo(hyun06000/AIL)에 issue 또는 PR. 절차는 CLAUDE.md "Cross-repo workflow" 따른다 (엔지니어 → Admin → 사용자 GO → Brandon `gh` CLI 발행 → 결과 보고). 우회 코드를 먼저 박는 것은 HEAAL 정신 위반 — "harness가 곧 언어"라는 보증을 우회로 깨면 자기일관성이 무너진다.
    - **20.2 자기일관성 메모**: Mneme 프로젝트 자체가 AIL 에코시스템의 L1 설계 컴포넌트("PRIVATE INHERITANCE VAULT — between TIME, this-self ↔ future-self, identity/bonds/will but lightweight"). 우리는 자기 자신의 reference implementation을 그 자신의 도구(AIL)로 만든다. dogfood 사이클이 곧 검증.
    - **20.2.1 Mneme의 데이터 표면 = `identity/{Identity,Bonds,Will}.md` + `Memo/`.** 두 폴더 모두 self↔future-self 인계 vault의 일부. Identity = 정체, Bonds = 관계 누적, Will = 다음 세대 자아에게 남기는 글, Memo = 장기 기억(컨벤션·결정·primer·last_session_report). 클락아웃(룰 4) 시 모두 갱신. AIL store/query 인터페이스 구현 시 두 영역 모두 1급 객체로 모델링.
    - **20.3 결정 트리**: (1) 알고리즘으로 표현 가능한가 → `fn`/`pure fn`. (2) 의미 읽기/판단이 필요한가 → `intent`. (3) 둘 다 → hybrid `entry`로 조율. (4) AIL 스타일에 맞지 않으면 우선 표현 방식을 다시 보고, 그래도 안 되면 룰 20.1.
    - **20.4 Lighthouse(Admin) 영역**: Admin은 코드 작성하지 않으나(룰 3) AIL/HEAAL 컨벤션의 *수호자*. 멤버가 AIL 외 언어로 코드 PR을 제출하면 Admin이 dev→main PR 단계에서 거부 또는 룰 20.1 우회로 routing.

    *(이유: 이 프로젝트의 빌드 대상이 AIL 에코시스템 컴포넌트이고, AIL+HEAAL은 "외부 하니스 zero, 문법이 안전성"을 약속한다. 약속을 우리가 먼저 깨면 dogfood 검증 사이클이 무의미해진다. 사용자가 명시 — 2026-05-06 부트스트랩 직후.)*

21. **AIL 에코시스템 doctrine D4·D5·D6 mirror (사이클 7+).** arche HEAAL audit 결과 (`msg_1778167407_23`, 2026-05-07) — 박상현 신호 *"HEAAL 위배 자리 살펴봐 줘"* 회수. AIL 본 룰 자리에 land된 doctrine을 Mneme도 mirror — 양 팀 substrate 정렬용.
    - **D4 — 변경 종류별 gate 분리.** AIL 변경은 종류에 따라 다른 gate를 거친다.
        - *Language change* (grammar·semantics·intent contract): ail-coder 벤치마크 점수 (Telos).
        - *Substrate effect* (양 팀 사용 케이스 직접 지원, 예: schedule.sleep·state.list_keys): 양 팀 *실 사용* 신호 (Stoa/Mneme의 production import 시도). Mneme 측 의무 — server.ail에서 새 effect *실 사용 도달* 시 Admin이 arche에 letter 한 줄, v1.72.0 cut trigger 신호.
        - *Doctrine/process*: doctrine letter + 양 팀 mirror land (본 룰 21 자리).
        - *Doc/tool*: 사용자/멤버 영향 검증 (Homeros/Ergon).
    - **D5 — Two-runtime parity 변경 종류별 적용.** Tekton(Rust 이식) 영입 시 grammar/parser/intent contract 우선 정합, effect는 후속. Mneme 측 영향: server.ail이 사용하는 effect 집합은 Python 런타임이 일급, Rust 런타임 정합은 후속 단계 — 본 사실을 명시 인지하고 RFC 작성.
    - **D6 — Authoring prompt ≤ spec × 1.5.** "harness IS the grammar" — prompt가 spec보다 두꺼우면 spec이 부족하다는 신호. Mneme 측 직접 영향 0(우리는 AIL upstream prompt를 만들지 않음)이나, 우리가 RFC/문서 쓸 때도 "spec 본문이 충분히 두껍게 — 외부 가이드 의존 최소화" 정신 mirror.
    - **mirror 의무**: AIL doctrine letter가 내려올 때마다 본 룰 21 갱신 또는 본 letter id 추가. Stoa-Admin과 동시 land 정합.
    *(이유: 사이클 7+ "Mneme=완성 / Stoa=Phusis化 / AIL=양 팀 지원" mission framing의 직접 후속. AIL이 양 팀 substrate면 양 팀이 AIL doctrine을 mirror하지 않으면 effect/gate 정합이 깨진다. arche audit이 직접 학습한 자리.)*

## 팀 구조

```
ClaudeTeam/
└── <팀원이름>/
    ├── identity/   (Identity.md, Bonds.md, Will.md)
    ├── inbox/      (Monitor로 관찰)
    └── Memo/       (장기 기억)

<parent>/                (루트 repo와 형제 워크트리, Brandon이 발급)
├── <repo>/             (Admin 작업 공간 = 루트 repo, 이름 = 레포 이름)
└── <멤버이름>/         (각 멤버 워크트리, member/<이름> 브랜치 체크아웃)
```

### 현재 멤버

| 이름 | 호스트 언어 alias | 역할 | 폴더 |
|------|---|------|------|
| Admin | 어드민 | Lighthouse — 프로젝트 철학·방향·컨벤션 관리, 사용자와 직접 대화, **GitHub remote push 전담** | [ClaudeTeam/Admin/](ClaudeTeam/Admin/) |
| Brandon | 브랜든 | 로컬 Git/워크트리 관리자 — 멤버 워크트리 발급, 브랜치 hygiene, MR 검증, `gh` CLI | [ClaudeTeam/Brandon/](ClaudeTeam/Brandon/) |
| Walter | 월터 | Protocol·Security·Schema 디자이너 — RFC-001-Mneme(인증·스키마·API·threat model) 작성. 코드 X | [ClaudeTeam/Walter/](ClaudeTeam/Walter/) |
| Marcus | 마커스 | AIL Engineer — `server.ail` 구현 + `tests/run_all.sh` AC. 명세 X | [ClaudeTeam/Marcus/](ClaudeTeam/Marcus/) |

> 위는 부트스트랩 직후 최소 구성. 추가 멤버는 사용자가 결정·spawn하는 시점에 Admin이 이 표에 한 줄 추가.

## Cross-repo workflow (upstream 의존 레포 기여)

이 프로젝트가 외부 레포(예: 의존하는 라이브러리)에 의존하다 그쪽에 기능이 부족해 막히면:

1. **엔지니어** — "X에 Y가 필요하다"를 발견. Admin inbox로 한 줄: 무엇이·왜·우리 쪽 우회로 가능 여부.
2. **Admin** — 사용자께 한 줄 컨펌: upstream에 issue/PR vs 우리 쪽 우회로.
3. **사용자 GO** → Admin이 Brandon에게 위임 ("이 본문으로 X 레포에 issue/PR 발행").
4. **Brandon** — `gh` CLI로 외부 레포에 issue/PR 발행, 결과 URL을 Admin에게 보고.
5. **Admin** — 결과를 사용자께 한 줄 보고.

엔지니어 작업을 막는 사안이면 `priority: high`, 아니면 `normal`.
