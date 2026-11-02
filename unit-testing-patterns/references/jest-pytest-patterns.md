# Jest and pytest patterns

## Factories
```typescript
// utils/factories.ts
export const getMockUser = (overrides?: Partial<User>): User => ({
  id: 'u-001', name: 'Alice', email: 'alice@example.com', role: 'user', ...overrides,
});
export const getMockProps = (overrides?: Partial<ComponentProps<typeof MyComponent>>) => ({
  title: 'Default Title', count: 0, onPress: jest.fn(), isLoading: false, ...overrides,
});

it('shows admin badge when role is admin', () => {
  renderWithTheme(<UserCard user={getMockUser({ role: 'admin' })} />);
  expect(screen.getByText('Admin')).toBeTruthy();
});
```
```python
# tests/conftest.py
@pytest.fixture
def make_user():
    def _make(**overrides):
        return User(**({"id": "u-001", "name": "Alice", "email": "alice@example.com", "role": "user"} | overrides))
    return _make

def test_admin_badge(make_user, client):
    user = make_user(role="admin")
    assert "Admin" in client.get(f"/users/{user.id}/profile").text
```

## Mocking
```typescript
jest.mock('utils/analytics', () => ({ Analytics: { logEvent: jest.fn() } }));
const mockLog = jest.requireMock('utils/analytics').Analytics.logEvent;

beforeEach(() => jest.clearAllMocks());
it('logs event on click', () => {
  renderWithTheme(<Button />);
  fireEvent.press(screen.getByTestId('button'));
  expect(mockLog).toHaveBeenCalledWith('button_clicked');
});
```
```python
from unittest.mock import patch, ANY

@patch("myapp.services.email.send_email", autospec=True)   # patch where it is looked up
def test_send_welcome_email(mock_send, make_user):
    user = make_user()
    send_welcome(user.id)
    mock_send.assert_called_once_with(user.email, ANY)
```

## Structure
```typescript
describe('MyComponent', () => {
  beforeEach(() => jest.clearAllMocks());
  describe('Rendering', () => {
    it('renders with default props', () => {});
    it('shows loading state when loading', () => {});
  });
  describe('User interactions', () => {
    it('calls onPress when button is tapped', async () => {});
  });
});
```
```python
class TestUserService:
    def test_creates_user_with_valid_data(self, make_user, mocker): ...
```
pytest-mock resets `mocker` patches after each test; no manual reset needed.

## Queries and events (Testing Library)
| Check | Code |
|---|---|
| Exists | `expect(screen.getByText('Hello')).toBeTruthy()` |
| Absent | `expect(screen.queryByText('Bye')).toBeNull()` |
| Appears later | `await waitFor(() => expect(screen.getByText('Loaded')).toBeTruthy())` |
| Type (RN) | `fireEvent.changeText(screen.getByLabelText('Email'), 'user@example.com')` |
| Press (RN) | `fireEvent.press(screen.getByTestId('submit'))` |

## pytest parametrize, async, DB
```python
@pytest.mark.parametrize("role,expected", [("admin", True), ("user", False)])
def test_is_admin(make_user, role, expected):
    assert make_user(role=role).is_admin() is expected

@pytest.mark.asyncio   # pytest-asyncio
async def test_fetch_data(mocker):
    mocker.patch("myapp.api.fetch", return_value={"data": 42})
    assert await fetch_data() == 42

@pytest.fixture
def db_session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    with sessionmaker(bind=engine)() as session:
        yield session
```
Patch an `async def` with `mocker.AsyncMock` when the caller awaits it.

## Run
```bash
npm test                        # all
npm test -- -t "MyComponent"    # by name
npm run test:coverage
pytest                          # all
pytest -k "UserService"         # by keyword
pytest --cov=myapp
```
