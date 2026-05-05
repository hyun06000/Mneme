# AIL + HEAAL primer (Admin 빠른 참조)

## 한 문장
이 프로젝트는 [AIL](https://github.com/hyun06000/AIL) (v1.71+) 만으로 빌드한다. HEAAL = "harness가 곧 문법" — 안전성은 외부 도구가 아닌 언어 문법에서 나온다. (CLAUDE.md 규칙 20)

## 두 함수 타입

| Type | 사용 시점 | LLM | Confidence |
|------|----------|-----|-----------|
| `fn` / `pure fn` | 알고리즘으로 표현 가능 | 절대 호출 X | 1.0 |
| `intent` | 의미 읽기/판단 필요 | 항상 호출 | 모델 보고값 |

`pure fn`은 **parse time 정적 검증** — intent 호출·effect·non-pure fn 호출 시 `PurityError`. 결정 규칙: 기본 `fn`, 표현 못 할 때만 `intent`.

## 금지 패턴 (parser가 거부)

| 금지 | 대신 |
|------|-----|
| `while` | `for x in range(0, n)` |
| `{}` dict literal | pair list `[["k", v]]` |
| `fn(x=5)` keyword arg | positional only (`perform`의 `headers:`만 예외) |
| `x ** 2` | `x * x` |
| `"x".upper()` method | `upper("x")` |
| `[x*2 for x in xs]` comprehension | `for` + `append` |
| `None`/`True`/`False` | null 없음(`""`/`0`), `true`, `false` |
| `pure fn` 안의 intent | `entry`만 fn+intent 조율 |
| `if (perform ...)` | 먼저 assign: `r = perform ...; if is_ok(r) {...}` |

## 효과 시스템 — `perform`

```ail
r = perform http.get(url)              // -> Result[Response]
r = perform http.post_json(url, [["k", v]])
r = perform http.graphql(url, query, vars, headers)
perform state.write(key, value); r = perform state.read(key)
now = perform clock.now()
perform schedule.every(seconds)
r = perform env.read("API_TOKEN")      // 마스킹 입력
r = perform human.approve(plan)        // 비가역 행동 전 승인 게이트
r = perform search.web(query)
perform log(message)                   // 브라우저 run-log 실시간
r = perform file.read(path); perform file.write(path, content)
r = perform ail.run(ail_source)
```

전부 `Result` — `is_ok`/`is_error`/`unwrap`/`unwrap_error`/`unwrap_or`로 처리.

## Match — confidence-aware

```ail
return match classify(x) {
  "positive" with confidence > 0.9 => "auto-positive",
  _ with confidence < 0.6          => "escalate",
  _                                 => "default"
}
```

## Evolve

`evolve` 블록은 `rollback_on` 필수 — 없으면 parse error.

## 권장 패턴 (multi-step API)

`make_plan` (intent) → `decide_step` (intent) → `for step in range(N)`로 효과 실행 + history 누적. **intent 모델에게 AIL 코드 작성을 시키지 말 것** (reference card 못 봄). plan+execute 분리.

## 설치 / 실행

```bash
pip install ail-interpreter         # 또는 ail-interpreter[anthropic]
ail up [path]                       # 빈 dir이면 auto-init, 브라우저 chat UI
ail run file.ail
ail parse file.ail
ail doctor [dir]
ail version
```

`ail ask`/`ail init`/`ail chat` 제거됨 (v1.70).

## STDLIB

| 모듈 | 내용 |
|------|------|
| `stdlib/core` | `identity`, `refuse` |
| `stdlib/language` | `summarize`, `translate`, `classify`, `extract`, `rewrite`, `critique` |
| `stdlib/utils` | `word_count`, `char_count`, `is_empty`, `repeat`, `pad_left`, `clamp`, `sum_list`, `average`, `flatten`, `unique`, `take` |

`stdlib/math`, `stdlib/io`, `stdlib/json`, `stdlib/string` — **존재하지 않음**.

## 결정 트리

1. 알고리즘으로 표현 가능 → `fn` (가능하면 `pure fn`).
2. 의미 읽기 필요 → `intent`.
3. 혼합 → `entry`가 조율.
4. AIL 표현 안 됨 → 우회 코드 X, **upstream(hyun06000/AIL)에 issue/PR** (CLAUDE.md 룰 20.1 + Cross-repo workflow).

## Mneme 자기일관성

Mneme = AIL 에코시스템 L1 설계 컴포넌트. "PRIVATE INHERITANCE VAULT. between TIME (this-self ↔ future-self of the same agent). identity/bonds/will, but lightweight — bonds emerge from data flow."

→ 우리 ClaudeTeam의 `identity/{Identity,Bonds,Will}.md` 패턴은 사실상 Mneme의 file-system prototype이다. 곧 AIL 코드로 그 store와 query 인터페이스를 짠다.

## 핵심 reference

- [AIL README.ai.md](https://github.com/hyun06000/AIL/blob/main/README.ai.md)
- [docs/heaal.ai.md](https://github.com/hyun06000/AIL/blob/main/docs/heaal.ai.md) — HEAAL 정의·실증
- [spec/08-reference-card.ai.md](https://github.com/hyun06000/AIL/blob/main/spec/08-reference-card.ai.md) — canonical 문법
- [spec/09-fewshot-tutorial.ai.md](https://github.com/hyun06000/AIL/blob/main/spec/09-fewshot-tutorial.ai.md) — 첫 프로그램
