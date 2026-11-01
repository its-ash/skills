# Eval Harness

Eval-driven development (EDD) for agent work: define evals before coding, grade them, compare agents head-to-head, and self-score each deliverable.

## When to use

- Setting up eval-driven development (EDD) for AI-assisted workflows
- Defining pass/fail criteria for agent task completion
- Measuring agent reliability with pass@k metrics
- Creating regression test suites for prompt or agent changes
- Benchmarking agent performance across model versions
- Comparing coding agents (Claude Code, Aider, Codex, and others) on your own tasks
- Self-rating a non-trivial deliverable before you hand it to the user

## Philosophy

Eval-Driven Development treats evals as the "unit tests of AI development":
- Define expected behavior BEFORE implementation
- Run evals continuously during development
- Track regressions with each change
- Use pass@k metrics for reliability measurement

## Eval Types

### Capability Evals
Test if the agent can do something it couldn't before:
```markdown
[CAPABILITY EVAL: feature-name]
Task: Description of what the agent should accomplish
Success Criteria:
  - [ ] Criterion 1
  - [ ] Criterion 2
  - [ ] Criterion 3
Expected Output: Description of expected result
```

### Regression Evals
Ensure changes don't break existing functionality:
```markdown
[REGRESSION EVAL: feature-name]
Baseline: SHA or checkpoint name
Tests:
  - existing-test-1: PASS/FAIL
  - existing-test-2: PASS/FAIL
  - existing-test-3: PASS/FAIL
Result: X/Y passed (previously Y/Y)
```

## Grader Types

### 1. Code-Based Grader
Deterministic checks using code:
```bash
# Check if file contains expected pattern
grep -q "export function handleAuth" src/auth.ts && echo "PASS" || echo "FAIL"

# Check if tests pass
npm test -- --testPathPattern="auth" && echo "PASS" || echo "FAIL"

# Check if build succeeds
npm run build && echo "PASS" || echo "FAIL"
```

### 2. Model-Based Grader
Use a model to evaluate open-ended outputs:
```markdown
[MODEL GRADER PROMPT]
Evaluate the following code change:
1. Does it solve the stated problem?
2. Is it well-structured?
3. Are edge cases handled?
4. Is error handling appropriate?

Score: 1-5 (1=poor, 5=excellent)
Reasoning: [explanation]
```

### 3. Human Grader
Flag for manual review:
```markdown
[HUMAN REVIEW REQUIRED]
Change: Description of what changed
Reason: Why human review is needed
Risk Level: LOW/MEDIUM/HIGH
```

## Metrics

### pass@k
"At least one success in k attempts"
- pass@1: First attempt success rate
- pass@3: Success within 3 attempts
- Typical target: pass@3 > 90%

### pass^k
"All k trials succeed"
- Higher bar for reliability
- pass^3: 3 consecutive successes
- Use for critical paths

## Eval Workflow

### 1. Define (Before Coding)
```markdown
## EVAL DEFINITION: feature-xyz

### Capability Evals
1. Can create new user account
2. Can validate email format
3. Can hash password securely

### Regression Evals
1. Existing login still works
2. Session management unchanged
3. Logout flow intact

### Success Metrics
- pass@3 > 90% for capability evals
- pass^3 = 100% for regression evals
```

### 2. Implement
Write code to pass the defined evals.

### 3. Evaluate
```bash
# Run capability evals
[Run each capability eval, record PASS/FAIL]

# Run regression evals
npm test -- --testPathPattern="existing"

# Generate report
```

### 4. Report
```markdown
EVAL REPORT: feature-xyz
========================

Capability Evals:
  create-user:     PASS (pass@1)
  validate-email:  PASS (pass@2)
  hash-password:   PASS (pass@1)
  Overall:         3/3 passed

Regression Evals:
  login-flow:      PASS
  session-mgmt:    PASS
  logout-flow:     PASS
  Overall:         3/3 passed

Metrics:
  pass@1: 67% (2/3)
  pass@3: 100% (3/3)

Status: READY FOR REVIEW
```

