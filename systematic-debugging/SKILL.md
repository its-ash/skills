---
name: systematic-debugging
description: "Systematic-debugging provides a structured four-phase methodology for isolating root causes of software defects, test failures, crashes, and unexpected runtime behavior across any language or stack. Use when encountering stack traces, assertion errors, segmentation faults, memory leaks, flaky tests, CI pipeline failures, silent data corruption, race conditions, off-by-one errors, null pointer exceptions, dependency conflicts, or performance regressions; invoke for reproduce steps, bisect commits, add logging, inspect state, form hypotheses, write minimal repro cases, apply fixes, and verify regressions with unit, integration, or end-to-end suites before committing."
---

# Systematic Debugging

Use a disciplined workflow to find the root cause of any bug, test failure, or unexpected behavior before writing a fix. The process works for single‑file scripts, large services, and CI pipelines.

## When to Use
- Test failures in local or CI environments
- Bugs in production or staging
- Performance regressions
- Build or deployment errors
- Integration issues across multiple components
- Any error message, stack trace, or unexpected output

## Core Principle
**Never fix a symptom without first confirming the root cause.**

---

## Phase 1 – Root Cause Investigation
1. **Read the error fully**
   - Capture the exact message, stack trace, line numbers, and error codes.
2. **Reproduce reliably**
   - Document the exact steps that trigger the issue.
   - If you cannot reproduce, gather more data before proceeding.
3. **Check recent changes**
   - `git diff` the last few commits.
   - Look for new dependencies, config edits, or environment changes.
4. **Gather evidence in multi‑component systems**
   - At each component boundary, log incoming and outgoing data.
   - Verify environment variables and configuration propagation.
   - Example for a four‑layer build pipeline:
   ```bash
   echo "=== Workflow secrets ==="
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"
   echo "=== Build env ==="
   env | grep IDENTITY || echo "IDENTITY missing"
   echo "=== Keychain state ==="
   security list-keychains
   security find-identity -v
   echo "=== Signing command ==="
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```
   - The logs show which layer fails.
5. **Trace data flow**
   - Starting from the symptom, move up the call stack to locate the origin of the bad value.
   - Record the source location; fix there, not at the symptom.

---

## Phase 2 – Pattern Analysis
1. **Find a working example** in the same repository.
2. **Compare line‑by‑line** with the broken code.
3. **List every difference**, however small.
4. **Identify required dependencies** and configuration assumptions.
5. **Read reference implementations completely** before adapting them.

---

## Phase 3 – Hypothesis and Testing
1. **Form a single hypothesis**
   - Example: “The `user` object is undefined because the API returned `null`.”
   - Write it down.
2. **Test minimally**
   - Change only one variable or add a single log statement.
   - Do not combine multiple fixes.
3. **Verify**
   - If the hypothesis is confirmed, move to Phase 4.
   - If not, create a new hypothesis and repeat.
4. **When stuck**
   - Admit the unknown.
   - Ask for help or research further before proceeding.

---

## Phase 4 – Implementation
1. **Create a failing test case**
   - Small, reproducible unit test or script that demonstrates the bug.
   - Use test‑driven development if possible.
2. **Apply a single fix** that addresses the root cause.
   - No “while I’m here” changes.
3. **Verify**
   - The new test passes.
   - All existing tests still pass.
4. **If the fix fails**
   - Count how many distinct fixes have been tried.
   - After three unsuccessful attempts, **stop** and question the overall architecture.
5. **Questioning architecture**
   - Look for systemic coupling, hidden shared state, or design flaws.
   - Discuss with the team before large refactors.

---

## Error Classification Framework
| Category | Indicators | Typical Causes |
|---|---|---|
| Syntax | Parse error, unexpected token | Typos, missing brackets |
| Type | `TypeError`, type mismatch | Wrong data type, null access |
| Reference | `NameError`, undefined variable | Scope issues |
| Runtime | Uncaught exception | Logic error, invalid operation |
| Network | Timeout, `ECONNREFUSED`, 4xx/5xx | Wrong URL, server down |
| Permission | `EACCES`, `PermissionError` | File rights, missing sudo |
| Dependency | `ModuleNotFound`, version conflict | Missing package, wrong version |
| Configuration | Missing env var, bad config file | Wrong settings |
| Database | Connection refused, query error | Bad credentials, bad SQL |
| Memory | OOM, heap out of memory | Leak, huge data set |

Use the table to quickly narrow the error type before deep investigation.

---

## Debugging Techniques
- **Binary Search**: Comment out half the code, run tests, repeat to isolate the failing line.
- **Minimal Reproduction**: Start with an empty file and add code until the error appears.
- **Rubber Duck**: Explain the problem aloud; often the solution emerges.
- **Git Bisect**:
  ```bash
  git bisect start
  git bisect bad   # current commit
  git bisect good <last‑good‑commit>
  # mark each checkout as good/bad
  git bisect reset
  ```
- **Strategic Logging**: Add logs at component boundaries (see Phase 1).

---

## Common Commands
### Node.js
```bash
# Verbose errors
NODE_DEBUG=* node app.js
# Inspect memory
node --inspect app.js
# List installed packages
npm ls [package]
# Verify package.json
npm ls --depth=0
```
### Python
```bash
# Interactive debugger
python -m pdb script.py
# List packages
pip list
pip show [package]
```
### General
```bash
# File permissions
ls -la [file]
# Open ports
lsof -i :[port]
netstat -an | grep [port]
# Environment variables
env | grep VAR_NAME
printenv VAR_NAME
# Disk space
df -h
# Memory usage (Linux)
free -m
# Memory usage (macOS)
vm_stat
```

---

## Checklist
- [ ] Capture full error message and stack trace.
- [ ] Document reproducible steps.
- [ ] Review recent code, config, and dependency changes.
- [ ] Add instrumentation at each component boundary (if applicable).
- [ ] Trace the bad value back to its origin.
- [ ] Locate a working reference implementation.
- [ ] List all differences between working and broken code.
- [ ] Form a single, testable hypothesis.
- [ ] Test the hypothesis with the smallest possible change.
- [ ] Write a failing test that reproduces the bug.
- [ ] Apply one fix that addresses the root cause.
- [ ] Run the failing test and the full test suite.
- [ ] If three fixes fail, pause and evaluate the architecture.
- [ ] Record the solution for future replay (optional).

Follow this workflow for every technical issue to reduce time spent on guess‑and‑check and to avoid introducing new bugs.

## Related skills

Load these when the task spans more than this skill.

- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`verification-before-completion`](../verification-before-completion/SKILL.md) — Run fresh verification commands (tests, lint, type checks, builds, security scans) and confirm their output be…
- [`code-review`](../code-review/SKILL.md) — Review code changes for correctness, security, performance, maintainability, tests, and production readiness.…
- [`performance`](../performance/SKILL.md) — Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary…
- [`clean-code`](../clean-code/SKILL.md) — Pragmatic clean code standards for AI-assisted development. Covers naming, function design, code structure, an…
- [`research-engineer`](../research-engineer/SKILL.md) — Research Engineer skill for rigorous, correctness-first engineering. Use when implementing algorithms, optimiz…
