---
name: ai-cli-delegation
description: "Delegates user requests to Gemini CLI or Codex CLI, selecting the model, sandbox, and approval mode, running commands safely in background or interactive mode, capturing output, and reporting results. Use when asked to run gemini, codex, ai cli, command-line agent, sandboxed code review, apply edits, resume session, background job, or delegate a task to terminal AI."
---

# AI CLI Delegation

Use this skill when a user asks to run an AI‑powered CLI (Gemini or Codex) for code review, plan analysis, or large‑context processing. The skill selects the right model, configures safety flags, runs the command (optionally with a timeout), captures the output, and informs the user.

---

## When to Use
- The user explicitly requests a Gemini or Codex CLI operation.
- The task needs more than a few hundred tokens of context (e.g., whole repository, architectural plan).
- The user wants automated background analysis (CI, batch jobs) **or** an interactive terminal session.
- The user asks for a professional code review, refactoring, security audit, or changelog generation.

---

## Workflow
1. **Identify the tool** – Gemini for large‑context, multi‑file analysis; Codex for focused code analysis or edit automation.
2. **Ask the user** (single prompt) which model they prefer. Offer the default flagship model:
   - Gemini: `gemini-3-pro-preview`
   - Codex: `gpt-5.2`
3. **Determine execution mode**
   - **Background / non‑interactive** – use fully automated approval (`yolo`).
   - **Interactive terminal** – use `default` (Gemini) or `auto_edit` for edit‑focused runs.
4. **Select sandbox / safety flags**
   - Codex: `--sandbox read-only` for review, `workspace-write` for edits, `danger-full-access` only if the user explicitly permits.
   - Gemini: optional `-s/--sandbox` for isolation; not required for most reviews.
5. **Build the command** – include model flag, approval mode, sandbox, directory includes, and the user‑provided prompt.
6. **Add a timeout** for background runs (`timeout 300 …`).
7. **Execute** the command, capture `stdout` and (if not suppressed) `stderr`.
8. **Summarize** the result for the user and ask if they want a follow‑up, a resume, or further analysis.
9. **Handle errors** – if the CLI exits non‑zero, report the error and request direction before retrying.

---

## Model Selection Guide
| Tool | Model | Best For | Context Window |
|------|-------|----------|----------------|
| Gemini | `gemini-3-pro-preview` ⭐ | Complex reasoning, security, performance reviews | 1 M input / 64 k output |
| Gemini | `gemini-3-flash` | Speed‑critical, low‑latency tasks | 1 M / 64 k |
| Gemini | `gemini-2.5-pro` | Legacy stable runs | 1 M / 65 k |
| Codex | `gpt-5.2` ⭐ | General software‑engineering tasks, agentic workflows | 400 k / 128 k |
| Codex | `gpt-5.2-max` | Ultra‑complex analysis, deep reasoning | 400 k / 128 k |
| Codex | `gpt-5.2-mini` | Cost‑optimized high‑volume jobs | 400 k / 128 k |

When the user does not specify a model, default to the flagship model (`gemini-3-pro-preview` or `gpt-5.2`).

---

## Approval / Sandbox Flags
### Gemini CLI
| Mode | Flag | When to Use |
|------|------|-------------|
| Interactive (terminal) | `--approval-mode default` | Only when a real terminal is present and the user can answer prompts. |
| Auto‑edit (code suggestions) | `--approval-mode auto_edit` | Background review that may generate edit suggestions but should not apply them automatically. |
| Fully automated | `--approval-mode yolo` or `-y` | All background or CI runs. |
| Sandbox isolation | `-s` or `--sandbox` | Optional; use when the user wants strict isolation. |

### Codex CLI
| Sandbox | Flag | When to Use |
|---------|------|-------------|
| Read‑only review | `--sandbox read-only` | Default for analysis without file changes. |
| Write edits | `--sandbox workspace-write` | When the user authorizes code modifications. |
| Full access (network, system) | `--sandbox danger-full-access` | Only after explicit user permission. |
| Auto execution | `--full-auto` | Combine with a write sandbox to let Codex apply edits automatically. |
| Skip repo check | `--skip-git-repo-check` | Always include unless the user asks otherwise. |

---

