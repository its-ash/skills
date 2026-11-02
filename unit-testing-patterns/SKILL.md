---
name: unit-testing-patterns
description: "Unit-testing patterns for JavaScript/TypeScript with Jest and Python with pytest: TDD red-green-refactor, test data factories, mocking, parametrized and async tests, describe/it and fixture structure, test naming, and flaky-test fixes. Use when writing unit tests, practicing TDD, mocking dependencies, testing async code, or adding coverage for features, bug fixes, and refactors. Sub-skills: test-driven-development, playwright, react-testing, ai-regression-testing, test-collaboration, browser-qa."
---
# Unit Testing Patterns
Write fast, readable unit tests in Jest and pytest with one shared method.

## Core rules
- TDD: write a failing test, run it and see it fail, write minimal code to pass, run all tests, refactor while green.
- One observable behavior per test.
- Build test data with factories (Jest) or factory fixtures (pytest) with defaults plus `overrides`; override only the fields the test needs.
- Mock only external boundaries (network, email, analytics, clock); keep core logic real.
- Patch at the import location the code under test uses; use `autospec=True` to enforce real signatures.
- Clear mocks between tests: `jest.clearAllMocks()` in `beforeEach`; pytest-mock resets `mocker` per test.
- Assert on outputs and UI, not mock calls, unless the call is the contract.
- Await every promise and coroutine; a missing `await` gives a false pass.
- Name tests as specs in present tense: `creates user with valid data`.
- Group with nested `describe` (Rendering, User interactions) or a `Test<Unit>` class.
- Run the full suite after each change; coverage must not drop.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Many cases, same logic | `it.each` / `@pytest.mark.parametrize` | Copy-pasted tests |
| Async function | `async` test + `await`; pytest-asyncio; `AsyncMock` for awaited deps | Fire-and-forget calls |
| Element must appear later | `await waitFor(...)` / `findBy*` | Fixed sleeps |
| Element must be absent | `queryBy*` → `toBeNull()` | `getBy*` in a try/catch |
| DB access in a unit test | In-memory SQLite fixture with `yield` | Shared dev database |
| Flaky test | Find shared state, timing, or order; fix root cause ([debugging](../systematic-debugging/SKILL.md)) | Retries to hide it |
| React components, hooks, MSW, axe | [react-testing](references/react-testing.md) | Snapshot-only tests |
| Full user flow in a browser | [playwright](references/playwright.md) | Unit tests with heavy DOM mocks |
| Code an AI wrote | [ai-regression-testing](references/ai-regression-testing.md) | Trust without a regression test |

## Load on demand
| Need | Read |
|---|---|
| Factories, mocks, structure, Testing Library queries, parametrize, async, DB fixture, run commands | [references/jest-pytest-patterns.md](references/jest-pytest-patterns.md) |
| Strict TDD cycle for features, fixes, refactors | [references/test-driven-development.md](references/test-driven-development.md) |
| Playwright E2E: config, POM, auth state, fixtures, flaky fixes, artifacts, visual regression, CI sharding | [references/playwright.md](references/playwright.md) |
| React Testing Library, Vitest/Jest, MSW, axe; RTL vs Playwright CT vs E2E | [references/react-testing.md](references/react-testing.md) |
| Regression tests for AI-written code, sandbox/production parity | [references/ai-regression-testing.md](references/ai-regression-testing.md) |
| Test inventory, gap analysis, `TESTS.md` TEST-ID registry, evidence review | [references/test-collaboration.md](references/test-collaboration.md) |
| Post-deploy browser QA: smoke, interaction, visual, a11y, SHIP verdict | [references/browser-qa.md](references/browser-qa.md) |

## Related skills
- [`python`](../python/SKILL.md) — pytest deep dive via python-testing
- [`typescript`](../typescript/SKILL.md) — TS types and config
- [`javascript`](../typescript/references/javascript.md) — core JS: closures, event loop
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — root-cause failing or flaky tests
- [`clean-code`](../clean-code/SKILL.md) — naming and structure in tests
