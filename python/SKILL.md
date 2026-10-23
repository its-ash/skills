---
name: python
description: "Guidance for modern Python 3.12+ development covering project layout, async versus sync decisions, framework selection, uv/ruff/mypy tooling, testing, profiling, and deployment. Use when writing .py code, scaffolding pyproject.toml, choosing FastAPI/Django/Flask, debugging asyncio or asyncio.gather, configuring uv/ruff/mypy/pytest, optimizing performance, or deploying Python services."
---

# Python Development (Modern 3.12+)

Provide clear, production‑ready guidance for Python projects that use version 3.12 or newer. The skill covers framework choice, async vs sync decisions, project structure, tooling, testing, performance, and deployment.

---

## When to Use
- You are writing or reviewing a Python 3.12+ codebase.
- You need to design an API, microservice, or background‑task system.
- You want to apply async patterns for I/O‑bound workloads.
- You require a reproducible development workflow with modern tools.
- You need performance profiling, testing, and CI/CD integration.

---

## Development Workflow
1. **Confirm environment**
   - Python 3.12+ installed.
   - Use `uv` to create a virtual environment and lock dependencies.
   ```bash
   uv venv .venv
   source .venv/bin/activate
   uv pip install -r requirements.txt
   uv lock
   ```
2. **Select framework** (see Decision Tree below).
3. **Decide async vs sync** based on workload characteristics.
4. **Create project layout** (small, medium, or large) and add a `pyproject.toml`.
5. **Configure tooling**
   - `ruff` for linting/formatting.
   - `mypy` or `pyright` for static type checking.
   - `pre‑commit` to run checks automatically.
6. **Write code**
   - Add type hints to all public functions, classes, and API models.
   - Use Pydantic models for request validation and configuration.
   - Keep business logic in service modules, not in routes or views.
   - Apply dependency injection for DB sessions, auth, and config.
7. **Add error handling**
   - Define a base `AppError` and specific subclasses.
   - Register FastAPI exception handlers that return a JSON error object.
8. **Implement caching** where read‑only data is reused (`functools.lru_cache`).
9. **Profile and benchmark**
   - Use `cProfile` or `py‑spy` for CPU profiling.
   - Use `pytest‑benchmark` for micro‑benchmarks.
10. **Write tests**
    - Unit tests with `pytest`.
    - Async tests with `pytest‑asyncio`.
    - Integration tests with `httpx.AsyncClient`.
11. **Set up CI**
    - GitHub Actions runs `ruff`, `mypy`, and `pytest` on each push.
12. **Containerize**
    - Multi‑stage Dockerfile builds the app and copies only runtime files.
13. **Deploy**
    - Use Docker, Kubernetes, or serverless platforms as required.

---

## Decision Tree: Framework Selection (2025)
```
What are you building?
├─ API‑first / microservice → FastAPI (async, high performance)
├─ Full‑stack web / CMS → Django (batteries‑included)
├─ Simple script / learning project → Flask (minimal)
├─ AI/ML model serving → FastAPI (Pydantic, async)
└─ Distributed background workers → Celery + any framework
```
**Ask the user** about admin interface needs, team familiarity with async, and existing infrastructure before choosing.

---

## Async vs Sync Decision Rules
- **Use async** when the code spends most time waiting for I/O (HTTP calls, database queries, file reads, websockets).
- **Use sync** for CPU‑bound work, simple scripts, or when only blocking libraries are available.
- **Never mix** sync libraries inside an async function without running them in a thread pool (`run_in_executor`).
- **Prefer async** with FastAPI, aiohttp, or Sanic; prefer sync with Flask unless you add an async extension.

---

## Project Structure Templates
### Small project / script
```
main.py
utils.py
requirements.txt
```
### Medium API
```
app/
│ ├─ __init__.py
│ ├─ main.py          # FastAPI app creation
│ ├─ models/          # ORM models
│ ├─ schemas/         # Pydantic models
│ ├─ routes/          # API endpoints
│ └─ services/        # Business logic
tests/
pyproject.toml
```
### Large application
```
src/
│ └─ myapp/
│     ├─ core/
│     ├─ api/
│     ├─ services/
│     └─ models/
tests/
pyproject.toml
```
Choose the layout that matches project size.

---

## Tooling Configuration Snippets
### `pyproject.toml` (minimal)
```toml
[project]
name = "myapp"
version = "0.1.0"
requires-python = ">=3.12"

[tool.uv]
# uv specific settings can go here

[tool.ruff]
line-length = 88
select = ["E", "F", "W", "C90"]
ignore = []

[tool.mypy]
strict = true
```
### Pre‑commit hook
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
---

