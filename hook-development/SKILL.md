---
name: hook-development
description: "Guide for creating, configuring, and debugging Claude Code plugin hooks and Hookify rules for event-driven automation. Use when you need to add PreToolUse, PostToolUse, Stop, SessionStart, or other lifecycle hooks, write Hookify rule files, configure hooks.json or .claude/settings.json, set matchers, handle stdin and stdout, use exit codes, or block unsafe commands, file edits, prompts, and session stops."
---

# Hook Development for Claude Code Plugins

Create event‑driven automation that runs before, after, or during Claude Code operations. Includes prompt‑based and command hooks, configuration formats, security practices, and Hookify rule syntax for pattern‑based warnings and blocks.

## When to Use
- Add validation, policy enforcement, or context loading to tool calls (`PreToolUse`, `PostToolUse`).
- Verify task completeness before the agent stops (`Stop`, `SubagentStop`).
- Run scripts when a session starts or ends (`SessionStart`, `SessionEnd`).
- React to user prompts (`UserPromptSubmit`).
- Write Hookify rules to warn or block dangerous Bash commands, file edits, or prompt content.

---

## Hook Types
| Type | When to Prefer | Example |
|------|----------------|---------|
| **Prompt** | Complex, context‑aware decisions; easy to maintain. | `{ "type": "prompt", "prompt": "Validate $TOOL_INPUT for safety.", "timeout": 30 }` |
| **Command** | Fast, deterministic checks; file system or external tool integration. | `{ "type": "command", "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh", "timeout": 60 }` |

## Configuration Formats
### Plugin `hooks/hooks.json` (wrapper)
```json
{
  "description": "Optional description",
  "hooks": {
    "PreToolUse": [ ... ],
    "Stop": [ ... ],
    "SessionStart": [ ... ]
  }
}
```
### User Settings `.claude/settings.json` (direct)
```json
{
  "PreToolUse": [ ... ],
  "Stop": [ ... ]
}
```
*Only the `hooks` object is required for plugins; settings omit the wrapper.*

## Hook Events and Typical Use Cases
| Event | Typical Use |
|-------|-------------|
| **PreToolUse** | Approve, deny, or modify a tool call before it runs. |
| **PostToolUse** | Analyse results, log, or provide feedback after a tool finishes. |
| **Stop** | Ensure tests passed, build succeeded, or required steps are done before the agent stops. |
| **SubagentStop** | Same as `Stop` but for a sub‑agent. |
| **UserPromptSubmit** | Validate or enrich a user prompt before Claude processes it. |
| **SessionStart** | Load project context, set environment variables. |
| **SessionEnd** | Cleanup, archive logs, persist state. |
| **PreCompact** | Add critical information before context compaction. |
| **Notification** | React to Claude‑generated notifications. |

### Example: PreToolUse Prompt Hook
```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "Validate file write safety. Check for system paths, credentials, or path traversal. Return 'allow' or 'deny'."
        }
      ]
    }
  ]
}
```
**Expected output** (sent to Claude):
```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow|deny",
    "updatedInput": { "field": "new_value" }
  },
  "systemMessage": "Explanation for Claude"
}
```

## Hook Input & Output Formats
### Input (via stdin)
All hooks receive a JSON object. Common fields:
```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.txt",
  "cwd": "/project/root",
  "permission_mode": "ask|allow",
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": { "file_path": "src/main.js", "content": "..." }
}
```
Event‑specific fields are added as shown above.

### Standard Output (stdout)
```json
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "Message shown to Claude"
}
```
- `continue`: `false` stops further processing.
- `suppressOutput`: `true` hides the hook’s stdout from the transcript.
- `systemMessage`: Optional text that Claude can display.

### Exit Codes
- `0` – Success (stdout shown).
- `2` – Blocking error (stderr fed back to Claude, halts operation).
- Other – Non‑blocking error, logged but processing continues.

