---
name: python
description: "Guidance for modern Python 3.12+ development covering project layout, async versus sync decisions, framework selection, uv/ruff/mypy tooling, testing, profiling, and deployment. Use when writing .py code, scaffolding pyproject.toml, choosing FastAPI/Django/Flask, debugging asyncio or asyncio.gather, configuring uv/ruff/mypy/pytest, optimizing performance, or deploying Python services. Sub-skills: python-patterns, python-testing, windows-installer."
---
# Python (3.12+)
Build, test, and ship modern Python with uv, ruff, mypy, and pytest.

## Core rules
- Target Python ≥ 3.12. Manage env and deps with `uv`; commit the `uv lock` file.
- Use one `pyproject.toml` for project, ruff, and mypy (strict) config; run them in pre-commit and CI.
- Type-hint every public function, class, and API model.
- Validate requests and settings with Pydantic models.
- Keep business logic in `services/`, not in routes or views.
- Inject DB sessions, auth, and config (FastAPI `Depends`, `yield` dependencies).
- Define a base `AppError` with subclasses; register handlers that return a JSON error object.
- Close async resources with `async with` or `yield` dependencies.
- Never call blocking libs (`requests`, sync DB drivers) in `async def`; use `httpx`/`asyncpg` or `run_in_executor`.
- Profile before optimizing: `cProfile` for hot spots, `py-spy` for low-overhead sampling, `pytest-benchmark` for micro-benchmarks.
- Cache pure, repeated calls with `functools.lru_cache`.
- Avoid ORM N+1: `select_related` / `prefetch_related` (Django), eager loading (SQLAlchemy).
- Use vectorized NumPy/Pandas ops, not Python loops, on large data.
- Test with pytest + `pytest-asyncio`; add `hypothesis` for edge cases; core coverage > 90%.
- Containerize with a multi-stage Dockerfile.

## Decisions
| Building | Use | Avoid |
|---|---|---|
| API-first service, microservice, ML model serving | FastAPI (async, Pydantic) | Django for a thin API |
| Full-stack web, CMS, needs admin | Django | Hand-rolled admin on FastAPI |
| Small script or learning project | Flask or plain script | Heavy framework |
| Distributed background jobs | Celery + any framework | Threads in the web process |

Ask about admin needs, team async skill, and current infra before you pick.

| Workload | Do | Avoid |
|---|---|---|
| I/O-bound (HTTP, DB, files, websockets) | `async` + `asyncio.gather`; cap with `asyncio.Semaphore` | Sequential awaits in a loop |
| CPU-bound | `ProcessPoolExecutor` / `multiprocessing`, sync code | `async` for CPU loops |
| Only blocking libs exist | Sync code, or `run_in_executor` | Blocking call inside `async def` |
| Flask app | Sync, unless you add an async extension | Mixed sync/async without a plan |

## Load on demand
| Need | Read |
|---|---|
| uv commands, project layouts, `pyproject.toml`, pre-commit, toolbox, ship checklist | [references/project-setup.md](references/project-setup.md) |
| Idioms: PEP 8, Protocols, EAFP, context managers, generators, dataclasses, decorators, concurrency, `__slots__`, anti-patterns | [references/python-patterns.md](references/python-patterns.md) |
| pytest: TDD, fixtures, `conftest.py`, parametrize, markers, mocks/autospec, async tests with httpx, coverage | [references/python-testing.md](references/python-testing.md) |
| Windows installer: Nuitka, 32/64-bit, dist slimming, DLLs, VC++ runtime, Inno Setup | [references/windows-installer.md](references/windows-installer.md) |

## Related skills
- [`fastapi`](../backend-development/references/fastapi.md) — FastAPI endpoints, Pydantic v2, SQLAlchemy 2.0
- [`django`](../backend-development/references/django.md) — Django 5, DRF, Celery, Channels
- [`backend-development`](../backend-development/SKILL.md) — API design, services, resilience
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — cross-language unit test patterns
- [`machine-learning`](../machine-learning/SKILL.md) — ML pipelines, PyTorch, serving
