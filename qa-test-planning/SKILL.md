---
name: qa-test-planning
description: "Designs QA test plans, manual test cases, regression suites, Figma UI validation, coverage analysis, and E2E scaffolding for React, Next.js, Node.js apps. Use when writing test plan, test cases, regression checklist, coverage report, Playwright/Cypress specs, QA matrix, acceptance criteria, bug reproduction, UI parity checks, .test.ts, .spec.ts, jest, vitest, playwright, cypress, testing-library."
---

# QA Test Planning

Create comprehensive test artifacts and quality checks for modern web applications. Use this skill when you need a test strategy, manual test cases, regression suites, UI‑design validation, or coverage/e2e automation for a feature or release.

## When to Use
- Defining scope, objectives, and schedule for a new feature or release.
- Generating step‑by‑step manual test cases quickly.
- Building smoke or full regression suites for CI pipelines.
- Comparing implemented UI with a Figma design.
- Measuring test coverage and scaffolding end‑to‑end (E2E) tests.
- Documenting reproducible bug reports.

---

## Workflow Overview
1. **Analyze** – Parse the feature description, identify required test types, and set priorities.
2. **Generate** – Produce a structured test plan, test cases, regression suite, or bug report using built‑in templates.
3. **Validate** – Check completeness, traceability, and design compliance (Figma). Adjust as needed.
4. **Execute** – Run coverage analysis, unit tests, and E2E scaffolding. Review results and iterate.

---

## 1. Test Plan Creation
- **Scope** – List in‑scope and out‑of‑scope items.
- **Objectives** – Define what success looks like.
- **Approach** – Manual, automated, or hybrid.
- **Environment** – Required browsers, devices, services.
- **Entry/Exit Criteria** – Conditions to start and finish testing.
- **Risks & Mitigations** – Identify high‑impact risks.
- **Timeline** – Milestones and deadlines.

**Command (example)**
```bash
# Generate a test plan (replace placeholders)
qa-tool generate-plan --feature "User Authentication" --output plan.md
```

## 2. Manual Test Cases
Each case must include:
- **Preconditions** – Setup steps.
- **Test Steps** – Precise actions.
- **Expected Result** – Exact outcome.
- **Test Data** – Values or files needed.
- **Priority / Severity** – Business impact.

**Template Example**
```markdown
### TC-001: Login with valid credentials
**Preconditions**: User account exists, login page loaded.
1. Enter username "john.doe@example.com".
2. Enter password "Correct$Pass123".
3. Click **Login**.
**Expected Result**: Dashboard loads within 2 seconds and displays user name.
**Priority**: High
```

## 3. Regression Suite Construction
- **Smoke Tests** – Critical path (login, checkout) – 15‑30 min.
- **Full Regression** – All functional areas – 2‑4 h.
- **Targeted Regression** – Selected modules – 30‑60 min.
- Order tests to respect data dependencies.

**Command (example)**
```bash
# Scaffold a regression suite for the payment module
qa-tool generate-regression --module payment --type full --output regression_suite.yaml
```

## 4. Figma Design Validation
1. Open the Figma URL.
2. Compare each component’s:
   - Size & spacing
   - Typography
   - Color palette
   - Interactive states (hover, active, disabled)
3. Record any discrepancy with screenshots.

**Command (example)**
```bash
qa-tool validate-figma --url https://www.figma.com/file/XYZ/login --component login-page --output figma_report.md
```

## 5. Coverage Analysis
- Run the coverage tool on the source directory.
- Review uncovered files/functions.
- Apply recommended fixes or add tests.

**Command**
```bash
python -m coverage run -m pytest && python -m coverage report -m
```

## 6. E2E Test Scaffolding
- Choose a framework (Playwright, Cypress, Selenium).
- Generate boilerplate for the feature.
- Include selectors, navigation steps, and assertions.

**Command (example for Playwright)**
```bash
npx playwright codegen https://app.example.com/login > tests/e2e/login.spec.ts
```

---

