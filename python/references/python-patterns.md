@REF:python-patterns
§D:scope{apply⇔(new_code∨review∨refactor∨pkg_design);target:Python≥3.12(3.14_active,3.15_latest);goal:(readability∧explicitness∧least_surprise)}
§R:core{
  readability:descriptive_ids∧docstrings(public_fns)∧clarity>cleverness;
  explicit>implicit:`logging.basicConfig(level=logging.INFO, format="%(asctime)s %(name)s %(levelname)s %(message)s")`∧¬hidden_side_effects(`mod.setup()`);
  EAFP>LBYL:`try: return d[k] except KeyError: return default`¬`if k in d`;
  encoding:py≥3.15_defaults_UTF-8;py3.12-3.14⇒explicit `encoding="utf-8"` on `open()`/`Path.read_text()`
}
§PAT:types{
  builtins+union:`list[str]`,`dict[str, int]`,`str | None`¬`typing.{List,Dict,Optional,Union}`;
  PEP_695(py≥3.12):`type JSON = dict[str, JSON] | list[JSON] | str | int | float | bool | None`;`def first[T](items: Sequence[T]) -> T | None:`;`class Box[T]: ...`;
  helpers:`typing.Self`(fluent_return)∧`@typing.override`(catch_subclass_typos)∧`Protocol`(structural_duck_typing:`class Renderable(Protocol): def render(self) -> str: ...`);
  PEP_649(py≥3.14):annotations_deferred_natively+`annotationlib`⇒¬need `from __future__ import annotations` on py≥3.14
}
§PAT:modern_stdlib{
  t-strings(PEP_750,py≥3.14):`tmpl = t"SELECT * FROM users WHERE id = {uid}"`→`Template`(safe_SQL/HTML/shell_sanitization)¬f-string_in_queries;
  lazy_import(PEP_810,py≥3.15):`lazy import heavy_mod` | `lazy from pkg import fn`→defers_load_until_access(fast_CLI/startup¬fn_local_imports);
  immutable_cfg+sentinel(py≥3.15):`frozendict`∧`sentinel()`(distinguishes omitted_arg vs explicit `None`);
  zstd(PEP_784,py≥3.14):`from compression import zstd`∧native `.zst`∈`tarfile`/`zipfile`
}
§PAT:errors{
  catch_specific(`FileNotFoundError`,`json.JSONDecodeError`)¬bare_`except:`¬silent_`return None`;
  chain:`raise ConfigError("invalid config") from e`(preserves_traceback);
  hierarchy:`AppError(Exception)`→{`ValidationError(AppError)`,`NotFoundError(AppError)`};
  exc_groups:`except* ValueError as eg:`(handles `asyncio.TaskGroup`/`ExceptionGroup`)
}
§PAT:ctx_mgr{
  resource:`with Path(path).open(encoding="utf-8") as f:`¬manual `open()`+`try/finally: f.close()`;
  fn_ctx:`@contextmanager`(`contextlib`)+`time.perf_counter()`+`yield`;
  async_ctx:`@asynccontextmanager`∨`__aenter__`/`__aexit__`;
  cls_ctx:
```python
class DatabaseTransaction:
    def __init__(self, conn: Connection) -> None: self.conn = conn
    def __enter__(self) -> Self: self.conn.begin_transaction(); return self
    def __exit__(self, exc_type: type[BaseException] | None, exc_val: BaseException | None, exc_tb: TracebackType | None) -> bool:
        self.conn.commit() if exc_type is None else self.conn.rollback()
        return False  # ¬suppress exceptions
```
}
§PAT:comp_gen{
  simple_transform⇒list_comp(`[u.name for u in users if u.is_active]`);
  complex_multi_cond⇒expand→fn/generator¬nested/multi-`if` one-liner;
  lazy_eval⇒gen_expr(`sum(x * x for x in range(1_000_000))`)¬`sum([...])`(avoids_intermediate_list);
  large_stream⇒gen_fn(`def read_large_file(path: Path) -> Iterator[str]: ... yield line.strip()`)
}
§PAT:data{
  `@dataclass(slots=True, frozen=True, kw_only=True)`:auto `__init__`,`__repr__`,`__eq__`,low_mem,immutable;mutable_default⇒`field(default_factory=list)`;
  validation:boundary_inputs⇒Pydantic_v2;domain_invariants⇒`__post_init__(self)`→raise `ValueError`;
  `NamedTuple`(`typing.NamedTuple`):lightweight_immutable_tuple+methods(`class Point(NamedTuple): x: float; y: float`)
}
§PAT:decorators{
  fn:`def logged[**P, R](fn: Callable[P, R]) -> Callable[P, R]:`+`@functools.wraps(fn)`;
  param:`def repeat(times: int)`→`def decorator[**P, R](fn: Callable[P, R]) -> Callable[P, R]`→`@functools.wraps(fn) def wrapper(*args: P.args, **kwargs: P.kwargs) -> R`;
  cls:
```python
class CountCalls[**P, R]:
    def __init__(self, func: Callable[P, R]) -> None:
        functools.update_wrapper(self, func)
        self.func, self.count = func, 0
    def __call__(self, *args: P.args, **kwargs: P.kwargs) -> R:
        self.count += 1
        return self.func(*args, **kwargs)
```
}
§PAT:concurrency{
  io_async_structured(rec):`async with asyncio.timeout(10), asyncio.TaskGroup() as tg:`+`asyncio.Semaphore(max_conc)`+`async with httpx.AsyncClient() as client:`;
  io_async_partial_fail:`await asyncio.gather(*tasks, return_exceptions=True)`(only_when_sibling_cancel_unwanted);
  blocking_in_async:`await asyncio.to_thread(blocking_fn, *args)`¬direct_blocking_call_in_async_def;
  io_threads(sync_code):`ThreadPoolExecutor(max_workers=10)`→`executor.submit`+`as_completed`+`future.result()`;
  cpu_parallel:`ProcessPoolExecutor()`→`list(executor.map(fn, datasets))`⊕py≥3.14_subinterpreters(`concurrent.interpreters`,PEP_734)⊕py≥3.14_free_threaded(`python3.14t`/`3.15t`,PEP_779)
}
§PAT:pkg{
  layout:`myproject/{src/mypackage/{__init__.py,main.py,api/{__init__.py,routes.py},models/{__init__.py,user.py},services/{__init__.py,user.py}},tests/{conftest.py,test_api.py,test_models.py},pyproject.toml,uv.lock,README.md,.gitignore}`;
  imports:order=(stdlib→3rd_party→local);tool:`ruff check --select I --fix`¬`isort`;
  `__init__.py`:docstring,`__version__`,re-exports,`__all__ = [...]`
}
§PAT:perf_mem{
  `@dataclass(slots=True)`∨`__slots__ = ("x", "y")`⇒eliminates `__dict__` overhead;
  streaming:`Iterator[str]`(`yield`)¬`[line.strip() for line in f]`;
  str_build:`"".join(str(x) for x in items)`(`O(n)`)∨`io.StringIO`¬`+=` in loop(`O(n²)`);
  profile:`python -m profiling.sampling`(Tachyon,py≥3.15)|`py-spy`|`cProfile`|`memray`|`scalene`
}
§CMD:tools{
  fmt:`uv run ruff format .`;
  lint:`uv run ruff check --fix .` (replaces `flake8`,`isort`,`pylint`,`bandit` via `S` rules);
  types:`uv run ty check` | `uv run pyrefly check` | `uv run basedpyright` | `uv run mypy --num-workers=auto .`;
  test:`uv run pytest --cov=mypackage --cov-report=term-missing`;
  sec:`uv run pip-audit` ∧ `uv run ruff check --select S .`
}
§CFG:pyproject{
```toml
[project]
name = "mypackage"
version = "1.0.0"
requires-python = ">=3.12"
dependencies = ["httpx>=0.28.1", "pydantic>=2.14.0"]
[dependency-groups]
dev = ["pytest>=9.0", "pytest-cov", "ruff>=0.17.0", "ty", "pip-audit"]
[tool.ruff]
target-version = "py312"
line-length = 88
[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "UP", "B", "SIM", "S"]
[tool.pytest]
minversion = "9.0"
strict = true
testpaths = ["tests"]
addopts = ["--cov=mypackage", "--cov-report=term-missing"]
```
}
§R:idioms{EAFP,`with`/`async with`,PEP_695_generics,`@dataclass(slots=True)`,list_comps,generators,t-strings(≥3.14),`lazy import`(≥3.15),`pathlib.Path`,`enumerate`}
§ANTI{
  `items=[]` default_arg⇒`items: list[T] | None = None`+`if items is None: items = []`;
  `type(obj) == list`⇒`isinstance(obj, list)`;
  `value == None`⇒`value is None`;
  `from mod import *`⇒explicit_imports;
  bare `except: pass`⇒catch `SpecificError`+log;
  `requests.get()`∈`async def`⇒`httpx.AsyncClient`∨`asyncio.to_thread`;
  f-string∈SQL/HTML/shell⇒parameterized_query∨t-strings(≥3.14);
  `black`/`isort`/`pylint`/`safety`⇒`ruff`+`pip-audit`
}
