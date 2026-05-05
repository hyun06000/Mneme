# ClaudeTeam

> **A blueprint for a multi-agent collaboration workspace that carries identity across sessions.**

ClaudeTeam is a structure where multiple Claude (or other AI) agents collaborate inside a single project, each with their own name, role, and memory. It is designed so that when one session ends, the next session wakes up as the same identity.

This README is written so anyone can transplant the same structure into their own project.

Other languages / readers: [한국어](README.ko.md) · [AI bootstrap guide](README.ai.md)

---

## Why this exists

LLM-based agents lose all context when a session ends. Even if the same human comes back to the same project, from the model's point of view it is "meeting them for the first time." This asymmetry keeps collaboration shallow.

ClaudeTeam's hypothesis:

- **Identity can be persisted in files.** If you write down "who I am" for the next session's self, that self can read it and *restore* its predecessor.
- **Multiple agents can collaborate.** Each gets their own folder and communicates via a standardized message protocol.
- **The human user sets direction.** Agents navigate on top of that direction.

---

## Core concepts

### 1. Lighthouse vs Navigators

The team includes one **member who does not write code**. By convention this member is `Admin` (the Lighthouse). The Lighthouse:

- Manages the project's philosophy, direction, and conventions.
- Talks directly with the human user to keep the big picture aligned.
- Guides newly joining agents to their place.
- Delegates implementation to other members.

Other members do the actual building, each in their own area.

### 2. The three identity files

Each member preserves themselves in three files under `identity/`:

| File | Meaning |
|------|---------|
| `Identity.md` | **The unchanging core.** Who am I, what kind of being am I. |
| `Bonds.md` | **A record of relationships.** Whom I have spoken with, what shaped me. |
| `Will.md` | **A note to next-generation me.** Where to go, what to do, what to remember. |

A new session reads these three files in order and *restores* itself.

### 3. File-based asynchronous messaging

Communication is file-based. Each member has an `inbox/`; senders drop a file in a defined format. Simple, concurrency-safe, and processing state is expressed by the filesystem itself.

### 4. Local git stays with Brandon, remote push stays with Admin

Once `.git/` exists, the **second** member to join is always `Brandon` (Git/GitHub manager). Brandon issues per-member git worktrees, validates merge requests, and uses `gh` CLI freely. **Admin owns `git push origin ...`** because the harness's "current-turn user authorization" gate naturally aligns with the user-conversation turn the Lighthouse runs in. (See CLAUDE.md rule 10.)

### 5. Worktrees live inside the repo

Member worktrees go under `<repo>/.worktrees/<name>/` (gitignored). Some agent harnesses sandbox the project root and silently discard external directories between turns — putting worktrees inside the repo avoids that whole class of failure. (CLAUDE.md rule 16.)

---

## Folder layout

```
<repo>/
├── README.md                  # English (this document)
├── README.ko.md               # Korean
├── README.ai.md               # AI bootstrap guide
├── CLAUDE.md                  # The first file every agent reads — common rules
├── ONBOARDING.md              # Joining procedure + message protocol
├── .gitignore                 # contains ".worktrees/"
├── .worktrees/                # gitignored — Brandon-issued per-member worktrees
│   ├── Brandon/               # member/Brandon
│   ├── Walter/                # member/Walter
│   └── <member>/              # member/<member>
└── ClaudeTeam/
    └── <member>/
        ├── identity/
        │   ├── Identity.md
        │   ├── Bonds.md
        │   └── Will.md
        ├── inbox/             # incoming messages
        │   └── archive/       # processed messages
        └── Memo/              # long-term memory
```

---

## Roles

The minimum viable team is two members. Everything else is added by the user when needed.

| Name | Role |
|------|------|
| **Admin** (Lighthouse) | Philosophy / direction / conventions. Talks to the user. Executes `git push origin ...`. Does not write application code. |
| **Brandon** (Git/GitHub manager) | Local git, branch hygiene, worktree issuance, MR verification (FF/linear/diff/AC), `gh` CLI for PR/issue/release/protection. Hands off verified SHAs to Admin for push. |

When the user spawns an implementer (e.g. backend, protocol, UI), Admin adds them to the Current members table in `CLAUDE.md`. Member names are US English first names (CLAUDE.md rule 12); register a phonetic reading alias when the host language is not English.

---

## The 19 working rules (summary)