## Best Practices
- **Traceability** – Link each test case to a requirement or user story.
- **Atomic Steps** – Keep each step simple and verifiable.
- **Data Management** – Provide reusable test data sets.
- **Version Control** – Store test artifacts alongside code.
- **Continuous Integration** – Run unit, coverage, and E2E tests on every PR.
- **Design Review** – Validate UI after every visual change.

## Common Anti‑Patterns
| Anti‑Pattern | Why It Fails | Correct Approach |
|--------------|--------------|------------------|
| Vague steps | Tests cannot be reproduced | Write explicit actions and expected results |
| Missing preconditions | Test crashes before execution | Document all required setup |
| No test data | Tester blocked | Include sample data or generation scripts |
| Generic bug titles | Hard to search | Use "[Feature] issue when [action]" |
| Skipping edge cases | Critical bugs missed | Add boundary values, nulls, and error paths |

---

## Verification Checklist
### Test Plan
- [ ] Scope defined (in/out).
- [ ] Entry/exit criteria present.
- [ ] Risks listed with mitigations.
- [ ] Timeline realistic.

### Test Cases
- [ ] Every step has an expected result.
- [ ] Preconditions documented.
- [ ] Test data supplied.
- [ ] Priority assigned.

### Regression Suite
- [ ] Critical paths covered.
- [ ] Execution order respects dependencies.
- [ ] Suite size matches time budget.

### Figma Validation
- [ ] All components compared.
- [ ] Visual discrepancies listed with screenshots.
- [ ] Design specs (spacing, color) matched.

### Bug Report
- [ ] Reproducible steps included.
- [ ] Environment details recorded.
- [ ] Evidence attached (screenshots, logs).
- [ ] Severity and priority set.

---

## Reference Templates (inline)
### Test Case Template
```markdown
**Test Case ID**: TC-<number>
**Title**: <short description>
**Preconditions**: <list>
**Steps**:
1. <action>
2. <action>
...
**Expected Result**: <outcome>
**Priority**: <High|Medium|Low>
**Owner**: <name>
```

### Bug Report Template
```markdown
**Title**: [<Component>] <Brief description>
**Description**: <Detailed problem statement>
**Steps to Reproduce**:
1. <action>
2. <action>
...
**Expected Result**: <what should happen>
**Actual Result**: <what happened>
**Environment**: OS, Browser, Version, Device
**Attachments**: <screenshots, logs>
**Severity**: <Critical|Major|Minor>
**Priority**: <P1|P2|P3>
```

---

## Quick Reference Table
| Task | Output | Typical Time |
|------|--------|--------------|
| Test Plan | Strategy, scope, schedule, risks | 10‑15 min |
| Manual Test Cases | Step‑by‑step instructions, expected results | 5‑10 min each |
| Regression Suite | Smoke/critical path list, execution order | 15‑20 min |
| Figma Validation | Discrepancy list with screenshots | 10‑15 min |
| Bug Report | Reproducible steps, evidence, severity | 5 min |

---

## Example Usage
**Create a test plan for the checkout feature**
```text
Create test plan for Checkout
```
**Generate three test cases for the checkout flow**
```text
Generate 3 test cases for Checkout
```
**Build a smoke regression suite for payment**
```text
Build smoke test suite for Payment module
```
**Validate login page against Figma**
```text
Compare login page with Figma at https://www.figma.com/file/XYZ/login
```
**Document a bug in form validation**
```text
Create bug report: Form validation fails when email is empty
```

---

## Integration Tips
- Add generated test artifacts to the repository under `/tests/`.
- Configure CI to run `coverage` and `e2e` scripts on each pull request.
- Store Figma URLs in a `design_links.json` file for easy reference.
- Use the same naming convention for test cases and bug IDs to enable traceability.

## Related skills

Load these when the task spans more than this skill.

- [`playwright`](../playwright/SKILL.md) — Playwright skill for building reliable end‑to‑end test suites and browser automation. Use it to set up Playwri…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`figma`](../figma/SKILL.md) — Provides a step‑by‑step workflow to fetch design context, screenshots, and assets from a Figma MCP server and…
- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`nextjs`](../nextjs/SKILL.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`planning`](../planning/SKILL.md) — Creates a concise atomic implementation plan for a coding task, expands it into a detailed step‑by‑step plan w…
