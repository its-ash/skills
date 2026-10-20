---
name: slash-command-development
description: "Teaches how to author, configure, and organize Claude Code slash commands including .md file placement in .claude/commands, YAML frontmatter fields like description and argument-hint, dynamic argument patterns $ARGUMENTS and $1-$9, @ file references, ! bash execution, naming conventions, validation checklist, and namespaced folder structures for large command sets. Use when building custom slash commands, editing command markdown files, writing frontmatter yaml, passing positional arguments or remainder capture, referencing project files with @ syntax, running shell commands via ! prefix, structuring flat or namespaced command directories, debugging command parsing errors, or following the validation checklist before committing command definitions."
---

# Slash Command Development for Claude Code

Create reusable, consistent workflows by defining commands as Markdown files. Use this guide when you need to add a new slash command, define arguments, include file contents, run Bash snippets, or organize a large command set.

## When to Use
- You want a `/command-name` that Claude can run repeatedly.
- You need to accept arguments, reference project files, or execute Bash.
- You are organizing many commands for a project, personal use, or a plugin.
- You want to enforce best‑practice patterns and validation.

---

## File Locations
| Scope | Directory | Visibility |
|-------|-----------|-------------|
| Project | `.claude/commands/` | Available to the current project only |
| Personal | `~/.claude/commands/` | Available in all projects |
| Plugin | `plugin-name/commands/` | Available when the plugin is installed |

Place each command in a file with a `.md` extension. The file name becomes the command name (e.g., `review.md` → `/review`).

---

## Basic File Structure
```text
.claude/commands/
├── review.md          # /review
├── test.md            # /test
└── deploy.md          # /deploy
```
A simple command can contain only the prompt text. No frontmatter is required.

---

## YAML Frontmatter Fields
Add a frontmatter block at the top of the file to configure the command.

```yaml
---
description: Brief description shown in /help
allowed-tools: Read, Bash(git:*)
model: sonnet
argument-hint: [pr-number] [priority] [assignee]
disable-model-invocation: false
---
```
| Field | Type | Default | When to Set |
|-------|------|---------|-------------|
| `description` | string | First line of prompt | Always provide a concise, actionable description (≤60 chars). |
| `allowed-tools` | string or array | Inherit from conversation | Limit tools the command may use (e.g., `Bash(git:*)`). |
| `model` | string (`sonnet`, `opus`, `haiku`) | Inherit from conversation | Choose a faster or more capable model for the command. |
| `argument-hint` | string | None | Document expected arguments for autocomplete. |
| `disable-model-invocation` | boolean | `false` | Prevent the command from being called programmatically. |

---

## Dynamic Arguments
### Capture All Arguments
Use `$ARGUMENTS` to insert the full argument string.
```markdown
---
description: Fix issue by number
argument-hint: [issue-number]
---
Fix issue #$ARGUMENTS following coding standards.
```
### Positional Arguments
Use `$1`, `$2`, … for individual arguments.
```markdown
---
description: Review PR with priority and assignee
argument-hint: [pr-number] [priority] [assignee]
---
Review PR #$1 with priority $2.
Assign to $3 after review.
```
### Combine Positional and Remainder
```markdown
Deploy $1 to $2 environment with options: $3
```
Invoked as `/deploy api staging --force`.

---

## File References (`@` Syntax)
Insert the contents of a file into the prompt.
```markdown
---
description: Review a source file
argument-hint: [file-path]
---
Review @$1 for code quality and bugs.
```
Multiple references are allowed:
```markdown
Compare @src/old.js with @src/new.js.
Identify breaking changes.
```
Static references (no arguments) are also possible.

---

## Bash Execution
Run a Bash command inline using back‑ticks prefixed with `!`.
```markdown
---
allowed-tools: Bash(git:*)
---
Changed files: !`git diff --name-only`
Review each file for issues.
```
**Guidelines**
- Include the required `Bash(...)` entry in `allowed-tools`.
- Limit scope (`Bash(git:*)` instead of `Bash(*)`).
- Avoid destructive commands.
- Capture errors and handle them gracefully.

---

## Command Organization
### Flat Structure (5‑15 commands)
```
.claude/commands/
├── build.md
├── test.md
├── deploy.md
└── review.md
```
### Namespaced Structure (15+ commands)
```
.claude/commands/
├── ci/
│   ├── build.md   # /ci/build
│   └── lint.md    # /ci/lint
├── git/
│   ├── commit.md  # /git/commit
│   └── pr.md      # /git/pr
└── docs/
    ├── generate.md # /docs/generate
    └── publish.md  # /docs/publish
```
Namespaces appear in `/help` and prevent name clashes.