## Integration Points

- Before implementation: write the eval definition to `.claude/evals/<feature>.md`.
- During implementation: run the evals and record the status in the log file.
- After implementation: write the full eval report.

## Eval Storage

Store evals in project:
```
.claude/
  evals/
    feature-xyz.md      # Eval definition
    feature-xyz.log     # Eval run history
    baseline.json       # Regression baselines
```

## Best Practices

1. **Define evals BEFORE coding** - Forces clear thinking about success criteria
2. **Run evals frequently** - Catch regressions early
3. **Track pass@k over time** - Monitor reliability trends
4. **Use code graders when possible** - Deterministic > probabilistic
5. **Human review for security** - Never fully automate security checks
6. **Keep evals fast** - Slow evals don't get run
7. **Version evals with code** - Evals are first-class artifacts

## Example: Adding Authentication

```markdown
## EVAL: add-authentication

### Phase 1: Define (10 min)
Capability Evals:
- [ ] User can register with email/password
- [ ] User can login with valid credentials
- [ ] Invalid credentials rejected with proper error
- [ ] Sessions persist across page reloads
- [ ] Logout clears session

Regression Evals:
- [ ] Public routes still accessible
- [ ] API responses unchanged
- [ ] Database schema compatible

### Phase 2: Implement (varies)
[Write code]

### Phase 3: Evaluate
Run each capability and regression eval; record PASS/FAIL.

### Phase 4: Report
EVAL REPORT: add-authentication
==============================
Capability: 5/5 passed (pass@3: 100%)
Regression: 3/3 passed (pass^3: 100%)
Status: SHIP IT
```

## Product Evals

Use product evals when behavior quality cannot be captured by unit tests alone.

### Grader Types

1. Code grader (deterministic assertions)
2. Rule grader (regex/schema constraints)
3. Model grader (LLM-as-judge rubric)
4. Human grader (manual adjudication for ambiguous outputs)

### pass@k Guidance

- `pass@1`: direct reliability
- `pass@3`: practical reliability under controlled retries
- `pass^3`: stability test (all 3 runs must pass)

Recommended thresholds:
- Capability evals: pass@3 >= 0.90
- Regression evals: pass^3 = 1.00 for release-critical paths

### Eval Anti-Patterns

- Overfitting prompts to known eval examples
- Measuring only happy-path outputs
- Ignoring cost and latency drift while chasing pass rates
- Allowing flaky graders in release gates

### Minimal Eval Artifact Layout

- `.claude/evals/<feature>.md` definition
- `.claude/evals/<feature>.log` run history
- `docs/releases/<version>/eval-summary.md` release snapshot

## Head-to-Head Agent Comparison

Use this when you choose between coding agents, or when a change to an agent setup needs measured pass rate, cost, and time.

### Task definitions

Keep one YAML file per task in `tasks/`. Each task states the prompt, the files, the judges, and a pinned commit:

```yaml
name: add-retry-logic
description: Add exponential backoff retry to the HTTP client
repo: ./my-project
files:
  - src/http_client.py
prompt: |
  Add retry logic with exponential backoff to all HTTP requests.
  Max 3 retries. Initial delay 1s, max delay 30s.
judge:
  - type: pytest
    command: pytest tests/test_http_client.py -v
  - type: grep
    pattern: "exponential_backoff|retry"
    files: src/http_client.py
  - type: llm
    prompt: |
      Does this implementation correctly handle exponential backoff?
      Check for: max retries, increasing delays, jitter.
commit: "abc1234"  # pin to specific commit for reproducibility
```

### Run procedure

For each agent and each run:

1. Create a fresh git worktree from the pinned commit (`git worktree add ../run-<agent>-<n> abc1234`). Agents cannot change the base repo or each other.
2. Give the prompt to the agent.
3. Run the judges.
4. Record pass/fail, cost, and wall-clock time.

