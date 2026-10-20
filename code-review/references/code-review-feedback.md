# Code Review Feedback

Use this skill to request a code review after completing work and to process review comments responsibly. Follow the steps to capture the right commit range, communicate clearly, verify feedback, and apply changes safely.

## When to Use
- After finishing a task, feature, or bug fix.
- Before merging a branch to the main line.
- When you are stuck and need a fresh perspective.
- When you receive review comments, especially if they are unclear or seem questionable.

---

## Requesting a Review
### 1. Identify the commit range
```bash
# Base commit: the last known good point (e.g., origin/main or previous task commit)
BASE_SHA=$(git rev-parse HEAD~1)   # adjust as needed
# Head commit: the current tip of your work
HEAD_SHA=$(git rev-parse HEAD)
```
### 2. Prepare the review payload
Fill the placeholders below and send them to the `code-reviewer` sub‑agent (or your team’s review tool).
| Placeholder | Content |
|---|---|
| `{WHAT_WAS_IMPLEMENTED}` | Short description of the new code (e.g., "Added verifyIndex() and repairIndex() functions"). |
| `{PLAN_OR_REQUIREMENTS}` | Reference to the design, ticket, or specification the work should satisfy. |
| `{BASE_SHA}` | Commit hash from step 1. |
| `{HEAD_SHA}` | Commit hash from step 1. |
| `{DESCRIPTION}` | One‑sentence summary of the change. |
### 3. Dispatch the review
Use your automation tool (e.g., `Task` with `superpowers:code-reviewer`) or create a pull request that includes the above data.
### 4. Act on the returned feedback
- **Critical** – fix immediately before any other work.
- **Important** – fix before proceeding to the next task.
- **Minor** – note for later or fix if time permits.
- If you disagree, provide a concise technical reason and request clarification.

---

## Receiving Review Feedback
### Response Pattern
1. **Read** the entire comment set without reacting.
2. **Restate** each requirement in your own words. If you do not understand, ask for clarification.
3. **Verify** the suggestion against the current codebase.
4. **Evaluate** whether the change is technically sound for this project.
5. **Respond** with a factual acknowledgment or a reasoned push‑back.
6. **Implement** one item at a time, testing after each change.

### Forbidden Replies
- "You're absolutely right!"
- "Great point!"
- "Let me implement that now" (before verification)

### Correct Replies
- "I understand the requirement to …"
- "Can you clarify what you mean by …?"
- "I checked the code and the change would break X; here's an alternative…"
- "Fixed. Updated `utils.py` to handle edge case Y."

---

## Handling Unclear or Questionable Feedback
- **Stop** any implementation until you have clarification.
- **Ask** a focused question: "Do you mean X should be validated before Y?"
- **Check** for hidden context: search the repository (`git grep`, `grep`) to see if the suggested code path is exercised.
- **YAGNI Check** – if the reviewer asks for a feature that is never called, ask: "I grepped the codebase and found no callers for this endpoint. Should we keep it?"

### When to Push Back
- The suggestion breaks existing functionality.
- The reviewer lacks full context (e.g., platform constraints, legacy compatibility).
- The change violates a YAGNI principle.
- The suggestion conflicts with an architectural decision from your human partner.

**How to push back:**
- State the technical reason.
- Reference the specific test, file, or configuration.
- Offer an alternative if possible.
- Involve your human partner if the decision is strategic.

---

## Implementation Order for Multiple Items
1. Clarify every unclear item first.
2. Prioritize:
   - **Blocking** issues (security, build failures).
   - **Simple** fixes (typos, import ordering).
   - **Complex** changes (refactoring, new logic).
3. Apply one change.
4. Run the relevant test suite.
5. Verify no regressions.
6. Commit with a clear message referencing the review comment ID.

---

## Common Pitfalls & How to Avoid Them
| Pitfall | Remedy |
|---|---|
| Performing a thank‑you without action | Immediately follow with the code change or a clarification request. |
| Implementing without verification | Run `git diff`, unit tests, and integration tests before committing. |
| Batch applying many fixes without testing each | Apply one fix, run tests, then commit. |
| Assuming the reviewer is always correct | Independently verify that the change does not break the build or existing behavior. |
| Ignoring minor issues | Log them in the issue tracker for future cleanup. |
| Forgetting to update documentation | Add or update docs as part of the same commit when the change affects public behavior. |

---

## Checklist
- [ ] Identify `BASE_SHA` and `HEAD_SHA`.
- [ ] Fill all placeholders (`WHAT_WAS_IMPLEMENTED`, `PLAN_OR_REQUIREMENTS`, `DESCRIPTION`).
- [ ] Dispatch the review request.
- [ ] Read all feedback fully.
- [ ] Restate each item in your own words.
- [ ] Ask clarification for any unclear point.
- [ ] Verify each suggestion against the codebase.
- [ ] Prioritize fixes (Critical → Important → Minor).
- [ ] Implement one fix, run tests, commit.
- [ ] Push back only with technical reasoning.
- [ ] Update documentation if needed.
- [ ] Close the review thread with a summary of actions taken.

---

## Quick Commands Reference
```bash
# Get commit range for review
BASE_SHA=$(git rev-parse HEAD~1)   # or use origin/main
HEAD_SHA=$(git rev-parse HEAD)

# Search for usage of a function or endpoint (YAGNI check)
grep -R "functionName" src/ | wc -l

# Reply to a GitHub PR comment via API (inline reply)
gh api repos/{owner}/{repo}/pulls/comments/{comment_id}/replies -f body='Your reply here'
```

---

**Bottom line:** Request reviews early and often. Treat feedback as suggestions that must be verified, clarified, and applied methodically. Avoid performative agreement; focus on technical correctness and clear communication.