## Environment Variables (available to command hooks)
- `${CLAUDE_PROJECT_DIR}` – Root of the current project.
- `${CLAUDE_PLUGIN_ROOT}` – Directory of the plugin (use for portable paths).
- `${CLAUDE_ENV_FILE}` – Only during `SessionStart`; append `export VAR=value` to persist env vars.
- `${CLAUDE_CODE_REMOTE}` – Set when running in a remote environment.

## Matchers
Define which tools a hook applies to.
```json
"matcher": "Write"               // exact match
"matcher": "Read|Write|Edit"    // multiple tools
"matcher": "*"                  // all tools
"matcher": "mcp__.*__delete.*" // regex pattern (case‑sensitive)
```
Use the pipe (`|`) to separate alternatives.

## Security Best Practices
1. **Validate all inputs** in command hooks. Example Bash snippet:
   ```bash
   set -euo pipefail
   input=$(cat)
   tool_name=$(echo "$input" | jq -r '.tool_name')
   [[ "$tool_name" =~ ^[a-zA-Z0-9_]+$ ]] || { echo '{"decision":"deny","reason":"Invalid tool name"}' >&2; exit 2; }
   ```
2. **Prevent path traversal** and protect sensitive files:
   ```bash
   file_path=$(echo "$input" | jq -r '.tool_input.file_path')
   [[ "$file_path" != *".."* ]] || { echo '{"decision":"deny","reason":"Path traversal"}' >&2; exit 2; }
   [[ "$file_path" != *.env* ]] && [[ "$file_path" != *.pem* ]] || { echo '{"decision":"deny","reason":"Sensitive file"}' >&2; exit 2; }
   ```
3. **Quote all variables** to avoid injection.
4. **Set reasonable timeouts** (`timeout` field). Defaults: 30 s for prompt hooks, 60 s for command hooks.

## Performance & Parallelism
- All matching hooks for an event run **in parallel**; they cannot see each other’s output.
- Use fast command hooks for simple checks; reserve prompt hooks for reasoning‑heavy validation.
- Cache expensive results in temporary files if needed.

## Temporarily Active Hooks
Activate a hook only when a flag file exists:
```bash
FLAG_FILE="$CLAUDE_PROJECT_DIR/.enable-strict-validation"
[ -f "$FLAG_FILE" ] || exit 0   # skip when flag missing
# ... validation logic ...
```
Or read a JSON config to toggle behavior.

## Hook Lifecycle
1. Hooks are loaded **once** at `SessionStart`.
2. Changing `hooks/hooks.json` or script files requires **restarting** Claude Code.
3. Invalid JSON or missing scripts abort loading; use `claude --debug` to see errors.

## Debugging Hooks
- Run Claude with `claude --debug` to view registration, input JSON, output JSON, and timing.
- Test command hooks directly:
  ```bash
  echo '{"tool_name":"Write","tool_input":{"file_path":"test.txt"}}' |
  bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh
  echo "Exit: $?"
  ```
- Validate JSON output with `jq .`.

---

## Writing Hookify Rules
Hookify rules are markdown files with YAML front‑matter that trigger on specific events and display a message to Claude.

### File Location & Naming
- Place files in the project root under `.claude/`.
- Name them `hookify.{rule-name}.local.md` (e.g., `hookify.dangerous-rm.local.md`).
- Add `.claude/*.local.md` to `.gitignore` if you don’t want them in VCS.

### Minimal Rule Structure
```markdown
---
name: rule-identifier          # kebab‑case, unique
enabled: true                 # false to disable
event: bash|file|stop|prompt|all
pattern: regex-pattern-here   # simple single‑condition pattern
---
Message shown to Claude when the rule matches.
```
**Fields**
- `name` – required, descriptive identifier.
- `enabled` – required, boolean.
- `event` – required, the hook event the rule applies to.
- `action` – optional, `warn` (default) or `block`.
- `pattern` – simple regex applied to the relevant field (see below).

