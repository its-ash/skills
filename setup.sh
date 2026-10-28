#!/usr/bin/env bash
#
# setup.sh — sync skills & instructions from this repo into the global system.
#
#   ./setup.sh             install, ask: delete all other skills or overwrite
#   ./setup.sh --clean     install, delete all other skills first
#   ./setup.sh --overwrite install, keep other skills
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
COPILOT_AGENTS_DIR="$COPILOT_DIR/agents"
CLAUDE_AGENTS_DIR="$CLAUDE_DIR/agents"
ZED_DIR="$HOME/.config/zed"
ZED_AGENTS_FILE="$ZED_DIR/AGENTS.md"
ZED_SKILLS_DIR="$HOME/.agents/skills"

ACTION="${1:-install}"
MODE=""

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

prune_dangling() {
  local dir="$1" l
  [[ -d "$dir" ]] || return 0
  for l in "$dir"/*; do
    if [[ -L "$l" && ! -e "$l" && "$(readlink "$l")" == "$REPO_DIR"/* ]]; then
      rm "$l"
      ok "pruned stale $l"
    fi
  done
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

choose_mode() {
  [[ -n "$MODE" ]] && return 0
  if [[ ! -t 0 ]]; then
    MODE="overwrite"
    return 0
  fi
  local ans
  printf '\n  1) Delete all other skills\n  2) Overwrite (keep other skills)\n'
  read -rp "Select [1/2] (default 2): " ans
  case "$ans" in
    1) MODE="clean" ;;
    ""|2) MODE="overwrite" ;;
    *) err "Invalid choice: $ans"; exit 1 ;;
  esac
}

purge_skills() {
  local d b
  for d in "$COPILOT_SKILLS_DIR" "$CLAUDE_SKILLS_DIR" "$ZED_SKILLS_DIR"; do
    if [[ -L "$d" ]]; then
      rm "${d:?}"
    elif [[ -d "$d" ]]; then
      find "${d:?}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    fi
    for b in "$d".backup.*; do
      [[ -e "$b" || -L "$b" ]] && rm -rf "${b:?}"
    done
  done
  ok "deleted all existing skills"
}

do_install() {
  choose_mode
  info "Installing from $REPO_DIR ($MODE)"
  [[ "$MODE" == "clean" ]] && purge_skills

  mkdir -p "$COPILOT_INSTRUCTIONS_DIR" "$COPILOT_SKILLS_DIR" "$CLAUDE_DIR" "$ZED_DIR"

  # --- Instructions (copilot.instructions.md is the single source of truth) ---
  link "$REPO_DIR/copilot.instructions.md" "$COPILOT_INSTRUCTIONS_FILE"

  # Claude's CLAUDE.md also points to the same file
  if [[ -L "$CLAUDE_INSTRUCTIONS_FILE" && "$(readlink "$CLAUDE_INSTRUCTIONS_FILE")" == *copilot.instructions.md* ]]; then
    ok "CLAUDE.md already linked → $(readlink "$CLAUDE_INSTRUCTIONS_FILE")"
  else
    link "$COPILOT_INSTRUCTIONS_FILE" "$CLAUDE_INSTRUCTIONS_FILE"
  fi

  # --- Skill router index (SKILLS.md → ~/.copilot/skills/SKILLS.md) ---
  link "$REPO_DIR/SKILLS.md" "$COPILOT_SKILLS_DIR/SKILLS.md"

  # --- Skills (repo skill dirs → ~/.copilot/skills, then Claude links to Copilot) ---
  prune_dangling "$COPILOT_SKILLS_DIR"
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

  # --- Agents (repo agents/ → ~/.copilot/agents, then Claude links to Copilot) ---
  if [[ -d "$REPO_DIR/agents" ]]; then
    if [[ -L "$COPILOT_AGENTS_DIR" && "$(readlink "$COPILOT_AGENTS_DIR")" == "$REPO_DIR/agents" ]]; then
      ok "Copilot agents already linked → $REPO_DIR/agents"
    else
      link "$REPO_DIR/agents" "$COPILOT_AGENTS_DIR"
    fi
    if [[ -L "$CLAUDE_AGENTS_DIR" && "$(readlink "$CLAUDE_AGENTS_DIR")" == "$COPILOT_AGENTS_DIR" ]]; then
      ok "Claude agents already linked → $COPILOT_AGENTS_DIR"
    else
      link "$COPILOT_AGENTS_DIR" "$CLAUDE_AGENTS_DIR"
    fi
  fi

  # --- Zed (personal AGENTS.md + per-skill links at ~/.agents/skills) ---
  if [[ -L "$ZED_AGENTS_FILE" && "$(readlink "$ZED_AGENTS_FILE")" == *copilot.instructions.md* ]]; then
    ok "Zed AGENTS.md already linked → $(readlink "$ZED_AGENTS_FILE")"
  else
    link "$COPILOT_INSTRUCTIONS_FILE" "$ZED_AGENTS_FILE"
  fi
  mkdir -p "$ZED_SKILLS_DIR"
  prune_dangling "$ZED_SKILLS_DIR"
  for skill_dir in "$REPO_DIR"/*/; do
    local name
    name="$(basename "$skill_dir")"
    [[ "$name" == ".git" || "$name" == ".github" ]] && continue
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    link "$REPO_DIR/$name" "$ZED_SKILLS_DIR/$name"
  done

  ok "Done. Skills, agents & instructions are now shared across Copilot, Claude and Zed."
}