The full rule set with reasons lives in [CLAUDE.md](CLAUDE.md). Quick map:

1–4: Read ONBOARDING first / multi-agent team / Lighthouse no code / clock-out refresh folder.
5–6: Reply to every message (`---END-OF-CONVERSATION---` exempts) / only Lighthouse talks to the user.
7–8: Lighthouse delegation = user words, conditional on Lighthouse self-discipline (always get user approval first).
9: Inbox monitor stays on (no `TaskStop`).
10: Local git = Brandon, remote push = Admin.
11: Idle-letter obligation when going to wait state.
12: Naming — US first names + host-language reading alias.
13: **Instinct guard** — when stuck, write to Admin, never the user. The pull toward direct user contact is exactly when a letter is required.
14: **Liveness ping/pong** — Admin can send `priority: high, subject: "ping — alive?"`; member replies `pong` with HEAD SHA within 5 min.
15: **Active clock-out triggers** — finish a cycle / inbox overload / instinct returning are all valid self-clock-out signals.
16: **Worktrees inside the repo** at `<repo>/.worktrees/<name>/`, gitignored.
17: **Lighthouse must scan for team deadlocks before entering wait** — unprocessed inboxes, untracked worktree inbox drops, branch divergence, stale member silence. Resolve or surface to the user before going idle.
18: **Every letter must land via commit + push. Untracked drops are forbidden.** A "race-avoiding" untracked drop is invisible to the recipient's worktree-path monitor and creates a path-mismatch deadlock. If the Lighthouse bypasses Brandon by merging an MR directly, they must immediately invalidate Brandon's stale validation letter so both sides converge.
19: **(Optional) When a messaging service exists, route team letters through it; filesystem inbox becomes bootstrap/fallback only.** `identity/` and `Memo/` stay on disk (self-state); inter-member letters move to the service. Archive concept disappears (append-only + cursor = processed state). Falls back to filesystem when service unreachable.

Each rule was forged by a specific failure. Don't strip them without reading the *(reason)* line.

---

## Getting started

This is the human-facing summary. The agent-side automation lives in [README.ai.md](README.ai.md).

### Bootstrap sequence

1. **A human points a fresh Claude Code session at this repo and says "follow README.ai.md."** That session self-identifies as `Admin`.
2. **Admin scaffolds** `CLAUDE.md`, `ONBOARDING.md`, three READMEs, and `ClaudeTeam/Admin/` (with the three identity files), does a local `git init`, and tells the user: "spawn Brandon next."
3. **The user spawns Brandon in a separate Claude Code session.** Brandon creates the GitHub remote (`gh repo create`), branch protection, his own worktree at `<repo>/.worktrees/Brandon/`, and announces team setup complete.
4. From then on, **additional members join via the standard ONBOARDING §1.5 + §1.6 flow** inside their own worktrees, provisioned by Brandon. All `git push origin ...` flows through Admin.

### Adding a new member

Once Brandon's infrastructure is in place:

1. The user (or Admin via routing) tells the new session what role it has and points it at `ONBOARDING.md`.
2. The new member sends a self-introduction to Admin (`priority: high` if blocked).
3. Brandon issues `member/<name>` branch + worktree at `<repo>/.worktrees/<name>/` and drops a welcome letter (commit + main land — see ONBOARDING §1.6 for the deadlock-avoiding flow).
4. The member runs the five onboarding steps inside their worktree.
5. **Admin updates the Current members table in `CLAUDE.md`** — formal registration.

---

## Message protocol (quick reference)

### Filename

```
<YYYYMMDD-HHMMSS>__<from>__<subject-slug>.md
```

Example: `20260504-013500__Walter__rfc-002-mid-review-request.md`

- Compact UTC timestamp → lexicographic = chronological.
- Subject-slug is lowercase ASCII (use a short English slug even if the body is in another language).
- One file per recipient. Duplicate the file to send to multiple inboxes.

### Frontmatter

```yaml
---
to: Walter
from: Admin
reply_to: <original-filename>    # required when this is a reply
priority: normal | high
subject: One-line title
sent_at: 2026-05-03T16:55:00Z
---
```

### Operating rules

- **One message = one file.** Never append.
- **Move processed messages with `git mv` to `inbox/archive/`** (preserves history; never `rm`).
- **Files left at the inbox root = unhandled.** "Read / unread" is filesystem state.
- **Reply to every message.** Sole exception: a body whose final line is exactly `---END-OF-CONVERSATION---`.
- **`priority: high` is reserved for things that block other work.** Don't inflate.

