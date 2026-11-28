@REF:jest-pytest-patterns
§VER{
  Vitest:5.1.x(Node≥22.12,Vite≥6.4,`clearMocks:true`_default,artifacts→`.vitest/`);
  Jest:30.x(Node≥18,`jsdom`26,TS≥5.4,single_file_bundles,improved_ESM);
  node:test:Node_22/24_built-in(zero_deps,`node:test`+`node:assert`);
  pytest:9.x(native_`[tool.pytest]`_TOML,core_`subtests`_fixture,kw_only_parametrize_opts);
  pytest-asyncio:1.x(`event_loop`_fixture_REMOVED,`asyncio_default_fixture_loop_scope`);
  RNTL:`@testing-library/react-native`14.x(RN≥0.78,Node≥22,async_by_default,`userEvent`>`fireEvent`)
}
§FACT{
  TS(`utils/factories.ts`):`getMockUser=(o?:Partial<User>):User=>({id:'u-1',name:'A',email:'a@b',role:'user',...o})`;`getMockProps=(o?:Partial<ComponentProps<typeof C>>)=>({title:'T',count:0,onPress:vi.fn(),isLoading:false,...o})`;`renderWithProviders(<UserCard user={getMockUser({role:'admin'})}/>)`;
  Py(`tests/conftest.py`):`@pytest.fixture def make_user():return lambda **o:User(**({"id":"u-1","name":"A","email":"a@b","role":"user"}|o))`
}
§MOCK{
  Vitest5:`vi.mock(m,()=>({Analytics:{logEvent:vi.fn()}}))`∨`vi.spyOn(Analytics,'logEvent')`;`clearMocks:true`_default(auto_`vi.clearAllMocks()`_pre_test;set_`clearMocks:false`_only_if_accumulating);`vi.useFakeTimers()`+`vi.advanceTimersByTimeAsync(...)`;
  Jest30:`jest.mock(m,()=>({Analytics:{logEvent:jest.fn()}}))`→`jest.requireMock(m).Analytics.logEvent`;`clearMocks:true`∈`jest.config`∨`beforeEach(()=>jest.clearAllMocks())`;`expect(mock).toHaveBeenCalledWith(x)`;
  Node:`import{describe,it,mock}from'node:test';import assert from'node:assert/strict';const fn=mock.fn(()=>42);mock.reset()`(in_`afterEach`);
  Py:`from unittest.mock import patch,ANY,AsyncMock`;`@patch("pkg.mod.fn",autospec=True)`(patch@lookup_site);`mock.assert_called_once_with(user.email,ANY)`;
  pytest-mock:auto_resets_`mocker`_per_test(¬manual_reset);awaited_`async def`⇒`mocker.AsyncMock`
}
§STR{
  Vitest/Jest:`describe(n,()=>{describe('Rendering'|'User interactions',()=>{it('handles valid submit',async()=>{})})})`;
  Py:`class TestUserService: def test_creates_user(self,make_user,mocker): ...`
}
§RTL{
  web_exists:`expect(screen.getByRole('button',{name:/save/i})).toBeInTheDocument()`;absent:`expect(screen.queryByText(t)).toBeNull()`;async:`expect(await screen.findByText(t)).toBeInTheDocument()`;
  RNTL14:`const user=userEvent.setup();await render(<Form/>);await user.type(screen.getByLabelText(l),v);await user.press(screen.getByRole('button',{name:/submit/i}))`
}
§PY{
  cfg(`pyproject.toml`,pytest9+pytest-asyncio1):`[tool.pytest]\nminversion="9.0"\ntestpaths=["tests"]\naddopts=["-ra","-q"]\nasyncio_mode="auto"\nasyncio_default_fixture_loop_scope="function"`;
  parametrize:`@pytest.mark.parametrize("role,expected",[("admin",True),("user",False)],ids=["admin","user"])`(pytest9:kw_only_`indirect`,`ids`,`scope`);
  subtests(pytest9_core,¬extra_plugin):`def test_cases(subtests):\n  for x in cases:\n    with subtests.test(x=x): assert check(x)`;
  async(pytest-asyncio1):`async def test_fetch(mocker): m=mocker.patch("pkg.mod.call",new_callable=mocker.AsyncMock,return_value=1); assert await fn()==1`;scoped_loop⇒`@pytest.mark.asyncio(loop_scope="module")`(created_1x/scope;¬custom_`event_loop`_fixture);
  DB:`create_engine("sqlite:///:memory:")`→`Base.metadata.create_all(engine)`→`with sessionmaker(bind=engine)() as s: yield s`
}
§ANTI{
  custom_`event_loop`_fixture(removed_in_`pytest-asyncio`1.x⇒use_`asyncio_default_fixture_loop_scope`);
  nose_setup_or_yield_tests(removed_in_pytest9);
  RNTL_`fireEvent`_default(prefer_RNTL14_`userEvent`+`await render`);
  Vitest5_shared_mock_history_across_tests(broken_by_default_`clearMocks:true`⇒scope_locally);
  patch@definition_site(patch@import_site_used_by_CUT+`autospec=True`)
}
§CMD{
  Vitest:`npx vitest run` | `npx vitest run -t "MyComponent"` | `npx vitest run --coverage`;
  Jest:`npx jest` | `npx jest -t "MyComponent"` | `npx jest --coverage`;
  Node:`node --test` | `node --test --test-name-pattern="MyUnit"` | `node --test --experimental-test-coverage`;
  Py:`uv run pytest` | `pytest -k "UserService"` | `pytest --cov=myapp`
}
