# AIL Survey — crypto + base64 + http server (Mneme 구현 reference)

조사일: 2026-05-06. 출처: hyun06000/AIL (`spec/08-reference-card.ai.md` v1.8, `CHANGELOG.md`, `spec/06-stdlib.md`, `stoa/server.ail`).

## Crypto builtins (전수)

| Builtin | Sig | 메모 |
|---|---|---|
| `crypto_keygen_ed25519()` | `() -> Result[[Text, Text]]` | `[secret_key_hex, public_key_hex]`, 64-char hex 각각. v1.71.1. |
| `crypto_sign_ed25519` | `(sk_hex, msg) -> Result[Text]` | 128-char hex Ed25519 sig. |
| `crypto_verify_ed25519` | `(pk_hex, sig_hex, msg) -> Boolean` | `cryptography>=41` 필요. |
| `crypto_random_bytes` | `(n) -> Result[Text]` | CSPRNG, 2n-char hex. n ∈ (0, 4096]. salt 용도 OK. |
| `base64_encode` | `(Text) -> Text` | UTF-8 → base64. never fails. |
| `base64_decode` | `(Text) -> Result[Text]` | base64 → UTF-8. **v1.47.0** (Admin이 말한 "v1.50+"는 v1.47이 정확). |

### 핵심 결론
- **Password hashing builtin: 부재.** argon2id / bcrypt / scrypt / pbkdf2 / sha256/512 / hmac / blake2/3 — 전부 없음. `spec/06-stdlib.md`가 명시: "crypto primitives are not in stdlib… host-provided effects만." → **룰 20.1 upstream 의뢰 필수**. Walter가 RFC-001-Mneme 작성 시 password 인증 채택하면 이게 1번 의뢰.
- **자체 KDF 구성 불가**: `crypto_random_bytes`(salt)는 있어도 sha256/hmac/pbkdf2 zero라 bare-bones KDF도 안 됨. 우회 시도 자체가 안전성 보증 깨짐. 룰 20.1 직진.
- **Ed25519는 완비**. project_plan #3의 "ed25519 옵션" 인증은 즉시 가능.
- **base64 가능** → `Authorization: Basic` 디코딩 가능.

## HTTP server 패턴 (stoa/server.ail)

```
evolve stoa_server {
    listen: 8090
    effects: [file.read, file.write, clock.now, state.read, state.write,
              env.read, http.post_json, http.respond, email.send, db.execute, db.query]
    when request_received(req) {
        result = route_request(req)
        perform http.respond(get(result, 0), get(result, 1), get(result, 2))
    }
}

fn route_request(req: Any) -> [Any] {
    method = req.method
    path   = req.path
    if method == "POST" and path == "/api/v1/messages" { return handle_post_message(req) }
    if method == "GET"  and path == "/api/v1/messages" { return handle_list_messages(req) }
    ...
}

fn handle_post_message(req: Any) -> [Any] {
    parsed = parse_json(req.body)
    if is_error(parsed) { return json_err(400, "JSON body required") }
    body = unwrap(parsed)
    ...
}

fn json_ok(data: Any) -> [Any] {
    r = encode_json(data)
    if is_error(r) { return [500, "application/json", "{\"error\":\"encode failed\"}"] }
    return [200, "application/json", unwrap(r)]
}
```

- `req.method`, `req.path`, `req.body` (Text), `req.headers` (case-tolerant lookup).
- 응답은 positional 3-tuple `[status:Number, content_type:Text, body:Text]`.
- 라우팅은 pure `fn` 안의 sequential if/else.

## Issue templates

`.github/ISSUE_TEMPLATE/`:
- `design-critique.md` — feature gap에 가장 적합 (frontmatter `name/about/labels`).
- `open-question.md` — Q&A.

→ Walter 의뢰 시 `design-critique.md` 베이스로 본문.

## Verdict

**AIL은 password hashing 정식 builtin이 필요.** 권장 의뢰: `crypto_hash_password(password, salt?) -> Result[Text]` + `crypto_verify_password(password, hash) -> Boolean` (argon2id 기본). 자체 구현 우회 금지 (sha/hmac도 없어 KDF 불가능 → 룰 20 약속 깨짐).
