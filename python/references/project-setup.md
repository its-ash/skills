@REF:project-setup
§R:versions{
  supported:Python≥3.12(3.12/3.13:sec_only;3.14:active_bugfix;3.15:latest_feature);EOL:{≤3.10};
  toolchains:uv(0.13.x)+ruff(0.17.x)+PEP_735([dependency-groups])+uv_build(src_layout);
  backends:FastAPI(0.165.x)|Django(6.1.x)|Pydantic(2.14.x)|SQLAlchemy(2.1.x,sqlalchemy[asyncio])|httpx(0.28.x);
  data:Polars(2.x,streaming_default)|Pandas(3.1.x,CoW_mandatory,native_str)
}
§CMD:uv{
  init_app:`uv init --app myapp && cd myapp && uv python install 3.14 && uv python pin 3.14`;
  init_lib:`uv init --lib mylib` (defaults to `src/` + `uv_build` backend);
  deps:`uv add fastapi pydantic httpx` ∧ `uv add --dev pytest pytest-asyncio pytest-cov ruff ty pip-audit`;
  sync:`uv sync` (local) | `uv sync --frozen` (CI) | `uv sync --frozen --no-dev` (prod);
  exec:`uv run pytest` | `uv run ruff check --fix .` | `uv run ruff format .` | `uv run ty check` | `uv run pip-audit`
}
§PAT:layout{
  script:`main.py,utils.py,pyproject.toml`;
  med_api:`app/{main.py,models/,schemas/,routes/,services/},tests/,pyproject.toml,uv.lock`;
  lg_pkg:`src/myapp/{__init__.py,core/,api/,services/,models/},tests/,pyproject.toml,uv.lock`;
  roles:{models:ORM,schemas:Pydantic_v2,routes:thin_endpoints,services:business_logic}
}
§CFG:pyproject.toml{
```toml
[build-system]
requires = ["uv_build>=0.13,<0.14"]
build-backend = "uv_build"

[project]
name = "myapp"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = ["fastapi>=0.165.0", "pydantic>=2.14.0", "httpx>=0.28.1"]

[dependency-groups]
dev = ["pytest>=9.0", "pytest-asyncio>=1.4", "pytest-cov", "hypothesis", "ruff>=0.17.0", "ty", "pip-audit"]

[tool.ruff]
target-version = "py312"
line-length = 88

[tool.ruff.lint]
select = ["E", "F", "W", "I", "UP", "B", "SIM", "S", "C90"]

[tool.ruff.format]
quote-style = "double"

[tool.pytest]
minversion = "9.0"
strict = true
testpaths = ["tests"]
addopts = ["-ra", "--cov=myapp", "--cov-report=term-missing"]
asyncio_mode = "auto"
asyncio_default_fixture_loop_scope = "function"

[tool.mypy]
strict = true
```
}
§CFG:.pre-commit-config.yaml{
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.17.6
    hooks:
      - id: ruff-check
        args: [--fix]
      - id: ruff-format
  - repo: local
    hooks:
      - id: typecheck
        name: typecheck
        entry: uv run ty check  # or pyrefly check / basedpyright / mypy --num-workers=auto
        language: system
        types: [python]
        pass_filenames: false
```
}
§CFG:ci_github_actions{
  setup:`astral-sh/setup-uv@v5`(with:`enable-cache:true`)→`uv python install`→`uv sync --frozen`;
  gates:`uv run ruff check .` ∧ `uv run ruff format --check .` ∧ `uv run ty check` ∧ `uv run pytest` ∧ `uv run pip-audit`
}
§CFG:dockerfile_uv_multistage{
```dockerfile
FROM python:3.14-slim AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
WORKDIR /app
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-dev --no-install-project
COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv uv sync --frozen --no-dev

FROM python:3.14-slim AS runtime
WORKDIR /app
COPY --from=builder /app/.venv /app/.venv
COPY . /app
ENV PATH="/app/.venv/bin:$PATH"
RUN useradd -u 1000 appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 8000
CMD ["python", "-m", "myapp.main"]
```
}
§D:toolbox{
  pkg|venv|py_ver|lock⇒uv(0.13.x)+uv_build+PEP_735¬{pip,pyenv,venv,poetry,pip-tools};
  lint|fmt|sec_static⇒ruff(0.17.x:check+format+S_rules)¬{black,isort,flake8,pylint,bandit};
  types⇒ty(Astral,fast)⊕pyrefly(Meta_1.4.x,infer)⊕basedpyright(1.40.x,max_strict)⊕mypy(2.4.x_--num-workers,plugins);
  http⇒httpx(0.28.x)¬requests_in_async;
  async_pg|orm⇒asyncpg∧SQLAlchemy_2.1(sqlalchemy[asyncio]);
  data⇒Polars_2.x(default_streaming,out_of_core)⊕Pandas_3.x(CoW_default,native_str);
  test⇒pytest_9(strict,subtests),pytest-asyncio_1.x,hypothesis,pytest-cov,pytest-benchmark;
  profile⇒profiling.sampling(Tachyon,py≥3.15),py-spy,cProfile,memray,scalene¬memory_profiler(unmaintained);
  vuln_audit⇒pip-audit¬safety
}
§CHK:ship{Py≥3.12(rec_3.14/3.15;¬EOL)∧uv.lock∧[dependency-groups];record(fw,async/sync);pyproject∋(ruff,pytest_9,type_checker);hints∀public_fn;Pydantic_v2(req,settings);DI(db,auth,cfg);AppError+handlers;tests(unit,async_int,crit)∧core_cov>90%;CI(ruff_check+format,typecheck,pytest,pip-audit)∀push;multi-stage_uv_Docker(non_root,runtime_only);¬secrets∧err¬leak_internals}
