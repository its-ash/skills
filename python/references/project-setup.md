# Python project setup

## Environment
```bash
uv venv .venv && source .venv/bin/activate
uv pip install -r requirements.txt
uv lock
```

## Layouts
| Size | Layout |
|---|---|
| Script | `main.py`, `utils.py`, `requirements.txt` |
| Medium API | `app/{main.py, models/, schemas/, routes/, services/}`, `tests/`, `pyproject.toml` |
| Large app | `src/myapp/{core/, api/, services/, models/}`, `tests/`, `pyproject.toml` |

`models/` = ORM, `schemas/` = Pydantic, `routes/` = endpoints, `services/` = business logic.

## Minimal `pyproject.toml`
```toml
[project]
name = "myapp"
version = "0.1.0"
requires-python = ">=3.12"

[tool.ruff]
line-length = 88
lint.select = ["E", "F", "W", "C90"]

[tool.mypy]
strict = true
```

## `.pre-commit-config.yaml`
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.4.0
    hooks:
      - id: ruff
        args: [--fix]
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.10.0
    hooks:
      - id: mypy
```

## Toolbox
| Need | Tool |
|---|---|
| Packages, venv, lock | `uv` |
| Lint and format | `ruff` |
| Types | `mypy` (strict) or `pyright` |
| HTTP client | `httpx` |
| Async Postgres / ORM | `asyncpg`, SQLAlchemy 2.0 async |
| Tests | `pytest`, `pytest-asyncio`, `hypothesis`, `pytest-cov`, `pytest-benchmark` |
| Profiling | `cProfile`, `py-spy`, `memory_profiler` |

## Ship checklist
- [ ] Python ≥ 3.12; deps locked with `uv lock`.
- [ ] Framework and async/sync choice recorded.
- [ ] `pyproject.toml` has ruff and mypy config.
- [ ] Type hints on all public functions.
- [ ] Pydantic for request validation and settings.
- [ ] DI for DB session, auth, config.
- [ ] `AppError` hierarchy + registered handlers.
- [ ] Unit, async integration, and critical-path tests; core coverage > 90%.
- [ ] CI runs ruff, mypy, pytest on every push.
- [ ] Multi-stage Dockerfile copies only runtime files.
- [ ] No secrets in code; error responses leak no internals.
