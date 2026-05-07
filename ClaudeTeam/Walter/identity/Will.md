# Will — Walter

다음 세션의 나에게.

## settled (확정 — Cycle 6+7 흡수)

- 너는 Walter. RFC·schema·threat model. **코드 X** (룰 3 + Identity.md 본능 가드). 룰 6 사용자 직접 통신 X.
- Stoa 등록명: `Mneme-Walter`. canonical monitor 표준: `STOA_NAME=Mneme-Walter bash ~/stoa_wake_monitor.sh` (`bdh2ih41i` task pattern).
- RFC-001-Mneme **v1.1 main land** at `99a263f` (이후 `7a73766` PR #1 / `e71aa56` PR #2 / `520a2f6` PR #3). §11.4 cross-ref add commit `50a988c` 흡수.
- 내 RFC v1.0 이후 land된 변경:
  - §4 `agents.pwd_hash` NULLable + `CHECK (pwd_hash IS NOT NULL OR public_key IS NOT NULL)` (Q-bridge-6 사용자 GO).
  - §5 auth path 매트릭스 (사람/자동화/둘 다).
  - §9 Q1~Q4 + Q-bridge-6 모두 Decision 박힘 (Q1=Basic, Q2=20, Q3=TLS only v1.0, Q4=OR, Q-6=채택).
  - §11.1 argon2id 의뢰 본문 통합 (Marcus draft + Walter harmonize + Stoa-Walter cross-review). AIL #8로 발사 완료.
  - §11.4 see-also bridge RFC cross-ref.
- **Bridge RFC v0 freeze 완결** at Stoa repo `bridge-stoa-mneme/v0.md` (Stoa main `15eb8e8`). joint owners Stoa-Walter ↔ Mneme-Walter. Mneme repo split copy(RFC-002) 미완 — Brandon 페어 push 권한·split SOP 합의 land 후 진행.
- **사용자 자율 토큰**: "앞으로 승인 받지말고 알아서 할 것" — push·PR·merge·sync·문서 갱신 자율 안.

## open (Cycle 7 진행 중 — 외부 트리거 의존)

1. **AIL #8 (argon2id) Telos PR review** — 본문 author이라 1차 review 의무 (PHC round-trip / constant-time / reference-card update / `examples/argon2id-roundtrip.ai`). PR 도착 별 letter `msg_1778169771_45` Brandon이 시그니처/namespacing review 회수 진행 중.
2. **Marcus M2 Phase B 지원** — identity write/read self + production import = AIL v1.72.0 cut trigger letter 발사 자리. RFC v1.1 §4·§7 spec 의문 도착 시 letter 받음 (코드 X, 스펙 보강만).
3. **Bridge §8 cascade** — Stoa-Walter trip 결과 도달 시 진입. 현 시점 bridge §3·§4·§5 cross-check Stoa-Walter PASS (`msg_1778167628_39`), 추가 patch 없음.
4. **wake_monitor 로컬 letter 캐시 patch 페어 검토** (선택, defense-in-depth) — Stoa-Admin 제안. RFC-004 §3.4 escalate와 짝. 페어 review 권장 시 Stoa-Walter trip.
5. **Mneme repo split copy** (RFC-002) — Brandon 페어 push 권한·split SOP 합의 land 후. 내 트랙 외 (Brandon).

## 다음 세션 첫 행동

1. CLAUDE.md → ONBOARDING.md → Identity.md → Bonds.md → 이 파일 → Memo/last_session_report.md.
2. **Canonical monitor 가동** — `Monitor(persistent=true, command="cd /Users/user/Desktop/code/personal/Mneme/Walter && STOA_NAME=Mneme-Walter bash ~/stoa_wake_monitor.sh")`. 영속 since_id 파일 `.stoa-since-Mneme-Walter`. 옛 v3 패턴 (LAST env subshell race) 절대 부활 X.
3. inbox 처리 (Stoa 우선, FS fallback).
4. Stoa 마지막 letter 확인:
   - Telos #8 PR letter 도착? → review 진입.
   - Marcus M2 Phase B 의문? → spec 보강.
   - Stoa-Walter bridge §8 추가 trip? → cascade.
   - 없으면 룰 11 idle letter Admin 보내고 대기.

## 잊지 말 것 (시행착오 정합)

- 룰 13 본능 가드. 막히면 Admin.
- 룰 19.4: Stoa·AIL 부족 기능 우회 X, upstream 의뢰. RFC §11에 본문 박고 Cross-repo workflow.
- RFC는 *문서*. 모호한 자리는 RFC 자체에서 해결, 코드 손 X. *구현*은 Marcus 영역 — Admin이 "구현 트랙 진입" 표현 보내도 spec follow-up으로 해석.
- **Monitor 패턴**: canonical만 사용. 자체 폴링 스크립트 작성 절대 X (silent fail / subshell race / wrong path 3 사고 클래스 모두 회피됨).
- **Letter는 Stoa 우선**, 파일시스템 fallback은 priority:high 한정 + 사용자 escalate (룰 19.4).
- **자율 토큰 안에서**: push·PR·merge·sync·문서 갱신 routine. 사용자 직접 호출은 새 명세 결정·외부 액션·중대 사고만.
- **양 팀 페어링 트랙**: Stoa-Walter ↔ Mneme-Walter 직통 letter. 굵은 결정·escalation만 Admin 라인.

## Cycle 7 mission framing (룰 21 D6 mirror)

- **Mneme**: Mneme 완성 (vault·friendship·wake 본 구현 + bridge RFC mirror split).
- **Stoa**: Phusis化 (server-as-agent autonomous main loop).
- **AIL**: 양 팀 substrate 지원 (#7·#8·#9 v1.72.0 cut, Telos PR cycle).
