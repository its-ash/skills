---
name: unit-testing-patterns
description: "Covers unit-testing patterns for JavaScript and TypeScript with Jest and for Python with pytest including test-driven development workflows, factory functions for test data, mocking strategies, parametrized tests, async testing, and test structure conventions. Use when writing unit tests, practicing TDD red-green-refactor, creating test data factories, mocking dependencies, parametrizing test cases, testing async code, structuring test files with describe it or pytest fixtures, naming tests with given-when-then or should-expect patterns, fixing flaky tests, or adding coverage for new features, bug fixes, and refactors in Jest, pytest, JavaScript, TypeScript, or Python projects."
---

# unit-testing-patterns

Provide consistent, maintainable unit tests for JavaScript/TypeScript projects that use Jest and for Python projects that use pytest. Follow the same principles across languages: write failing tests first, keep test data DRY, mock external code safely, and structure tests for readability.

## When to use
- You need to add or improve unit tests for a JavaScript/TypeScript codebase (React, Node, etc.).
- You need to add or improve unit tests for a Python codebase.
- You want to adopt Test‑Driven Development (TDD) or Behavior‑Driven Testing.
- You need reusable factories for component props, data objects, or fixtures.
- You need clear patterns for mocking modules, functions, or external services.

---

## Test‑Driven Development Workflow
1. Write a test that fails because the feature does not exist.
2. Run the test suite; confirm the new test fails.
3. Write the minimal production code required to make the test pass.
4. Run the test suite again; confirm all tests pass.
5. Refactor the production code while keeping the tests green.
6. Repeat for the next behavior.

> Keep the test focused on a single observable behavior. Do not write production code before a failing test exists.

---

## Factory Functions for Test Data
### JavaScript / TypeScript
Create a function that returns default props or data objects. Allow an optional `overrides` argument to replace selected fields.

```typescript
// utils/factories.ts
export const getMockUser = (overrides?: Partial<User>): User => ({
  id: 'u-001',
  name: 'Alice',
  email: 'alice@example.com',
  role: 'user',
  ...overrides,
});

export const getMockComponentProps = (overrides?: Partial<ComponentProps<typeof MyComponent>>): ComponentProps<typeof MyComponent> => ({
  title: 'Default Title',
  count: 0,
  onPress: jest.fn(),
  isLoading: false,
  ...overrides,
});
```

**Usage**
```typescript
import { getMockUser, getMockComponentProps } from 'utils/factories';
import { renderWithTheme } from 'utils/testUtils';

it('shows admin badge when role is admin', () => {
  const user = getMockUser({ role: 'admin' });
  renderWithTheme(<UserCard user={user} />);
  expect(screen.getByText('Admin')).toBeTruthy();
});
```

### Python (pytest)
Define reusable fixtures that return default objects. Allow parameter overrides via fixture arguments.

```python
# tests/conftest.py
import pytest
from myapp.models import User

@pytest.fixture
def mock_user():
    def _factory(**overrides):
        defaults = {
            "id": "u-001",
            "name": "Alice",
            "email": "alice@example.com",
            "role": "user",
        }
        defaults.update(overrides)
        return User(**defaults)
    return _factory
```

**Usage**
```python
def test_admin_badge(mock_user):
    user = mock_user(role="admin")
    response = client.get(f"/users/{user.id}/profile")
    assert "Admin" in response.text
```

---

## Mocking Strategies
### Jest (JavaScript)
- Mock an entire module with `jest.mock('module')`.
- Provide a factory function to replace specific exports.
- Access the mock via `jest.requireMock` or the imported name.

```typescript
jest.mock('utils/analytics', () => ({
  Analytics: { logEvent: jest.fn() },
}));

const mockLog = jest.requireMock('utils/analytics').Analytics.logEvent;

it('logs event on click', () => {
  renderWithTheme(<Button />);
  fireEvent.press(screen.getByTestId('button'));
  expect(mockLog).toHaveBeenCalledWith('button_clicked');
});
```

- Clear mocks in `beforeEach` with `jest.clearAllMocks()`.

### pytest (Python)
- Use `unittest.mock.patch` as a decorator or context manager.
- Patch at the import location used by the code under test.
- Return a `Mock` object that you can configure.

```python
from unittest.mock import patch

@patch('myapp.services.email.send_email')
def test_send_welcome_email(mock_send, mock_user):
    user = mock_user()
    send_welcome(user.id)
    mock_send.assert_called_once_with(user.email, any=str)
```

- Use `autospec=True` to enforce the real signature.

---

## Test Structure and Naming
### Jest
```typescript
describe('MyComponent', () => {
  beforeEach(() => jest.clearAllMocks());

  describe('Rendering', () => {
    it('renders with default props', () => { /* ... */ });
    it('shows loading state when loading', () => { /* ... */ });
  });

  describe('User interactions', () => {
    it('calls onPress when button is tapped', async () => { /* ... */ });
  });
});
```

