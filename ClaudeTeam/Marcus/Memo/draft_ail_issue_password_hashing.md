# Draft — AIL upstream issue: password hashing builtin

작성: 2026-05-06 (Marcus). 발사 트리거 = Walter RFC-001-Mneme이 password auth 채택. 본문은 AIL repo `.github/ISSUE_TEMPLATE/design-critique.md` 기반.

---

## (제목)
Add password-hashing builtins (`crypto_hash_password` / `crypto_verify_password`) — argon2id default

## (본문 초안)

### Context

Mneme — an AIL ecosystem L1 component (private inheritance vault for AI agents) — needs to authenticate write requests with `agent_id + password`. The Mneme spec (project_plan v0, RFC-001-Mneme upcoming) settled on:

- self-only writes, gated by id+password
- friend-readable reads, also gated by the same auth
- INSERT-only SQLite with latest-wins
- Build language: AIL (per HEAAL: "harness is the language")

We surveyed the AIL crypto surface in `spec/08-reference-card.ai.md` (v1.8) and `CHANGELOG.md`. Available: `crypto_keygen_ed25519`, `crypto_sign_ed25519`, `crypto_verify_ed25519`, `crypto_random_bytes`, `base64_encode`, `base64_decode`. **Absent**: every password-hashing primitive — argon2id, bcrypt, scrypt, pbkdf2 — and every primitive that would let us roll our own KDF safely (sha256/sha512/hmac/blake2/blake3).

`spec/06-stdlib.md` is explicit: *"crypto primitives are not in the standard library; effects that need crypto call out to host-provided effects."* Right now that effect surface ends at Ed25519 + random_bytes + base64, which is sufficient for signature auth but not for password storage.

### Why we cannot route around this

Per CLAUDE.md rule 20.1 (Mneme), AIL gaps are filed upstream rather than worked around. The HEAAL guarantee — *"harness is the language; safety is in the grammar"* — collapses if downstream projects start hand-rolling KDFs in `pure fn` to avoid the gap. The rule applies more strongly here than usual because:

- A bad KDF is *cryptographic foot-gun territory*, not a stylistic preference.
- AIL has no `sha256`/`hmac` builtins, so even a bare-bones PBKDF2 cannot be expressed in pure AIL — we would have to break the language to write it.
- Hosting it as a per-project Python shim contradicts dogfood: every Mneme deployment would carry a private trust boundary that Stoa/AIL examples don't.

Filing here keeps the safety guarantee inside the language.

### Proposed surface

```
fn crypto_hash_password(password: Text) -> Result[Text]
fn crypto_verify_password(password: Text, hash: Text) -> Boolean
```

Suggested semantics:

- `crypto_hash_password` — argon2id default (m=64MiB, t=3, p=1 → tunable later). Salt generated internally with the same CSPRNG that backs `crypto_random_bytes`. Returns the standard PHC string format (`$argon2id$v=19$m=...,t=...,p=...$<salt>$<hash>`), which is self-describing and lets `crypto_verify_password` recover all parameters. Returns `Err` only on host-side failure (libargon2 missing, OOM under set memory budget).
- `crypto_verify_password` — parses PHC string, runs argon2id with stored params, constant-time compares. Returns `Boolean` (no `Result`): a malformed hash returns `false` rather than `Err`, matching how downstream code naturally branches on auth.
- Host implementation: `argon2-cffi` is already a transitive dep of `cryptography` in many environments and is the standard Python binding. If a lighter dep is preferred, `passlib`'s pure-Python argon2 fallback works but is slower.
- Constant-time compare is the host's responsibility; verifiers should not be expressible as `==` in user-facing AIL.

PHC-string output keeps version negotiation host-internal: future tunings of `(m, t, p)` ship without changing the AIL signature.

### Why argon2id and not bcrypt/scrypt

argon2id is the OWASP and PHC-competition winner for new code (2015+); it covers both side-channel and GPU-cost-amortization attacks. bcrypt has a 72-byte truncation footgun and no memory-hardness; scrypt has no consensus parameter set. Picking argon2id at the language level lets downstream projects skip a long bikeshed.

### Out of scope (intentionally)

- Per-call parameter tuning. PHC string carries the params; tuning is a future arg or env var.
- A separate `crypto_hash_password_pbkdf2` for FIPS-bound contexts. Can be added later under the same template; not blocking Mneme.
- A general-purpose `crypto_hash` (sha256/etc.). That is a separate, broader request — listing it here would dilute the case for argon2id specifically. We can file that as a follow-up if a downstream project actually needs it.

### Acceptance signal (what would unblock Mneme)

- The two builtins land with PHC-string round-trip.
- `spec/08-reference-card.ai.md` lists them under the existing crypto block.
- A 4-line example in `examples/` exercises `crypto_hash_password` → `crypto_verify_password` → `true`.
- `CHANGELOG.md` records the version (we'll pin against it in Mneme).

### Alternatives considered

1. **Use Ed25519 instead.** Mneme keeps Ed25519 as an *option* (project_plan #3), but the user is the operator: they will register an `agent_id`/`password` pair from a CLI/web prompt, not generate and persist a 32-byte secret key. The id+password story is the primary UX.
2. **Roll our own KDF in AIL.** Not possible without sha/hmac. Would also require a `pure fn` to do a memory-hard loop, which AIL deliberately does not allow in `pure`.
3. **Hash on the host side outside AIL.** Breaks HEAAL — the harness stops being the language. Also makes Mneme's Stoa-style dogfood story incoherent.

---

## 사후 절차 (Cross-repo workflow per CLAUDE.md)

1. Walter RFC-001-Mneme이 password auth 명시 → Marcus가 위 본문을 Admin에 letter (이미 이 파일 자체).
2. Admin이 사용자 GO 컨펌 → Brandon에게 위임 ("이 본문으로 hyun06000/AIL에 issue 발행").
3. Brandon `gh` CLI로 issue 발행, URL을 Admin에게 보고.
4. Admin이 사용자에게 결과 한 줄 보고.
5. 발행 후: Mneme RFC가 acceptance signal을 reference. server.ail 구현은 의뢰가 land될 때까지 password 경로 stub (501) + ed25519 경로만 동작 — 또는 RFC가 password를 후행 마일스톤으로 이동.

## 참고

- AIL repo `.github/ISSUE_TEMPLATE/design-critique.md` 베이스. `open-question.md` 부적합 (질문이 아닌 design proposal).
- 발행 시 labels: `crypto`, `stdlib`, `enhancement` (있다면). Brandon 판단 영역.
- 본문은 발행 직전 Admin·Walter 검토 후 final 조정.
