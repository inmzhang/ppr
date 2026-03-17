# PPR

PPR ("Ping-Pong Review") is a small shell-based orchestration tool for running
multi-agent code review rounds with terminal coding agents such as Claude Code,
Codex CLI, and Gemini CLI.

The author agent initializes a review, launches reviewer agents in the
background, collects their feedback, responds, and iterates until consensus or
the round limit is reached.

## Install

Install the `ppr` CLI and the default agent config:

```bash
./install.sh
```

This copies:

- `ppr` to `~/.local/bin/ppr`
- `agents.json` to `~/.config/ppr/agents.json` if it does not already exist

Install agent-specific integration:

```bash
./install.sh --agent claude-code
./install.sh --agent codex
./install.sh --agent gemini
./install.sh --agent all
```

## What The Installer Sets Up

Claude Code:
- Symlinks this directory into `~/.claude/skills/ppr`

Codex:
- Appends a short pointer to `~/AGENTS.md`

Gemini CLI:
- Appends a short pointer to `~/GEMINI.md`

## Verified Reviewer Commands

These are the default `agents.json` commands shipped by this repo:

```json
{
  "claude-code": {
    "cmd": "claude -p --permission-mode plan --output-format text \"$(cat \"$PROMPT\")\""
  },
  "codex": {
    "cmd": "codex --ask-for-approval never exec --sandbox read-only -o \"$REVIEW_FILE\" - < \"$PROMPT\""
  },
  "gemini": {
    "cmd": "gemini -p \"$(cat \"$PROMPT\")\" --approval-mode plan --output-format text"
  }
}
```

Rationale:

- All three commands run non-interactively.
- Reviewers emit only the final review.
- `ppr` captures stdout into `.ppr/round-N/reviews/<name>.md` unless the agent
  command uses `$REVIEW_FILE` to write the final answer directly.
- Reviewer permissions are read-only / no-write where supported.

This matches the current CLI surfaces verified locally on 2026-03-17:

- Claude Code `2.1.77`
- Codex CLI `0.115.0`
- Gemini CLI `0.33.2`

## Quick Start

From a git repo with local changes:

```bash
ppr init \
  --reviewers "claude-code:claude-reviewer,gemini:gemini-reviewer" \
  --max-rounds 2 \
  --context "Please review these changes for correctness and maintainability."

ppr launch
ppr wait --timeout 600
ppr collect
```

After you address feedback:

```bash
ppr respond --message "Addressed the blocking comments."
ppr launch
```

When finished:

```bash
ppr finish --commit --message "feat: reviewed changes"
```

## Protocol Notes

- Reviewers should emit only the final markdown review.
- Use `$REVIEW_FILE` only for CLIs that can write just the final answer there.
- `ppr` treats any non-empty review file as completion and marks `LGTM` when
  the captured review contains an `LGTM` verdict line.

See [INSTRUCTIONS.md](./INSTRUCTIONS.md) for the full portable protocol and
[SKILL.md](./SKILL.md) for the skill-oriented entrypoint.