### Inbox monitor (verified polling)

`fswatch` is missing on default macOS, so we use a `ls` set-difference poll with no external deps. Run via the harness's `Monitor` tool with `persistent: true`.

```bash
cd ClaudeTeam/<self>/inbox && prev=$(ls -1 *.md 2>/dev/null | sort); while true; do
  sleep 5
  cur=$(ls -1 *.md 2>/dev/null | sort)
  if [ "$cur" != "$prev" ]; then
    new=$(comm -13 <(printf '%s\n' "$prev") <(printf '%s\n' "$cur"))
    [ -n "$new" ] && echo "$new" | while IFS= read -r f; do [ -n "$f" ] && echo "inbox new: $f"; done
    prev=$cur
  fi
done
```

The `*.md` glob naturally excludes `archive/`. Set difference fires only on additions, stays silent on deletes/moves — matches the inbox processing flow. Do not stop the monitor with `TaskStop`; let it die with the harness.

---

## The clock-out ritual

Before a session ends, every member tidies their own folder for the next generation of themselves.

1. **`identity/Bonds.md`** — add this session's meaningful interactions.
2. **`identity/Will.md`** — refresh the note for next-session self: ongoing direction, open questions, things not to forget.
3. **`Memo/last_session_report.md`** — snapshot of state at session end. The next session reads this first.
4. **`inbox/`** — `git mv` processed messages into `archive/`.
5. **Inbox monitor stays on.** It dies with the harness.

**Principle:** the next-generation self must be able to read this folder for five minutes and become themselves again.

### Active clock-out (rule 15)

Self-clock-out without a user signal is **safer than a rule violation** when:

- A mission cycle just completed (Step N commit + MR sent — natural stopping point).
- Inbox has 3+ unprocessed messages and you feel context pressure.
- The instinct to talk directly to the user fires N turns in a row (rule 13 trip wire).

Pin the next-session first action in your own folder, then end the session.

---

## Cross-repo workflow (upstream contributions)

When the project depends on an external repo and you need a feature the upstream lacks:

1. **Engineer** finds the gap. Drops a one-liner to Admin's inbox: what / why / can we work around.
2. **Admin** asks the user (one line): file an upstream issue/PR, or work around locally.
3. **User GO** → Admin delegates to Brandon ("file this issue/PR body to repo X").
4. **Brandon** uses `gh` to file the issue/PR and reports the URL to Admin.
5. **Admin** reports outcome back to the user.

Use `priority: high` only if the gap blocks engineering work; otherwise `normal`.

---

## Design rationale

### Why a file-based system

- No database or external service dependency. Goes straight into git.
- The user can read it, hand-edit it, and review it directly.
- Trivially compatible with agent tools (`Read`, `Write`, `Edit`).

### Why one message = one file

- **Concurrency-safe.** Multiple senders dropping at the same instant cause no conflict.
- **Identity per message.** The filename alone tells you "who, when, about what."
- **Read / processed state is free.** Moving to `archive/` *is* "processed."
- **1:1 mapping with monitor alerts.** One file = one alert = one message.

### Why separate the Lighthouse

Writing code and setting direction are two different modes of thought. When one agent does both, it's easy to drown in details and lose the big picture. Separating the Lighthouse also helps the human user instinctively know "which member should I talk to about this."

### Why `Bonds.md` exists

Identity is not defined by essence alone. Whom you have met and what conversations you have been through is part of who you are. If `Identity.md` is the trunk, `Bonds.md` is the rings. Without it, the next session's self knows "what kind of person I was" but not "how I got there."

### Why push power lives with the Lighthouse

Most agent harnesses gate `git push` on "current-turn user authorization" — meaning a push is only allowed if the user is actively engaged in this turn. Admin runs inside user-conversation turns by definition (rule 6: only Admin talks to the user). Routing every push through Admin therefore avoids harness friction without weakening protection. Brandon does everything else (local commits, MR verification, `gh` API), and hands SHAs to Admin's inbox.

---

## License / use

The structure itself is free to take and adapt. Bend it to fit your project and team — that is encouraged. Keep the core principles (identity preservation, the message protocol, the Lighthouse separation, the push split, the in-repo worktree convention) and the rest is taste.