The open-source [agent-eval](https://github.com/joaquinhuigomez/agent-eval) CLI automates these steps. Read its source before you install it.

### Metrics

| Metric | What It Measures |
|--------|-----------------|
| Pass rate | Did the agent produce code that passes the judge? |
| Cost | API spend per task (when available) |
| Time | Wall-clock seconds to completion |
| Consistency | Pass rate across repeated runs (e.g., 3/3 = 100%) |

```
Task: add-retry-logic (3 runs each)
| Agent       | Pass Rate | Cost  | Time | Consistency |
|-------------|-----------|-------|------|-------------|
| claude-code | 3/3       | $0.12 | 45s  | 100%        |
| aider       | 2/3       | $0.08 | 38s  |  67%        |
```

### Rules

- Start with 3-5 tasks from your real workload, not toy examples.
- Run at least 3 trials per agent. Agents are not deterministic.
- Pin the commit so results stay reproducible.
- Include at least one deterministic judge (tests, build) per task. LLM judges add noise.
- Track cost with pass rate. A 95% agent at 10x the cost can be the wrong choice.
- Version task definitions as code. They are test fixtures.

## Self-Evaluation Scorecard

After a non-trivial task, rate the deliverable on 5 axes. This is a reflection step, not a pass/fail gate. Use it after code that spans 3+ files or 50+ lines, after a multi-step workflow, after a debug session with 3+ attempts, after a design document, or when the user asks "rate yourself".

| Axis | Question | What it catches |
|---|---|---|
| **Accuracy** | Are the facts, claims, and outputs correct? | Hallucinations, wrong API names, incorrect syntax |
| **Completeness** | Did it cover everything the user asked for? | Missed edge cases, unhandled error paths, skipped subtasks |
| **Clarity** | Is the output understandable and well-structured? | Jargon without definition, missing context, rambling |
| **Actionability** | Can the user act on the output immediately? | Vague suggestions, missing steps, no verification path |
| **Conciseness** | Did it use the minimum words/tokens needed? | Redundancy, over-explanation, filler |

```
5 — Exceptional: no reasonable improvement possible
4 — Good: minor nits only, no substantive gaps
3 — Adequate: meets the request but has a notable weakness on at least one axis
2 — Weak: has a clear gap that affects usability or correctness
1 — Poor: fundamentally misses the request or contains significant errors
```

**Evidence rule:** every score below 5 must cite specific evidence. "Show the gap, don't just name it."

### Procedure

1. Collect the original request, the deliverable, tool outputs that verify it (tests, exit codes, lint), and user corrections.
2. Score each axis independently. Do not pick an average first and work backwards.
3. Report: one-line summary, scorecard with evidence, overall score (average, 1 decimal), 1-3 improvements ranked by impact, and the check "Would the user agree?".
4. If an axis scores 3 or less: fix it now when the fix is small; otherwise flag it with the cause, the evidence, and the specific fix.

```
Task: Add retry logic to HTTP client

Scorecard:
  Accuracy:     2 — Used urllib3; the codebase uses httpx. Wrong library.
  Completeness: 3 — Works for GET. POST/PUT not handled (user said "all HTTP requests").
  Clarity:      4 — Code is readable. Good variable names.
  Actionability:2 — "Add tests" mentioned but no test file created.
  Conciseness:  3 — Retry config duplicated in 3 places instead of one RetryConfig.

Overall: 2.8 — Switch to httpx first, then extend to all methods, then consolidate config.
```

### Anti-patterns

- "Everything is a 5" with no evidence. A real 5 needs proof that nothing can improve.
- Penalizing for scope the user did not ask for.
- Using the evaluation to re-argue design decisions already made.
- Personal preference as evidence ("I don't like decorators"). Cite a concrete readability, testability, or correctness concern.
- Guessing. Cite test and lint output as evidence.

## Related

- `references/agent-architecture-audit.md` — find which agent layer causes a failure
- `references/agent-introspection-debugging.md` — debug a failing agent run
