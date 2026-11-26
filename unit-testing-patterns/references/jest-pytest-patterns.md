@REF:jest-pytest-patterns
§FACT{
  TS(`utils/factories.ts`):`getMockUser=(o?:Partial<User>):User=>({id:'u-1',name:'A',email:'a@b',role:'user',...o})`;`getMockProps=(o?:Partial<ComponentProps<typeof C>>)=>({title:'T',count:0,onPress:jest.fn(),isLoading:false,...o})`;`renderWithTheme(<UserCard user={getMockUser({role:'admin'})}/>)`;
  Py(`tests/conftest.py`):`@pytest.fixture def make_user():return lambda **o:User(**({"id":"u-1","name":"A","email":"a@b","role":"user"}|o))`
}
§MOCK{
  Jest:`jest.mock(m,()=>({Analytics:{logEvent:jest.fn()}}))`→`jest.requireMock(m).Analytics.logEvent`;`beforeEach(()=>jest.clearAllMocks())`;`expect(mock).toHaveBeenCalledWith(x)`;
  Py:`from unittest.mock import patch,ANY`;`@patch("pkg.mod.fn",autospec=True)`(patch_lookup_site);`mock.assert_called_once_with(user.email,ANY)`;
  pytest-mock:auto_resets_`mocker`_per_test(¬manual_reset);awaited_`async def`⇒`mocker.AsyncMock`
}
§STR{
  Jest:`describe(n,()=>{beforeEach(()=>jest.clearAllMocks());describe('Rendering'|'User interactions',()=>{it(...,async()=>{})})})`;
  Py:`class TestUserService: def test_*(self,make_user,mocker)`
}
§RTL{
  exists:`expect(screen.getByText(t)).toBeTruthy()`;absent:`expect(screen.queryByText(t)).toBeNull()`;async:`await waitFor(()=>expect(screen.getByText(t)).toBeTruthy())`;
  RN:`fireEvent.changeText(screen.getByLabelText(l),v)`;`fireEvent.press(screen.getByTestId(id))`
}
§PY{
  `@pytest.mark.parametrize("role,expected",[("admin",True),("user",False)])`;
  `@pytest.mark.asyncio`+`mocker.patch(path,return_value=...)`+`await fn()`;
  DB:`create_engine("sqlite:///:memory:")`→`Base.metadata.create_all(engine)`→`with sessionmaker(bind=engine)() as s:yield s`
}
§CMD{`npm test` | `npm test -- -t "MyComponent"` | `npm run test:coverage` | `pytest` | `pytest -k "UserService"` | `pytest --cov=myapp`}