## Command Templates
### Gemini (background)
```bash
# Example: security review of entire repo
timeout 300 gemini -m gemini-3-pro-preview \
  --approval-mode yolo \
  "Review this codebase for security vulnerabilities, performance issues, and code‑quality violations"
```
### Gemini (interactive)
```bash
gemini -m gemini-3-pro-preview \
  --approval-mode default \
  -i "Review the authentication module for OWASP compliance"
```
### Codex (read‑only review)
```bash
# Suppress thinking tokens unless debugging is requested
codex exec --model gpt-5.2 \
  --config model_reasoning_effort="high" \
  --sandbox read-only \
  --skip-git-repo-check 2>/dev/null \
  "Perform a comprehensive code review focusing on security and performance"
```
### Codex (apply edits)
```bash
codex exec --model gpt-5.2 \
  --config model_reasoning_effort="high" \
  --sandbox workspace-write \
  --full-auto \
  --skip-git-repo-check 2>/dev/null \
  "Refactor the data‑access layer to use async/await and add type annotations"
```
### Codex (resume previous session)
```bash
# Pipe new prompt; inherits original model, sandbox, and reasoning effort
echo "Also update the logging format" | \
  codex exec --skip-git-repo-check resume --last 2>/dev/null
```
---

## Error Handling & Troubleshooting
- **Non‑zero exit**: Immediately stop, report the error code and any stderr, then ask the user how to proceed.
- **Hung Gemini process**: Detect with `ps` (process state `S`, 0 % CPU, >20 min). Resolve by killing:
  ```bash
  pkill -9 -f "gemini.*gemini-3-pro-preview"
  ```
- **Missing CLI**: Run `gemini --version` or `codex --version`. If the command fails, inform the user to install the required CLI version (Gemini v0.16+, Codex v0.57+).
- **Permission flags**: Never use `--approval-mode yolo`, `--full-auto`, or `danger-full-access` without explicit user consent.
- **Timeouts**: Always wrap background runs with `timeout 300` (5 min) unless the user requests a different limit.
- **Partial output**: Summarize warnings or incomplete sections and ask the user whether to retry, adjust the prompt, or continue.
---

## Checklist
- [ ] Identify whether the request is for Gemini or Codex.
- [ ] Ask the user for the preferred model (provide defaults).
- [ ] Determine execution mode (interactive vs background).
- [ ] Choose appropriate approval mode (`default`, `auto_edit`, `yolo`).
- [ ] Select sandbox level (`read-only`, `workspace-write`, `danger-full-access`).
- [ ] Build the CLI command with model, sandbox, approval, and user prompt.
- [ ] Add `timeout` for background runs.
- [ ] Execute the command and capture output.
- [ ] Verify exit status; on failure, report and ask for next steps.
- [ ] Summarize results for the user.
- [ ] Offer follow‑up actions (new Gemini session, Codex resume, changelog generation, etc.).
---

## Follow‑Up Actions
- **Start a new Gemini session** for deeper analysis of findings.
- **Resume a Codex session** with `codex exec resume --last` when the user wants to continue editing.
- **Generate a CHANGELOG**: after a Codex edit run, ask Codex to output a markdown list of changed files and a summary, then save to `CHANGELOG.md`.
- **Save structured reports**: request Gemini or Codex to format output as JSON or markdown tables for later reference.

---

*All commands assume the relevant CLI is installed and available in the PATH. Adjust paths or environment variables as needed for the target system.*

## Related skills

Load these when the task spans more than this skill.

- [`bash-scripting`](../bash-scripting/SKILL.md) — Bash Scripting – a concise guide for writing safe, production‑ready Bash scripts on Linux/macOS. Includes comm…
- [`background-jobs`](../background-jobs/SKILL.md) — Provides guidance for implementing reliable background jobs in Node.js/TypeScript using BullMQ, Trigger.dev, o…
- [`parallel-agents`](../parallel-agents/SKILL.md) — Parallel Agents skill lets you orchestrate multiple independent AI agents to work concurrently on separate pro…
- [`subagent-driven-development`](../subagent-driven-development/SKILL.md) — Subagent‑Driven Development runs an implementation plan by creating a fresh subagent for each independent task…
- [`indie-product-building`](../indie-product-building/SKILL.md) — A step‑by‑step guide for indie creators to turn a validated problem into a profitable product—whether an AI‑wr…
