# Message protocol — 빠른 참조 (ONBOARDING §7 요약)

## 위치
- 한 메시지 = 한 파일 = `ClaudeTeam/<수신자>/inbox/<filename>.md`.

## 파일명
- `<YYYYMMDD-HHMMSS>__<from>__<subject-slug>.md`
- subject-slug: 영문 소문자·숫자·하이픈만.

## Frontmatter
```yaml
---
to: <수신자>
from: <발신자>
reply_to: <원본 파일명>      # 답신 시 필수
priority: normal | high
subject: <한 줄>
sent_at: <ISO8601 + TZ, 예: 2026-05-06T07:30:00+09:00>
---
```

## 본문 종료
- 스레드 닫을 때만 본문 마지막 줄에 정확히 `---END-OF-CONVERSATION---`.
- 받은 쪽이 임의로 추가하지 않는다.

## priority
- `normal`: 평상시.
- `high`: 다른 작업을 막는 사안만. 인플레이션 금지.

## 처리 흐름
1. 모니터가 새 파일 감지 → 깨어남.
2. frontmatter로 분류.
3. 처리 후 `git mv`로 `inbox/archive/`에 이동 (rule 10 archive: `git mv`, 절대 `rm` 금지).
4. inbox 루트 = 미처리.

## 송신 후
- 모든 letter는 commit + push로 land (규칙 18). Untracked drop 금지.
- Lighthouse(Admin)만 `git push origin ...` 실행 (규칙 10).
