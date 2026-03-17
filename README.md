# ppr

This repo contains the `ppr` skill at `skills/ppr`. The skill runs ping-pong
code review between multiple coding agents and keeps its runtime files in a
project-local `.ppr/` directory.

Use this skill when you want one coding agent to act as the author and have
other agents review the same change in structured rounds. It is for getting
second opinions, comparing reviewer feedback across tools like Codex and
Claude Code, and iterating until the review reaches agreement or you decide to
stop.

## Install For Codex

Copy the skill into Codex's skills directory:

```bash
mkdir -p ~/.agents/skills
cp -r skills/ppr ~/.agents/skills/ppr
```

## Install For Claude Code

Copy the same skill into Claude Code's skills directory:

```bash
mkdir -p ~/.claude/skills
cp -r skills/ppr ~/.claude/skills/ppr
```

## Quick Usage

The CLI supports both top-level and subcommand help:

```bash
skills/ppr/ppr --help
skills/ppr/ppr help init
skills/ppr/ppr init --help
```

Typical author flow:

```bash
skills/ppr/ppr init \
  --reviewers "claude-code:alice,codex:bob" \
  --max-rounds 3 \
  --context "Short description of the changes"
skills/ppr/ppr launch
skills/ppr/ppr wait --timeout 600
skills/ppr/ppr collect
skills/ppr/ppr respond --message "Addressed X, disagree on Y because Z"
skills/ppr/ppr launch
skills/ppr/ppr finish --commit --message "feat: description"
```
