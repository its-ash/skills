@REF:python-testing
§D:scope{apply⇔(new_code∨suite_design∨cov_review∨test_infra)}
§R:philosophy{
  TDD:RED(failing_test)→GREEN(minimal_pass)→REFACTOR(keep_green)
  cov:target≥80% ∧ critical_paths=100%
  cmd:`pytest --cov=mypackage --cov-report=term-missing --cov-report=html`
}
§PAT:assert{
  eq/neq:`==`, `!=`; truth:`assert res`, `assert not res`; identity:`is True`, `is False`, `is None`
  membership:`in`, `not in`; range:`0 <= res <= 100`; type:`isinstance(res, str)`
  exceptions:
  - `with pytest.raises(ValueError): ...`
  - `with pytest.raises(ValueError, match="invalid input"): ...`
  - `with pytest.raises(CustomError) as exc_info:` → assert `exc_info.value.code == 400`, `"error" in str(exc_info.value)`
}
§PAT:fixtures{
  basic:`@pytest.fixture def sample_data(): return {...}`
  teardown:`@pytest.fixture`→setup→`yield resource`→teardown(`close()`/`remove()`)
  scopes:`function`(default), `module`(`scope="module"`), `session`(`scope="session"`)
  params:`@pytest.fixture(params=[1, 2, 3]) def number(request): return request.param`
  compose:inject multiple fixtures as test args; `@pytest.fixture(autouse=True)` runs ∀ test
  `tests/conftest.py`(Flask):`with app.test_client() as client: yield client`; `auth_headers`→`POST /api/login`→`{"Authorization": f"Bearer {token}"}`
}
§PAT:parametrize{
  `@pytest.mark.parametrize("a,b,expected", [(2,3,5), (0,0,0)])`
  `ids=["valid-email", "missing-at", "missing-domain"]` for readable case IDs
  backend_matrix:`@pytest.fixture(params=["sqlite", "postgresql", "mysql"])`
}
§PAT:markers{
  decor:`@pytest.mark.slow`, `@pytest.mark.integration`, `@pytest.mark.unit`
  select:`pytest -m "not slow"`, `pytest -m integration`, `pytest -m "integration or slow"`, `pytest -m "unit and not slow"`
  register:`slow`, `integration`, `unit`, `django` in `pytest.ini`/`pyproject.toml`
}
§PAT:mock{
  import:`from unittest.mock import patch, Mock, mock_open, PropertyMock`
  fn:`@patch("mypackage.external_api_call")`→`m.return_value = ...`→`m.assert_called_once()` / `m.assert_called_once_with(...)`
  err:`m.side_effect = ConnectionError("Network error")`
  ctx:`@patch("builtins.open", new_callable=mock_open)`→`m.return_value.read.return_value = ...`
  autospec:`@patch("mypackage.DBConnection", autospec=True)` (catches API misuse on `.return_value`)
  cls_inst:`repo_mock.return_value.save.return_value = ...`
  prop:`type(cfg).debug = PropertyMock(return_value=True)`
}
§PAT:async{
  test:`@pytest.mark.asyncio async def test_...(): ...`
  mock:`api_call_mock.assert_awaited_once()`
  fastapi_lifespan:`ASGITransport` ¬runs lifespan events⇒install `asgi-lifespan`∧wrap in `LifespanManager`; ref:https://github.com/fastapi/fastapi/blob/master/docs/en/docs/advanced/async-tests.md
```python
@pytest_asyncio.fixture
async def async_client():
    app = create_app()
    async with LifespanManager(app) as manager:
        async with AsyncClient(transport=ASGITransport(app=manager.app), base_url="http://test") as client:
            yield client
```
}
§PAT:side_effects{
  temp_manual:`tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt')` + `try/finally: os.unlink(temp_path)`
  `tmp_path`:built-in `pathlib.Path` (`(tmp_path / "test.txt").write_text(...)`, auto-cleaned)
  `tmpdir`:built-in (`tmpdir.join("test.txt").write(...)`)
}
§PAT:org{
  layout:`tests/{conftest.py,__init__.py,unit/{__init__.py,test_models.py,test_utils.py,test_services.py},integration/{__init__.py,test_api.py,test_database.py},e2e/{__init__.py,test_user_flow.py}}`
  class:`class TestUserService:` + `@pytest.fixture(autouse=True) def setup(self):`
}
§R:best_practices{
  DO:TDD(red-green-refactor) ∧ 1_behavior/test ∧ descriptive_names(`test_user_login_with_invalid_credentials_fails`) ∧ fixtures_for_DRY ∧ mock_external_deps ∧ edge_cases(empty,`None`,bounds) ∧ cov≥80%(critical=100%) ∧ fast_tests+marks
  ANTI:¬test_internals(test_behavior) ∧ ¬complex_conditionals_in_tests ∧ ¬ignore_failures ∧ ¬test_3rd_party ∧ ¬shared_state ∧ ¬manual_try_except(use `pytest.raises`) ∧ ¬`print` ∧ ¬brittle_over_specific_mocks
}
§PAT:common{
  flask_api:`client.get("/api/users/1")`→`200`, `client.post("/api/users", json={...})`→`201`
  db_rollback:
```python
@pytest.fixture
def db_session():
    session = Session(bind=engine)
    session.begin_nested()
    yield session
    session.rollback()
    session.close()
```
  cls_methods:`class TestCalculator:` with fixture `calculator(self)`
}
§CFG:pytest{
```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = --strict-markers --disable-warnings --cov=mypackage --cov-report=term-missing --cov-report=html
markers =
    slow: marks tests as slow
    integration: marks tests as integration tests
    unit: marks tests as unit tests
```
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = ["--strict-markers", "--cov=mypackage", "--cov-report=term-missing", "--cov-report=html"]
markers = ["slow: marks tests as slow", "integration: marks tests as integration tests", "unit: marks tests as unit tests"]
```
}
§CMD:pytest{
  all:`pytest`
  file:`pytest tests/test_utils.py`
  node:`pytest tests/test_utils.py::test_function`
  verbose:`pytest -v`
  cov:`pytest --cov=mypackage --cov-report=html`
  marks:`pytest -m "not slow"`
  fail_ctrl:`pytest -x` | `pytest --maxfail=3` | `pytest --lf`
  filter:`pytest -k "test_user"`
  debug:`pytest --pdb`
}
§R:quick{`pytest.raises()`, `@pytest.fixture()`, `@pytest.mark.parametrize()`, `@pytest.mark.slow`, `pytest -m "not slow"`, `@patch()`, `tmp_path`, `pytest --cov`, `assert`}
