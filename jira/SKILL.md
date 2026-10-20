---
name: jira
description: "Manage Jira issues, tickets, sprints, and boards through the jira CLI or Atlassian MCP tools, including search, create, update, transition, comment, assign, and status checks. Use when the user mentions Jira, Atlassian, an issue key like PROJ-123, ticket, story, bug, task, epic, sprint, backlog, board, JQL, assignee, priority, label, status, comment, transition, create issue, update issue, close ticket, reopen, move ticket, sprint status, or errors such as issue not found, permission denied, and invalid transition."
---

# Jira

Interact with Jira from the command line. The skill supports two back‑ends: the **jira CLI** and **Atlassian MCP** tools. Choose the back‑end that is installed on the host before running any operation.

## When to use
- The user mentions an issue key like `PROJ-123`.
- The user asks to create, view, list, update, transition, or comment on a ticket.
- The user wants sprint or backlog information.
- The user asks for a quick JQL search.

---

## Backend detection
1. Run `which jira`.
   - If the command is found, use the **CLI** back‑end.
2. If the CLI is not found, look for any `mcp__atlassian__*` tools in the environment.
   - If such tools exist, use the **MCP** back‑end.
3. If neither is available, guide the user to install one of them (see *No backend available*).

---

## Quick reference
### CLI commands
| Intent | Command |
|--------|---------|
| View issue | `jira issue view ISSUE-KEY` |
| Open in browser | `jira open ISSUE-KEY` |
| List my issues | `jira issue list -a$(jira me)` |
| List my in‑progress issues | `jira issue list -a$(jira me) -s"In Progress"` |
| Create issue | `jira issue create -tTYPE -s"SUMMARY" -b"DESCRIPTION"` |
| Transition (move) issue | `jira issue move ISSUE-KEY "TRANSITION"` |
| Assign to me | `jira issue assign ISSUE-KEY $(jira me)` |
| Unassign | `jira issue assign ISSUE-KEY x` |
| Add comment | `jira issue comment add ISSUE-KEY -b"COMMENT TEXT"` |
| Show current sprint | `jira sprint list --state active` |
| Who am I (account ID) | `jira me` |

### MCP commands
| Intent | MCP tool |
|--------|----------|
| Search issues (JQL) | `mcp__atlassian__searchJiraIssuesUsingJql` |
| Get issue details | `mcp__atlassian__getJiraIssue` |
| Create issue | `mcp__atlassian__createJiraIssue` |
| Update issue | `mcp__atlassian__editJiraIssue` |
| List transitions | `mcp__atlassian__getTransitionsForJiraIssue` |
| Apply transition | `mcp__atlassian__transitionJiraIssue` |
| Add comment | `mcp__atlassian__addCommentToJiraIssue` |
| Lookup account ID | `mcp__atlassian__lookupJiraAccountId` |
| List visible projects | `mcp__atlassian__getVisibleJiraProjects` |

---

## Issue key detection
Issue keys match the regular expression `[A-Z]+-[0-9]+` (e.g., `PROJ-123`). When a key is detected:
- **CLI** – use `jira issue view KEY` or `jira open KEY`.
- **MCP** – call `mcp__atlassian__getJiraIssue` with the key.

---

## Common workflows
### Creating a ticket
1. Ask the user for required fields: project key, issue type, summary, description, optional fields.
2. Draft the ticket content and show it to the user for confirmation.
3. Run the appropriate create command.
4. Verify the new issue appears and share the key with the user.

### Updating a ticket
1. Fetch the current issue data.
2. Show the existing values that will change.
3. Ask the user to confirm each change.
4. Apply the update (field edit, comment, or transition).
5. Retrieve the issue again to confirm the change.

---

## Rules & checklist before any modification
- **Fetch first** – always retrieve the issue to know its current status, assignee, and fields.
- **Identify stakeholders** – check watchers, linked issues, and parent epics; a change may notify many people.
- **Validate identifiers** – use issue keys, transition IDs, and account IDs (MCP requires IDs, not display names).
- **Confirm reversibility** – some transitions are one‑way; ensure the user understands the impact.
- **Obtain explicit approval** – never apply a change without the user’s confirmation.
- **Show the exact command** – display the full CLI or MCP call before execution.

---

## Things to never do
- Transition an issue without first checking its current status.
- Assign using a display name with MCP; always resolve the account ID first.
- Edit the description without showing the original text.
- Use `--no-input` (CLI) when required fields are missing.
- Assume transition names are the same across projects; always query available transitions.
- Perform bulk edits without explicit user consent.

---

## Safety practices
- Display the command that will run and wait for user approval.
- Preserve the original field values in the output for review.
- After any write operation, fetch the issue again to verify the change.
- If authentication fails, surface the error clearly and suggest re‑authenticating.

---

## No backend available
If the host lacks both the jira CLI and MCP tools, advise the user to install one:

**Jira CLI** (recommended)
```bash
# macOS with Homebrew
brew install ankitpokhrel/jira-cli/jira-cli
# Initialise configuration
jira init
```

**Atlassian MCP**
- Install the MCP package according to your organization’s guidelines.
- Configure Atlassian credentials in the MCP settings.

---

## Checklist (run before any operation)
- [ ] Detect which backend is present.
- [ ] Verify authentication works (`jira me` or MCP account lookup).
- [ ] Fetch the target issue and display current fields.
- [ ] List available transitions if a state change is requested.
- [ ] Show the exact command that will be executed.
- [ ] Obtain user confirmation.
- [ ] Execute the command.
- [ ] Re‑fetch the issue and confirm the expected outcome.

## Related skills

Load these when the task spans more than this skill.

- [`git-branch-workflow`](../git-branch-workflow/SKILL.md) — The git-branch-workflow skill creates an isolated Git worktree for a new feature branch, runs project setup an…
- [`git-commit`](../git-commit/SKILL.md) — Generate conventional commit messages by analyzing staged changes, suggesting type, scope, and wording, and gu…
- [`product-management`](../product-management/SKILL.md) — A comprehensive product‑management skill that guides product managers, strategists, and agile owners through d…
- [`planning`](../planning/SKILL.md) — Creates a concise atomic implementation plan for a coding task, expands it into a detailed step‑by‑step plan w…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
- [`professional-communication`](../professional-communication/SKILL.md) — Provides frameworks, templates, and checklists for writing professional emails, internal updates, chat message…