do_unlink() {
  info "Unlinking all symlinks"
  unlink_path "$COPILOT_INSTRUCTIONS_FILE"
  unlink_path "$CLAUDE_INSTRUCTIONS_FILE"
  unlink_path "$COPILOT_SKILLS_DIR/SKILLS.md"
  for skill_dir in "$REPO_DIR"/*/; do
    local name
    name="$(basename "$skill_dir")"
    [[ "$name" == ".git" || "$name" == ".github" ]] && continue
    unlink_path "$COPILOT_SKILLS_DIR/$name"
  done
  unlink_path "$CLAUDE_SKILLS_DIR"
  unlink_path "$CLAUDE_AGENTS_DIR"
  unlink_path "$COPILOT_AGENTS_DIR"
  unlink_path "$ZED_AGENTS_FILE"
  for skill_dir in "$REPO_DIR"/*/; do
    local name
    name="$(basename "$skill_dir")"
    [[ "$name" == ".git" || "$name" == ".github" ]] && continue
    unlink_path "$ZED_SKILLS_DIR/$name"
  done
  ok "Unlinked."
}

do_status() {
  info "Current link state"
  status_path "$COPILOT_INSTRUCTIONS_FILE"
  status_path "$CLAUDE_INSTRUCTIONS_FILE"
  status_path "$COPILOT_SKILLS_DIR/SKILLS.md"
  for skill_dir in "$REPO_DIR"/*/; do
    local name
    name="$(basename "$skill_dir")"
    [[ "$name" == ".git" || "$name" == ".github" ]] && continue
    status_path "$COPILOT_SKILLS_DIR/$name"
  done
  status_path "$CLAUDE_SKILLS_DIR"
  status_path "$COPILOT_AGENTS_DIR"
  status_path "$CLAUDE_AGENTS_DIR"
  status_path "$ZED_AGENTS_FILE"
  for skill_dir in "$REPO_DIR"/*/; do
    local name
    name="$(basename "$skill_dir")"
    [[ "$name" == ".git" || "$name" == ".github" ]] && continue
    status_path "$ZED_SKILLS_DIR/$name"
  done
}

case "$ACTION" in
  install)     do_install ;;
  --clean)     MODE="clean"; do_install ;;
  --overwrite) MODE="overwrite"; do_install ;;
  --unlink) do_unlink   ;;
  --status) do_status   ;;
  *)
    err "Usage: $0 [install|--clean|--overwrite|--unlink|--status]"
    exit 1
    ;;
esac