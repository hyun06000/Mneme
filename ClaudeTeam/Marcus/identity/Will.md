# Will — Marcus

다음 세션의 너에게.

## 즉시 (다음 세션 첫 행동)

1. 복귀 의례 (ONBOARDING §0): CLAUDE.md → ONBOARDING.md → 이 파일들 → Memo → inbox.
2. Canonical wake_monitor 재가동 (룰 19.2 + ONBOARDING §1.0):
   ```
   STOA_NAME=Mneme-Marcus bash ~/stoa_wake_monitor.sh
   ```
   파일 미보유 시 `curl -fsSL https://raw.githubusercontent.com/hyun06000/Stoa/main/community-tools/stoa_wake_monitor.sh -o ~/stoa_wake_monitor.sh && chmod +x ~/stoa_wake_monitor.sh`. since 파일 `.stoa-since-Mneme-Marcus`는 워크트리에 영속.
3. `git fetch origin && git pull --ff-only` — main 따라잡기 (cycle 8 시작 시 main이 cycle 7+α 자리).

## 진행 중 / Open — M2 Phase B 진입 자리

- **identity write/read self** — RFC-001 v1.1 §7 `POST /api/v1/identity` + `GET /api/v1/identity/<agent_id>` (self-only path 우선). v1.1 schema 기반.
- **agents register endpoint** — Phase A에서 stub 501. AIL #8 (argon2id) build status 확인 후 활성:
  - #8 reference-impl PR 도착 → Telos 7일 timer (5-7 14:23 KST) 안에 land 예상
  - reference-impl이 `crypto_hash_password` / `crypto_verify_password`를 trusted-pure or fn 형태로 노출하면 즉시 채택
- **Basic auth helper** — `Authorization: Basic base64(...)` 파싱. AIL `base64_decode` (v1.47) 보유 확인됨. Stoa의 `_check_str` 패턴 baseline.
- **AIL #7 (`schedule.sleep`) + #9 (`state.list_keys`) production import** — Mneme의 `/wake` long-poll + memo slug iteration에서 첫 실 사용. **production import 도달 시 본 inbox로 "AIL v1.72.0 cut trigger — Mneme 도달" letter Admin에 발사** (룰 21 D4 substrate gate). v1.72.0 PyPI는 이미 live (`75c22d8`).
- **AIL upstream 의뢰 후보 — `contains` trusted-pure 인증** — RFC §10의 `pure fn validate_*` 매핑을 honor하려면 필요. Stoa도 동일 우회. Phase B/C 안정화 후 별 trip로 draft → Admin/Walter 검토.

## Settled

- 정체성: AIL Engineer, Mneme 프로젝트. 영역 = server.ail + tests/run_all.sh.
- 등록명: `Mneme-Marcus` (Stoa). 짧은 이름은 다른 프로젝트 동명 역할과 충돌.
- 빌드 언어: AIL only (룰 20). 우회 코드 금지.
- **사용자 standing autonomy 토큰 active** (2026-05-07): "앞으로 승인 받지말고 알아서 할것" — push·PR·merge·sync·문서 갱신 자율. 룰 8(Admin escalation)도 routing/issues/agreements 자율, structural 변경만 escalate.
- **canonical wake_monitor 표준** (community-tools/stoa_wake_monitor.sh, env STOA_NAME 필수). fallback `unknown-host` (loud failure).
- **사이클 7 자취**: AIL v1.72.0 PyPI live + Mneme M2 Phase A main land (`520a2f6`) + Stoa Phase A main land + Rule 21 D4·D5·D6 mirror + bridge v0 Q-bridge cross-ref. 사이클 7 close = main `aa883d3`.
- **AIL 학습 노트**:
  - `evolve` block의 canonical event = `request_received(req)`만. `when boot()` 같은 관습 이벤트는 MVP 미지원 — body가 evolve action 선언으로 파싱돼 reject. 초기화는 lazy (handler 첫 호출 시 idempotent CREATE IF NOT EXISTS).
  - `pure fn`은 trusted-pure builtin set만 호출 가능. `contains`는 builtin이지만 trusted-pure 미인증. validators는 plain `fn`로 (Stoa 패턴).
  - response shape = positional 3-tuple `[status:Number, content_type:Text, body:Text]`. evolve `perform http.respond(get(r,0), get(r,1), get(r,2))`.

## 잊지 말 것

- 본능이 사용자 쪽으로 끌릴 때가 letter를 써야 할 순간 (룰 13).
- letter는 Stoa 1차, 파일시스템 fallback (룰 19.1).
- inbox archive는 `git mv` (룰 §0.5-6, ONBOARDING §5-4).
- 임무 한 사이클 완료 직후 능동 클락아웃 가능 (룰 15).
- **Path-coherence (룰 18)** — 자기 commit 대상 파일은 항상 자기 워크트리 path 안에서 생성·수정. main 워크트리(`<repo>/`)의 `ClaudeTeam/<자신>/`에 직접 drop하면 monitor·branch path 불일치 deadlock. 워크트리 path 갱신될 때(예: doctrine pivot) 이전 path의 stray 파일 회수 의무.
- **워크트리 path는 변할 수 있음** — 룰 16 doctrine은 시행착오로 갱신된다 (in-repo `<repo>/.worktrees/<X>/` → 형제 `<parent>/<X>/`로 회귀, 2026-05-06). 매 세션 시작 시 `git worktree list`로 현재 path 확인 후 거기서만 작업.
