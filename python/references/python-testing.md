@REF:python-testing
§D:scope{apply⇔(new_code∨suite_design∨cov_review∨test_infra);target:pytest≥9.0+pytest-asyncio≥1.4}
§R:philosophy{
  TDD:RED(failing_test)→GREEN(minimal_pass)→REFACTOR(keep_green);
  cov:target≥80%∧critical_paths=100%∧core_cov>90%;
  cmd:`uv run pytest --cov=mypackage --cov-report=term-missing --cov-report=html`
}
§PAT:assert{
  eq/neq:`==`,`!=`;truth:`assert res`,`assert not res`;identity:`is True`,`is False`,`is None`;
  membership:`in`,`not in`;range:`0 <= res <= 100`;type:`isinstance(res, str)`;
  exceptions:
  - `with pytest.raises(ValueError): ...`
  - `with pytest.raises(ValueError, match="invalid input"): ...`
  - `with pytest.raises(CustomError) as exc_info:`→assert `exc_info.value.code == 400`,`"error" in str(exc_info.value)`
}
§PAT:subtests{
  native(pytest≥9.0;replaces `pytest-subtests`):track_independent_failures_in_loops_without_early_abort;
```python
def test_all_configs_valid(subtests: pytest.Subtests, paths: list[Path]) -> None:
    for path in paths:
        with subtests.test(path=path.name):
            assert validate_config(path)
```
}
§PAT:fixtures{
  basic:`@pytest.fixture def sample_data() -> dict[str, Any]: return {...}`;
  teardown:`@pytest.fixture`→setup→`yield resource`→teardown(`close()`/`remove()`);
  scopes:`function`(default),`class`,`module`(`scope="module"`),`package`,`session`(`scope="session"`);
  params:`@pytest.fixture(params=[1, 2, 3]) def number(request: pytest.FixtureRequest) -> int: return request.param`;
  compose:inject_multiple_fixtures_as_test_args;`@pytest.fixture(autouse=True)` runs ∀ test;
  `tests/conftest.py`:shared_app_client+`auth_headers`→`POST /api/login`→`{"Authorization": f"Bearer {token}"}`
}
§PAT:parametrize{
  `@pytest.mark.parametrize("a,b,expected", [(2,3,5), (0,0,0)])`;
  unique_ids:`ids=["valid-email", "missing-at", "missing-domain"]` (enforced_unique_by `strict = true` / `strict_parametrization_ids` in pytest_9);
  backend_matrix:`@pytest.fixture(params=["sqlite", "postgresql"])`
}
§PAT:property_based{
  hypothesis:`from hypothesis import given, strategies as st`;
  edge_cases:`@given(st.lists(st.integers())) def test_sort_idempotent(xs: list[int]) -> None: assert sorted(sorted(xs)) == sorted(xs)`
}
§PAT:markers{
  decor:`@pytest.mark.slow`,`@pytest.mark.integration`,`@pytest.mark.unit`;
  select:`pytest -m "not slow"`,`pytest -m integration`,`pytest -m "integration or slow"`,`pytest -m "unit and not slow"`;
  register:declare ∀ custom markers in `[tool.pytest.markers]` (enforced by `strict = true`)
}
§PAT:mock{
  import:`from unittest.mock import patch, Mock, AsyncMock, mock_open, PropertyMock`;
  fn:`@patch("mypackage.external_api_call")`→`m.return_value = ...`→`m.assert_called_once()`/`m.assert_called_once_with(...)`;
  async_fn:`@patch("mypackage.fetch", new_callable=AsyncMock)`→`m.return_value = ...`→`m.assert_awaited_once_with(...)`;
  err:`m.side_effect = ConnectionError("Network error")`;
  ctx:`@patch("builtins.open", new_callable=mock_open)`→`m.return_value.read.return_value = ...`;
  autospec:`@patch("mypackage.DBConnection", autospec=True)` (catches_API_misuse_on `.return_value`);
  cls_inst:`repo_mock.return_value.save.return_value = ...`;
  prop:`type(cfg).debug = PropertyMock(return_value=True)`
}
§PAT:async{
  breaking_1.x:legacy `event_loop` fixture REMOVED¬redefine;MUST set `asyncio_default_fixture_loop_scope` in `pyproject.toml`;
  loop_scoping:match `loop_scope` across fixture+test (prevents `MultipleEventLoopsRequestedError`);no collector class required in 1.x;
  custom_loop:use `pytest_asyncio_loop_factories` hook (replaces_deprecated_loop_policies);
  fastapi_lifespan:`ASGITransport` ¬runs lifespan⇒wrap in `asgi_lifespan.LifespanManager`;
```python
@pytest_asyncio.fixture(scope="session", loop_scope="session")
async def async_client() -> AsyncIterator[AsyncClient]:
    app = create_app()
    async with LifespanManager(app) as manager:
        async with AsyncClient(transport=ASGITransport(app=manager.app), base_url="http://test") as client:
            yield client

@pytest.mark.asyncio(loop_scope="session")
async def test_health(async_client: AsyncClient) -> None:
    res = await async_client.get("/health")
    assert res.status_code == 200
```
}
§PAT:side_effects{
  `tmp_path`(rec):built-in `pathlib.Path` (`(tmp_path / "test.txt").write_text(..., encoding="utf-8")`, auto-cleaned);
  `monkeypatch`:env_vars(`monkeypatch.setenv`),attrs(`monkeypatch.setattr`),cwd(`monkeypatch.chdir`);
  ¬`tmpdir`(legacy `py.path.local`)∧¬manual `tempfile`+`os.unlink`
}
§PAT:org{
  layout:`tests/{conftest.py,unit/{test_models.py,test_utils.py,test_services.py},integration/{test_api.py,test_database.py},e2e/{test_user_flow.py}}`;
  class:`class TestUserService:`+`@pytest.fixture(autouse=True) def setup(self):`
}
§R:best_practices{
  DO:TDD(red-green-refactor)∧1_behavior/test∧descriptive_names(`test_user_login_with_invalid_credentials_fails`)∧fixtures_for_DRY∧mock_external_deps(autospec)∧edge_cases(empty,`None`,bounds,hypothesis)∧cov≥80%(core>90%,crit=100%)∧fast_tests+marks∧`strict = true`;
  ANTI:¬test_internals(test_behavior)∧¬complex_conditionals_in_tests∧¬ignore_failures∧¬`--disable-warnings`∧¬test_3rd_party∧¬shared_state∧¬manual_try_except(use `pytest.raises`)∧¬`print`∧¬brittle_over_specific_mocks∧¬override `event_loop` fixture
}
§PAT:common{
  sync_api:`TestClient(app)`(FastAPI)/`app.test_client()`(Flask)→`client.get("/api/users/1")`→`200`;
  db_rollback:
```python
@pytest.fixture
def db_session() -> Iterator[Session]:
    with Session(bind=engine) as session:
        session.begin_nested()
        yield session
        session.rollback()
```
}
§CFG:pytest{
  native_toml(pytest≥9.0;mutually_exclusive_with `[tool.pytest.ini_options]`):
```toml
[tool.pytest]
minversion = "9.0"
strict = true
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = ["-ra", "--cov=mypackage", "--cov-report=term-missing"]
asyncio_mode = "auto"
asyncio_default_fixture_loop_scope = "function"

[tool.pytest.markers]
slow = "marks tests as slow"
integration = "marks tests as integration tests"
unit = "marks tests as unit tests"
```
}
§CMD:pytest{
  all:`uv run pytest`;
  file:`uv run pytest tests/test_utils.py`;
  node:`uv run pytest tests/test_utils.py::test_function`;
  verbose:`uv run pytest -v`;
  cov:`uv run pytest --cov=mypackage --cov-report=html`;
  marks:`uv run pytest -m "not slow"`;
  fail_ctrl:`uv run pytest -x` | `uv run pytest --maxfail=3` | `uv run pytest --lf`;
  filter:`uv run pytest -k "test_user"`;
  debug:`uv run pytest --pdb`;
  mem_prof:`uv run python -m memray run -m pytest` | `uv run scalene -- -m pytest`
}
§R:quick{`pytest.raises()`,`subtests.test()`,`@pytest.fixture()`,`@pytest.mark.parametrize()`,`@given()`,`@pytest.mark.slow`,`@patch(autospec=True)`,`AsyncMock`,`tmp_path`,`monkeypatch`,`strict = true`}