## Common Code Patterns
### FastAPI endpoint with async, Pydantic, and dependency injection
```python
from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession
from .database import get_async_session

class UserCreate(BaseModel):
    email: str = Field(..., regex=r"[^@]+@[^@]+\.[^@]+")
    password: str = Field(..., min_length=8)

app = FastAPI()

@app.post("/users", response_model=UserCreate)
async def create_user(
    payload: UserCreate,
    db: AsyncSession = Depends(get_async_session),
):
    # Business logic lives in a service module
    from .services.user import create_user_service
    try:
        user = await create_user_service(db, payload)
        return user
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))
```
### Async I/O pattern with `asyncio.gather`
```python
import asyncio
import httpx

async def fetch(url: str) -> str:
    async with httpx.AsyncClient() as client:
        resp = await client.get(url, timeout=10)
        resp.raise_for_status()
        return resp.text

async def main(urls: list[str]):
    tasks = [fetch(u) for u in urls]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    for r in results:
        if isinstance(r, Exception):
            print(f"Error: {r}")
        else:
            print(f"Fetched {len(r)} characters")

asyncio.run(main(["https://example.com", "https://httpbin.org/get"]))
```
### Caching with `functools.lru_cache`
```python
from functools import lru_cache

@lru_cache(maxsize=128)
def get_config(key: str) -> str:
    # Expensive read from file or remote store
    ...
```
### pytest‑asyncio test for FastAPI endpoint
```python
import pytest
from httpx import AsyncClient
from myapp.app.main import app

@pytest.mark.asyncio
async def test_create_user():
    async with AsyncClient(app=app, base_url="http://test") as client:
        payload = {"email": "test@example.com", "password": "secret123"}
        resp = await client.post("/users", json=payload)
        assert resp.status_code == 200
        data = resp.json()
        assert data["email"] == payload["email"]
```
---

## Performance & Optimization Rules
- Profile before optimizing. Use `cProfile` for CPU hot spots and `py‑spy` for low‑overhead sampling.
- For I/O‑bound code, increase concurrency with `asyncio.gather` or an async pool (`asyncio.Semaphore`).
- Use `functools.lru_cache` for pure functions that are called repeatedly with the same arguments.
- For CPU‑bound work, switch to `concurrent.futures.ProcessPoolExecutor` or `multiprocessing`.
- Keep data frames in NumPy/Pandas memory‑efficient forms; avoid Python loops over large datasets.
---

## Testing & Quality Assurance Rules
- Write unit tests for pure functions and services.
- Use `pytest‑asyncio` for async code.
- Include property‑based tests with `hypothesis` for edge cases.
- Measure coverage with `pytest‑cov`; aim for >90% on core modules.
- Run lint (`ruff`), type check (`mypy`), and tests in CI on every push.
---

## Common Pitfalls to Avoid
- Importing a blocking library (e.g., `requests`) inside an async function.
- Using async for CPU‑heavy loops; it adds overhead without benefit.
- Skipping type hints on public APIs; reduces readability and static analysis.
- Forgetting to close async resources (e.g., DB connections) – use `async with` or FastAPI dependencies with `yield`.
- Ignoring N+1 queries in ORM usage; use `select_related` / `prefetch_related`.
- Not pinning dependency versions; always generate a lock file with `uv lock`.
---

## Checklist Before Shipping
- [ ] Python version is 3.12 or newer.
- [ ] Framework selected matches the decision tree.
- [ ] Async vs sync decision documented.
- [ ] Project layout follows the appropriate template.
- [ ] `pyproject.toml` includes uv, ruff, and mypy configurations.
- [ ] All public functions have type hints.
- [ ] Pydantic models used for request validation and settings.
- [ ] Dependency injection set up for DB, auth, and config.
- [ ] Custom exception hierarchy defined and handlers registered.
- [ ] Tests cover unit, async integration, and critical paths.
- [ ] CI pipeline runs lint, type check, and tests.
- [ ] Dockerfile uses multi‑stage build and copies only needed files.
- [ ] Profiling plan (cProfile or py‑spy) is ready for performance review.
- [ ] Security review performed (no secret keys in code, proper error messages).

---

## References (selected)
- `uv` – fast Python package manager.
- `ruff` – linting and formatting tool.
- `httpx` – async HTTP client.
- `asyncpg` – async PostgreSQL driver.
- `SQLAlchemy 2.0` – async ORM support.
- `FastAPI` – modern async web framework.
- `pytest`, `pytest‑asyncio`, `hypothesis` – testing ecosystem.
- `cProfile`, `py‑spy`, `memory_profiler` – profiling tools.

## Related skills

Load these when the task spans more than this skill.

- [`fastapi`](../backend-development/references/fastapi.md) — FastAPI skill for building production‑ready async endpoints with FastAPI, Pydantic v2, SQLAlchemy 2.0, depende…
- [`django`](../backend-development/references/django.md) — Provides concise, production‑ready guidance for Django 5.x projects, covering async views, DRF, Celery, Channe…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`performance`](../web-quality-audit/references/performance.md) — Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary…
- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
