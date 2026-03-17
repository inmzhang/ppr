---
name: ppr
description: >
  Orchestrate multi-agent ping-pong code reviews where different coding agents
  (Claude Code, Codex, Gemini CLI, OpenCode, etc.) review each other's work
  through structured rounds of file-based feedback. Use this skill whenever the
  user wants code review from multiple AI agents, mentions ping-pong review,
  cross-agent review, wants to have AI agents review code changes collaboratively,
  mentions "ppr", or asks for multi-model code review. Also use when the user
  says things like "have codex review this", "get a second opinion from gemini",
  or "review my changes with other agents".
---

# PPR — Ping-Pong Review

Read `INSTRUCTIONS.md` in this skill's directory for the full portable protocol
documentation. Below are Claude Code-specific instructions for orchestrating
and participating in PPR reviews.

## As the Orchestrating Author

When the user asks you to start a ping-pong review of their changes:

### 1. Determine the reviewers

Ask the user which agents should review if they haven't specified. Common
setups:
- `claude-code:reviewer1,codex:reviewer2` — Claude + Codex
- `claude-code:reviewer1,codex:reviewer2,gemini:reviewer3` — three-way

### 2. Initialize and launch

```bash
ppr init --reviewers "codex:codex-reviewer,gemini:gemini-reviewer" \
         --max-rounds 3 \
         --context "Description of the changes"
ppr launch
```

Both commands must run without blocking. `ppr launch` starts reviewer agents
in the background — their stdout is captured to review files.

### 3. Wait and collect

```bash
ppr wait --timeout 600
ppr collect
```

Read the collected reviews. Present a summary to the user highlighting:
- Issues that multiple reviewers agree on (high confidence)
- Disagreements between reviewers (worth discussing)
- The overall verdict from each reviewer

### 4. Address feedback

For each review comment, decide with the user:
- **Fix it**: Make the code change.
- **Argue**: Write a response explaining why the current approach is better.
- **Ask**: Request clarification from the reviewer.

After making changes:

```bash
ppr respond --message "Addressed X, disagreed on Y because Z"
ppr launch   # Re-launch reviewers who requested changes
```

### 5. Iterate until consensus

Repeat steps 3-4 until all reviewers approve or the round limit is hit.

### 6. Finish

```bash
ppr finish --commit --message "feat: description of changes"
```

## As a Reviewer

When launched as a reviewer (you'll see PPR protocol instructions in your
prompt), follow the review format described in INSTRUCTIONS.md. Key points:

- Be thorough but constructive
- Tag each issue: `[bug]`, `[security]`, `[performance]`, `[style]`,
  `[suggestion]`, `[question]`
- Reference specific files and lines
- End with **LGTM** or **CHANGES REQUESTED**
- Emit only the final review; ppr captures stdout or provides a final-output path

## Prerequisites

- The `ppr` script must be on PATH (run `install.sh` or add the skill
  directory to PATH)
- `agents.json` must be configured at `~/.config/ppr/agents.json` or
  `.ppr/agents.json` in the project
- Dependencies: `bash`, `jq`, `git`

## Troubleshooting

- **"agent type not found"**: Add the agent to `agents.json`. See
  INSTRUCTIONS.md § Agent Configuration.
- **Reviews not appearing**: Check `.ppr/round-N/reviews/.stderr-NAME.log`
  for agent launch errors.
- **Timeout on wait**: Increase with `--timeout` or check if the agent
  command template is correct in `agents.json`.
