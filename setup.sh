#!/usr/bin/env bash
#
# setup.sh — sync skills & instructions from this repo into the global system.
#
#   ./setup.sh           install (symlink repo → ~/.copilot & ~/.claude)
#   ./setup.sh --unlink  remove symlinks, restore nothing
#   ./setup.sh --status  show current link state
#
# Works for both GitHub Copilot (~/.copilot) and Claude Code (~/.claude).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COPILOT_DIR="$HOME/.copilot"
CLAUDE_DIR="$HOME/.claude"
COPILOT_INSTRUCTIONS_DIR="$COPILOT_DIR/instructions"
COPILOT_INSTRUCTIONS_FILE="$COPILOT_DIR/instructions/copilot.instructions.md"
COPILOT_SKILLS_DIR="$COPILOT_DIR/skills"
CLAUDE_INSTRUCTIONS_FILE="$CLAUDE_DIR/CLAUDE.md"
CLAUDE_SKILLS_DIR="$CLAUDE_DIR/skills"

ACTION="${1:-install}"

color() { printf '\033[%sm%s\033[0m\n' "$1" "$2"; }
info()  { color "0;36" "› $*"; }
ok()    { color "0;32" "✓ $*"; }
warn()  { color "0;33" "! $*"; }
err()   { color "0;31" "✗ $*" >&2; }

backup_path() {
  local p="$1" bak
  bak="$p.backup.$(date +%Y%m%d%H%M%S)"
  mv "$p" "$bak"
  warn "backed up existing $p → $bak"
}

link() {
  local target="$1" name="$2"
  if [[ -L "$name" ]]; then
    rm "$name"
  elif [[ -e "$name" ]]; then
    backup_path "$name"
  fi
  ln -s "$target" "$name"
  ok "linked $name → $target"
}

unlink_path() {
  local name="$1"
  if [[ -L "$name" ]]; then
    rm "$name"
    ok "removed symlink $name"
  elif [[ -e "$name" ]]; then
    warn "$name is not a symlink (left untouched)"
  else
    info "$name absent"
  fi
}

status_path() {
  local name="$1"
  if [[ -L "$name" ]]; then
    ok "$name → $(readlink "$name")"
  elif [[ -e "$name" ]]; then
    warn "$name exists but is NOT a symlink"
  else
    info "$name absent"
  fi
}

do_install() {
  info "Installing from $REPO_DIR"

  mkdir -p "$COPILOT_INSTRUCTIONS_DIR" "$COPILOT_SKILLS_DIR" "$CLAUDE_DIR"

  # --- Instructions (copilot.instructions.md is the single source of truth) ---
  link "$REPO_DIR/copilot.instructions.md" "$COPILOT_INSTRUCTIONS_FILE"

  # Claude's CLAUDE.md also points to the same file
  if [[ -L "$CLAUDE_INSTRUCTIONS_FILE" && "$(readlink "$CLAUDE_INSTRUCTIONS_FILE")" == *copilot.instructions.md* ]]; then
    ok "CLAUDE.md already linked → $(readlink "$CLAUDE_INSTRUCTIONS_FILE")"
  else
    link "$COPILOT_INSTRUCTIONS_FILE" "$CLAUDE_INSTRUCTIONS_FILE"
  fi

  # --- Skills (repo skill dirs → ~/.copilot/skills, then Claude links to Copilot) ---
  for skill_dir in "$REPO_DIR"/*/; do
    local name
    name="$(basename "$skill_dir")"
    [[ "$name" == ".git" || "$name" == ".github" ]] && continue
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    link "$REPO_DIR/$name" "$COPILOT_SKILLS_DIR/$name"
  done

  # Claude skills → Copilot skills (single link, mirrors existing setup)
  if [[ -L "$CLAUDE_SKILLS_DIR" && "$(readlink "$CLAUDE_SKILLS_DIR")" == "$COPILOT_SKILLS_DIR" ]]; then
    ok "Claude skills already linked → $COPILOT_SKILLS_DIR"
  else
    link "$COPILOT_SKILLS_DIR" "$CLAUDE_SKILLS_DIR"
  fi

  ok "Done. Skills & instructions are now shared across Copilot and Claude."
}

do_unlink() {
  info "Unlinking all symlinks"
  unlink_path "$COPILOT_INSTRUCTIONS_FILE"
  unlink_path "$CLAUDE_INSTRUCTIONS_FILE"
  for skill_dir in "$REPO_DIR"/*/; do
    local name
    name="$(basename "$skill_dir")"
    [[ "$name" == ".git" || "$name" == ".github" ]] && continue
    unlink_path "$COPILOT_SKILLS_DIR/$name"
  done
  unlink_path "$CLAUDE_SKILLS_DIR"
  ok "Unlinked."
}

do_status() {
  info "Current link state"
  status_path "$COPILOT_INSTRUCTIONS_FILE"
  status_path "$CLAUDE_INSTRUCTIONS_FILE"
  for skill_dir in "$REPO_DIR"/*/; do
    local name
    name="$(basename "$skill_dir")"
    [[ "$name" == ".git" || "$name" == ".github" ]] && continue
    status_path "$COPILOT_SKILLS_DIR/$name"
  done
  status_path "$CLAUDE_SKILLS_DIR"
}

case "$ACTION" in
  install)  do_install  ;;
  --unlink) do_unlink   ;;
  --status) do_status   ;;
  *)
    err "Usage: $0 [install|--unlink|--status]"
    exit 1
    ;;
esac