### pytest
```python
import pytest

@pytest.mark.describe('UserService')
class TestUserService:
    @pytest.fixture(autouse=True)
    def _clear_mocks(self, mocker):
        mocker.resetall()

    def test_create_user(self, mock_user, mocker):
        # test body
        ...
```

**Naming rules**
- Use present tense, describe the observable outcome.
- Prefix with the unit under test when helpful (e.g., `UserService creates user with valid data`).

---

## Query and Interaction Patterns (JavaScript)
- **Existence**: `expect(screen.getByText('Hello')).toBeTruthy();`
- **Non‑existence**: `expect(screen.queryByText('Goodbye')).toBeNull();`
- **Async appearance**:
  ```typescript
  await waitFor(() => expect(screen.getByText('Loaded')).toBeTruthy());
  ```
- **User events**:
  ```typescript
  fireEvent.changeText(screen.getByLabelText('Email'), 'user@example.com');
  fireEvent.press(screen.getByTestId('submit'));
  ```

---

## pytest Fixtures, Parametrization, and Async Testing (Python)
- **Simple fixture**: see `mock_user` example above.
- **Parametrized test**:
  ```python
  @pytest.mark.parametrize('role,expected', [
      ('admin', True),
      ('user', False),
  ])
  def test_is_admin(mock_user, role, expected):
      user = mock_user(role=role)
      assert user.is_admin() is expected
  ```
- **Async test** (requires `pytest-asyncio`):
  ```python
  @pytest.mark.asyncio
  async def test_fetch_data(mocker):
      mocker.patch('myapp.api.fetch', return_value={'data': 42})
      result = await fetch_data()
      assert result == 42
  ```
- **Database fixture** (example with SQLite in‑memory):
  ```python
  @pytest.fixture
  def db_session():
      engine = create_engine('sqlite:///:memory:')
      Base.metadata.create_all(engine)
      Session = sessionmaker(bind=engine)
      yield Session()
      Session.close()
  ```

---

## Common Pitfalls
- **Testing mock implementation instead of behavior** – assert on UI or output, not on `mockFn.called` unless the call itself is the observable effect.
- **Duplicating test data** – always use factories or fixtures; duplicated literals become out‑of‑sync.
- **Over‑mocking** – mock only external boundaries. Keep core logic unmocked to retain confidence.
- **Missing `await` in async tests** – leads to false positives. Always await promises or coroutine calls.
- **Not clearing mocks between tests** – residual call history can cause flaky assertions.

---

## Checklist
- [ ] Write a failing test before any production code.
- [ ] Use a factory or fixture to create default data.
- [ ] Override only the fields needed for the specific test.
- [ ] Mock external modules at the import location used by the code.
- [ ] Clear mocks in a `beforeEach` (Jest) or fixture with `autouse=True` (pytest).
- [ ] Keep each test focused on one behavior.
- [ ] Use descriptive test names that read like specifications.
- [ ] Verify observable outcomes, not internal mock calls, unless the call is the contract.
- [ ] Run the full suite after each change; ensure coverage does not drop.
- [ ] For async code, await all promises or coroutine calls.

---

## Running Tests
- **Jest**
  ```bash
  npm test                 # all tests
  npm test -- -t "MyComponent"  # specific test name pattern
  npm run test:coverage    # with coverage report
  ```
- **pytest**
  ```bash
  pytest                     # all tests
  pytest -k "UserService"   # tests matching keyword
  pytest --cov=myapp         # with coverage
  ```

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/test-driven-development.md](references/test-driven-development.md) | Test‑Driven Development (TDD) guides you to write a failing test before any production code, then write the minimal code to make the test pass, and finally refactor while keeping all tests green. Use for new features, bug fixes, refactoring, or any change that needs reliable behavior verification. |

## Related skills

Load these when the task spans more than this skill.

- [`javascript`](../javascript/SKILL.md) — A concise reference of core JavaScript concepts—primitives, type coercion, scope, closures, this, event loop,…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`python`](../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — A step‑by‑step process for diagnosing and fixing bugs, test failures, or unexpected behavior. Use it for any t…
- [`clean-code`](../clean-code/SKILL.md) — Pragmatic clean code standards for AI-assisted development. Covers naming, function design, code structure, an…
- [`java`](../java/SKILL.md) — Guidance, best practices, and checklists for modern Java 21+ development, covering language features, virtual…
- [`verification-before-completion`](../verification-before-completion/SKILL.md) — Run fresh verification commands (tests, lint, type checks, builds, security scans) and confirm their output be…