### Advanced Rules with Multiple Conditions
```markdown
---
name: warn-env-file-edits
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(env|pem)$
  - field: new_text
    operator: contains
    pattern: API_KEY
---
You are adding an API key to a sensitive file. Ensure the file is excluded from version control.
```
**Condition fields**
- `field` – which input attribute to test (`command` for bash, `file_path`, `new_text`, `old_text`, `content` for file events, `user_prompt` for prompt events).
- `operator` – `regex_match`, `contains`, `equals`, `not_contains`, `starts_with`, `ends_with`.
- `pattern` – pattern or literal string.
All conditions must be satisfied for the rule to fire.

### Message Body Guidelines
- Explain what was detected and why it matters.
- Offer concrete alternatives or best practices.
- Use markdown formatting (bold, lists, checkboxes) for readability.

**Example Message**
```markdown
⚠️ **Dangerous `rm -rf` detected!**

Removing files recursively can erase important data.

**Recommendations**
- Review the path before execution.
- Use version control to recover accidental deletions.
```

### Common Event Patterns
| Event | Typical Fields | Example Pattern |
|-------|----------------|-----------------|
| `bash` | `command` | `rm\s+-rf` (dangerous delete) |
| `file` | `new_text`, `file_path` | `console\.log\(` (debug logs) |
| `stop` | any | `.*` (run checklist before stop) |
| `prompt` | `user_prompt` | `deploy to production` |

### Regex Tips
- Escape special characters (`.` → `\.` , `(` → `\(` ).
- Use `\s` for whitespace, `+` for one‑or‑more, `*` for zero‑or‑more.
- Test patterns with Python or an online tester before committing:
  ```bash
  python3 - <<'PY'
  import re, sys
  print(bool(re.search(r'rm\s+-rf', 'rm -rf /tmp')))
  PY
  ```

### Enabling / Disabling Rules
- Set `enabled: false` to turn a rule off without deleting it.
- Delete the `.local.md` file to remove the rule permanently.

---

## Checklist for Adding a New Hook or Hookify Rule
- [ ] Choose the correct **event** (`PreToolUse`, `Stop`, etc.).
- [ ] Decide between **prompt** (LLM) or **command** (bash) hook type.
- [ ] Write a **matcher** that targets the intended tools.
- [ ] For command hooks, validate all JSON input fields and quote variables.
- [ ] Set a sensible **timeout** (default 30 s prompt, 60 s command).
- [ ] Add the hook definition to `hooks/hooks.json` (plugin) **or** `.claude/settings.json` (user).
- [ ] If using Hookify, create `.claude/hookify.{name}.local.md` with required front‑matter.
- [ ] Test the hook/script directly with sample JSON.
- [ ] Restart Claude Code to load changes.
- [ ] Run `claude --debug` and verify input/output logs.
- [ ] Ensure the hook outputs valid JSON and respects exit‑code conventions.
- [ ] Document the purpose, activation flag, and any environment variables in the plugin README.

---

**References**
- Official hook docs: https://docs.claude.com/en/docs/claude-code/hooks
- Use `jq` to inspect JSON payloads.
- For complex validation, prefer prompt hooks; for speed, use command hooks.

## Related skills

Load these when the task spans more than this skill.

- [`claude-code-guide`](../claude-code-guide/SKILL.md) — Guide for configuring Claude Code projects, using prompting keywords, debugging the agent, and applying best‑p…
- [`slash-command-development`](../slash-command-development/SKILL.md) — Defines how to create, configure, and organize Claude Code slash commands. Covers file locations, YAML frontma…
- [`skill-authoring`](../skill-authoring/SKILL.md) — Skill Authoring guides you through designing, writing, testing, evaluating, and refining Claude skills. Use it…
- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`mcp-development`](../mcp-development/SKILL.md) — Guide for building, testing, and integrating Model Context Protocol (MCP) servers. Use when creating a new MCP…
