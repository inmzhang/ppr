#!/usr/bin/env bash
# ==============================================================================
# install.sh — Install ppr (Ping-Pong Review) for various coding agents
#
# Usage:
#   ./install.sh              Install ppr CLI to ~/.local/bin and default config
#   ./install.sh --agent X    Also set up instructions for agent X
#
# Supported --agent values: claude-code, codex, gemini, all
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_BIN="${PPR_INSTALL_BIN:-$HOME/.local/bin}"
INSTALL_CONFIG="$HOME/.config/ppr"

info() { echo "[ppr-install] $*"; }
die()  { echo "[ppr-install] error: $*" >&2; exit 1; }

# ---------- Core install: ppr script + default config ----------

install_core() {
  # Ensure bin directory exists and is on PATH
  mkdir -p "$INSTALL_BIN"
  cp "$SCRIPT_DIR/ppr" "$INSTALL_BIN/ppr"
  chmod +x "$INSTALL_BIN/ppr"
  info "installed ppr to $INSTALL_BIN/ppr"

  case ":$PATH:" in
    *":$INSTALL_BIN:"*) ;;
    *) info "NOTE: $INSTALL_BIN is not on your PATH. Add it:
    export PATH=\"$INSTALL_BIN:\$PATH\"" ;;
  esac

  # Install default agents.json if none exists
  mkdir -p "$INSTALL_CONFIG"
  if [ ! -f "$INSTALL_CONFIG/agents.json" ]; then
    cp "$SCRIPT_DIR/agents.json" "$INSTALL_CONFIG/agents.json"
    info "installed default config to $INSTALL_CONFIG/agents.json"
  else
    info "agents.json already exists at $INSTALL_CONFIG/agents.json — skipping"
  fi
}

# ---------- Agent-specific setup ----------

setup_claude_code() {
  # For Claude Code, install as a skill by symlinking the skill directory
  local skills_dir="$HOME/.claude/skills"
  mkdir -p "$skills_dir"

  if [ -L "$skills_dir/ppr" ] || [ -d "$skills_dir/ppr" ]; then
    info "claude-code: skill already exists at $skills_dir/ppr — skipping"
  else
    ln -s "$SCRIPT_DIR" "$skills_dir/ppr"
    info "claude-code: linked skill to $skills_dir/ppr"
  fi
}

setup_codex() {
  # For Codex, append ppr instructions to AGENTS.md in the user's home
  # directory. Codex reads AGENTS.md for system-level instructions.
  local agents_md="$HOME/AGENTS.md"

  if [ -f "$agents_md" ] && grep -q "PPR — Ping-Pong Review" "$agents_md" 2>/dev/null; then
    info "codex: AGENTS.md already contains ppr instructions — skipping"
  else
    {
      echo ""
      echo "<!-- PPR instructions: see $(readlink -f "$SCRIPT_DIR/INSTRUCTIONS.md") -->"
      echo "When asked to participate in a PPR (Ping-Pong Review), read"
      echo "$SCRIPT_DIR/INSTRUCTIONS.md for the full protocol."
      echo "The ppr CLI is at: $INSTALL_BIN/ppr"
    } >> "$agents_md"
    info "codex: appended ppr reference to $agents_md"
  fi
}

setup_gemini() {
  # For Gemini CLI, add a reference to the instructions.
  # Gemini reads GEMINI.md or uses settings — we add a GEMINI.md pointer.
  local gemini_md="$HOME/GEMINI.md"

  if [ -f "$gemini_md" ] && grep -q "PPR — Ping-Pong Review" "$gemini_md" 2>/dev/null; then
    info "gemini: GEMINI.md already contains ppr instructions — skipping"
  else
    {
      echo ""
      echo "<!-- PPR instructions -->"
      echo "When asked to participate in a PPR (Ping-Pong Review), read"
      echo "$SCRIPT_DIR/INSTRUCTIONS.md for the full protocol."
      echo "The ppr CLI is at: $INSTALL_BIN/ppr"
    } >> "$gemini_md"
    info "gemini: appended ppr reference to $gemini_md"
  fi
}

# ---------- Main ----------

install_core

agent=""
while [ $# -gt 0 ]; do
  case "$1" in
    --agent) agent="$2"; shift 2 ;;
    *) die "unknown option: $1" ;;
  esac
done

case "$agent" in
  "")          info "core install complete. Use --agent to set up specific agents." ;;
  claude-code) setup_claude_code ;;
  codex)       setup_codex ;;
  gemini)      setup_gemini ;;
  all)         setup_claude_code; setup_codex; setup_gemini ;;
  *)           die "unknown agent: $agent (supported: claude-code, codex, gemini, all)" ;;
esac

info "done!"
