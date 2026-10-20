# Test‑Driven Development (TDD)

Write a test first, watch it fail, write the smallest code to pass, then clean the code. The test is the living specification.

## When to Use
- Implementing a new feature
- Fixing a bug
- Refactoring existing code
- Adding complex logic
- Any change that must be trusted by automated tests

*Avoid TDD for throw‑away prototypes, generated code, or simple configuration files unless a human partner approves.*

## The TDD Cycle
```
🔴 RED   → Write a failing test
🟢 GREEN → Write just enough code to pass
🔵 REFACTOR → Improve code without changing behavior
repeat
```

## The Three Laws of TDD
1. Write production code only to make a failing test pass.
2. Write only enough test to demonstrate the failure.
3. Write only enough code to make the test pass.

## RED Phase – Write a Failing Test
- Test must fail before any implementation exists.
- Test name describes the expected behavior.
- Test covers a single behavior or edge case.
- Use real code, not mocks, unless the dependency cannot be exercised.

**Example (Jest, TypeScript)**
```typescript
test('retryOperation retries three times and succeeds', async () => {
  let attempts = 0
  const operation = async () => {
    attempts++
    if (attempts < 3) throw new Error('fail')
    return 'ok'
  }
  const result = await retryOperation(operation)
  expect(result).toBe('ok')
  expect(attempts).toBe(3)
})
```
Run the test and confirm it fails:
```bash
npm test path/to/retryOperation.test.ts
```

## GREEN Phase – Write Minimal Code
- Implement the smallest logic that makes the test pass.
- Do not add features that are not covered by the test.
- Avoid premature optimization.

**Minimal implementation for the example**
```typescript
async function retryOperation(fn: () => Promise<string>): Promise<string> {
  for (let i = 0; i < 3; i++) {
    try {
      return await fn()
    } catch (e) {
      if (i === 2) throw e
    }
  }
  throw new Error('unreachable')
}
```
Run the test again and verify it passes, and that the full test suite still passes.

## REFACTOR Phase – Clean Up
- Remove duplication.
- Improve naming and structure.
- Extract helpers if they improve readability.
- Keep the test suite green after every change.
- Commit after each successful refactor.

## AAA Test Pattern
| Step | Purpose |
|------|---------|
| **Arrange** | Set up inputs, mocks, and environment |
| **Act** | Call the function under test |
| **Assert** | Verify the expected outcome |

## Good Test Characteristics
- **One behavior per test** – split combined scenarios.
- **Clear name** – describes the expected result.
- **Real code** – avoid unnecessary mocks.
- **Edge cases covered** – include error and boundary conditions.

## Common Rationalizations & Red Flags
| Rationalization | Why it fails |
|------------------|--------------|
| "Too simple to test" | Simple code still breaks; a test takes seconds. |
| "I'll test after" | Immediate pass proves nothing; you may miss bugs. |
| "Manual testing is enough" | No repeatable record; regressions go unnoticed. |
| "I already spent hours, deleting is wasteful" | Sunk‑cost fallacy; untested code is technical debt. |
| "Skip RED because I know the answer" | Violates the first law; you lose the safety net. |

**Red flag:** any code written before a failing test. Stop, delete the code, and start the RED step.

## Checklist
- [ ] Every new function/method has a corresponding test file.
- [ ] Each test was run and failed **before** any implementation.
- [ ] Failure was due to missing behavior, not a typo or syntax error.
- [ ] Implemented the smallest code to make the test pass.
- [ ] All tests (new and existing) pass with a clean output.
- [ ] No new behavior was added without a test.
- [ ] Refactored code does not change test results.

If any item is unchecked, restart the cycle for that piece of code.

## When Stuck
- **Don’t know how to test?** Write the API you wish existed and assert its result. Ask a teammate for clarification.
- **Test is too complex?** Simplify the design; a testable design is usually simpler.
- **Too many mocks?** Introduce dependency injection to make the code more testable.
- **Large test setup?** Extract shared helpers into a separate test utility file.

## Anti‑Patterns to Avoid
| ❌ Do Not | ✅ Do |
|----------|------|
| Write production code before the test | Write a failing test first |
| Write the test after the code | Keep the test as the specification |
| Over‑engineer the first implementation | Write the simplest code that passes |
| Put multiple assertions in one test | Test one behavior per test |
| Test implementation details | Test observable behavior |

---

Follow this workflow for every change. The test suite becomes the safety net that lets you refactor confidently and catch regressions early.
