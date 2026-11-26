@REF:python-patterns
§D:scope{apply⇔(new_code∨review∨refactor∨pkg_design); goal:(readability∧explicitness∧least_surprise)}
§R:core{
  readability:descriptive_ids∧docstrings(public_fns)∧clarity>cleverness
  explicit>implicit:`logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')` ∧ ¬hidden_side_effects(`mod.setup()`)
  EAFP>LBYL:`try: return d[k] except KeyError: return default` ¬`if k in d`
}
§PAT:types{
  py≥3.9⇒builtins(`list[str]`, `dict[str, int]`); py≤3.8⇒`typing.{List,Dict,Optional,Any}`
  alias∧generic:`JSON = Union[dict[str, Any], list[Any], str, int, float, bool, None]`; `T = TypeVar('T')`; `def first(items: list[T]) -> T | None`
  protocol(duck_typing):`class Renderable(Protocol): def render(self) -> str: ...`
}
§PAT:errors{
  catch_specific(`FileNotFoundError`,`json.JSONDecodeError`) ¬bare_`except:` ¬silent_`return None`
  chain:`raise ConfigError(f"...") from e` (preserves traceback)
  hierarchy:`AppError(Exception)`→{`ValidationError(AppError)`,`NotFoundError(AppError)`}
}
§PAT:ctx_mgr{
  resource:`with open(path, 'r') as f:` ¬manual `open()`+`try/finally: f.close()`
  fn_ctx:`@contextmanager` (`contextlib`) + `time.perf_counter()` + `yield`
  cls_ctx:
```python
class DatabaseTransaction:
    def __init__(self, conn): self.conn = conn
    def __enter__(self): self.conn.begin_transaction(); return self
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.conn.commit() if exc_type is None else self.conn.rollback()
        return False  # ¬suppress exceptions
```
}
§PAT:comp_gen{
  simple_transform⇒list_comp(`[u.name for u in users if u.is_active]`)
  complex_multi_cond⇒expand→fn/generator ¬nested/multi-`if` one-liner
  lazy_eval⇒gen_expr(`sum(x * x for x in range(1_000_000))`) ¬`sum([...])` (avoids intermediate list)
  large_stream⇒gen_fn(`def read_large_file(path: str) -> Iterator[str]: ... yield line.strip()`)
}
§PAT:data{
  `@dataclass`:auto `__init__`,`__repr__`,`__eq__`; mutable/dynamic_default⇒`field(default_factory=datetime.now)`
  validation:`__post_init__(self)`→raise `ValueError` (e.g. `"@" not in self.email`, `self.age < 0 or self.age > 150`)
  `NamedTuple`(`typing.NamedTuple`):immutable record + methods (`class Point(NamedTuple): x: float; y: float`)
}
§PAT:decorators{
  fn:`@functools.wraps(func)` + `(*args, **kwargs)`
  param:`def repeat(times: int)`→`def decorator(func: Callable) -> Callable`→`@functools.wraps(func) def wrapper(*args, **kwargs)`
  cls:
```python
class CountCalls:
    def __init__(self, func: Callable):
        functools.update_wrapper(self, func)
        self.func, self.count = func, 0
    def __call__(self, *args, **kwargs):
        self.count += 1
        return self.func(*args, **kwargs)
```
}
§PAT:concurrency{
  io_threads:`concurrent.futures.ThreadPoolExecutor(max_workers=10)`→`executor.submit`+`as_completed`+`future.result()` (e.g. `urllib.request.urlopen`)
  cpu_mp:`concurrent.futures.ProcessPoolExecutor()`→`list(executor.map(fn, datasets))`
  io_async:`asyncio`+`aiohttp.ClientSession()`→`await asyncio.gather(*tasks, return_exceptions=True)`
}
§PAT:pkg{
  layout:`myproject/{src/mypackage/{__init__.py,main.py,api/{__init__.py,routes.py},models/{__init__.py,user.py},utils/{__init__.py,helpers.py}},tests/{__init__.py,conftest.py,test_api.py,test_models.py},pyproject.toml,README.md,.gitignore}`
  imports:order=(stdlib→3rd_party→local); tool:`isort`
  `__init__.py`:docstring, `__version__`, re-exports, `__all__ = [...]`
}
§PAT:perf_mem{
  `__slots__ = ['x', 'y']`⇒eliminates `__dict__` overhead
  streaming:`Iterator[str]` (`yield`) ¬`[line.strip() for line in f]`
  str_build:`"".join(str(x) for x in items)` (`O(n)`) ∨ `io.StringIO` ¬`+=` in loop (`O(n²)`)
}
§CMD:tools{
  fmt:`black .` ∧ `isort .`
  lint:`ruff check .` ∧ `pylint mypackage/`
  types:`mypy .`
  test:`pytest --cov=mypackage --cov-report=html`
  sec:`bandit -r .` ∧ `pip-audit` ∧ `safety check`
}
§CFG:pyproject{
```toml
[project]
name = "mypackage"
version = "1.0.0"
requires-python = ">=3.9"
dependencies = ["requests>=2.31.0", "pydantic>=2.0.0"]
[project.optional-dependencies]
dev = ["pytest>=7.4.0", "pytest-cov>=4.1.0", "black>=23.0.0", "ruff>=0.1.0", "mypy>=1.5.0"]
[tool.black]
line-length = 88
target-version = ['py39']
[tool.ruff]
line-length = 88
select = ["E", "F", "I", "N", "W"]
[tool.mypy]
python_version = "3.9"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "--cov=mypackage --cov-report=term-missing"
```
}
§R:idioms{EAFP, `with` ctx_mgrs, list_comps, generators, type_hints, `@dataclass`, `__slots__`, f-strings(≥3.6), `pathlib.Path`(≥3.4), `enumerate`}
§ANTI{
  `items=[]` default_arg⇒`items=None` + `if items is None: items = []`
  `type(obj) == list`⇒`isinstance(obj, list)`
  `value == None`⇒`value is None`
  `from mod import *`⇒explicit imports
  bare `except: pass`⇒catch `SpecificError` + log
}