---

## Best Practices
1. **Single responsibility** – each command does one clear task.
2. **Clear description** – concise, actionable text for `/help`.
3. **Explicit tool list** – set `allowed-tools` only when needed.
4. **Document arguments** – always provide `argument-hint`.
5. **Consistent naming** – use `verb-noun` (e.g., `review-pr`).
6. **Validate early** – check arguments and files before main work.
7. **Safe Bash** – restrict to needed commands, capture errors.
8. **Add comments** – use HTML comments for usage notes.

---

## Common Patterns
### Review Pattern
```markdown
---
description: Review changed files
allowed-tools: Read, Bash(git:*)
---
Files changed: !`git diff --name-only`
Review each file for style, bugs, and test coverage.
```
### Testing Pattern
```markdown
---
description: Run tests for a file
argument-hint: [test-file]
allowed-tools: Bash(npm:*)
---
Run tests: !`npm test $1`
Analyze failures and suggest fixes.
```
### Documentation Pattern
```markdown
---
description: Generate docs for a source file
argument-hint: [source-file]
---
Generate documentation for @$1 including:
- Function descriptions
- Parameters
- Return values
- Usage examples
```
### Workflow Pattern
```markdown
---
description: Complete PR workflow
argument-hint: [pr-number]
allowed-tools: Bash(gh:*), Read
---
PR #$1 steps:
1. Fetch: !`gh pr view $1`
2. Review changes
3. Run checks
4. Approve or request changes
```
---

## Validation Patterns
### Argument Validation
```markdown
---
description: Deploy with environment validation
argument-hint: [environment]
---
Validate: !`echo "$1" | grep -E "^(dev|staging|prod)$" || echo "INVALID"`
$IF($1 == "INVALID",
  Explain: "Valid environments: dev, staging, prod. Usage: /deploy [environment]",
  Deploy to $1
)
```
### File Existence Check
```markdown
---
description: Process config file
argument-hint: [config-file]
---
Check: !`test -f $1 && echo "EXISTS" || echo "MISSING"`
$IF($1 == "MISSING",
  Explain: "Place the config at $1 and ensure correct JSON format.",
  Process: @${1}
)
```
### Bash Error Handling
```markdown
---
description: Build with error handling
allowed-tools: Bash(*)
---
Build: !`bash build.sh 2>&1 || echo "BUILD_FAILED"`
$IF($BUILD_FAILED,
  Explain: "Build failed. Review the error output above.",
  Report: "Build succeeded. Output at ./dist"
)
```
---

## Checklist
- [ ] File saved with `.md` extension in the correct directory.
- [ ] Command name matches file name.
- [ ] Frontmatter includes a concise `description`.
- [ ] `allowed-tools` lists only needed tools.
- [ ] `argument-hint` accurately reflects expected arguments.
- [ ] Dynamic arguments use `$ARGUMENTS` or `$1`, `$2`, … correctly.
- [ ] File references use `@` with valid relative paths.
- [ ] Bash snippets are wrapped in `!\`...\`` and have matching `allowed-tools`.
- [ ] Validation steps handle missing arguments or files.
- [ ] Command follows single‑responsibility and naming conventions.
- [ ] Tested in Claude Code; appears in `/help`.

## Related skills

Load these when the task spans more than this skill.

- [`claude-code-guide`](../claude-code-guide/SKILL.md) — Guide for configuring Claude Code projects, using prompting keywords, debugging the agent, and applying best‑p…
- [`hook-development`](../hook-development/SKILL.md) — Guide for creating, configuring, and debugging Claude Code plugin hooks and Hookify rules. Use when you need t…
- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
- [`bash-scripting`](../bash-scripting/SKILL.md) — Bash Scripting – a concise guide for writing safe, production‑ready Bash scripts on Linux/macOS. Includes comm…
- [`skill-authoring`](../skill-authoring/SKILL.md) — Skill Authoring guides you through designing, writing, testing, evaluating, and refining Claude skills. Use it…
- [`mcp-development`](../mcp-development/SKILL.md) — Guide for building, testing, and integrating Model Context Protocol (MCP) servers. Use when creating a new MCP…
