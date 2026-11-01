# FastAPI Endpoint Builder

Create high‑performance, async‑first API endpoints in an existing FastAPI project. Use Pydantic v2 for validation, SQLAlchemy 2.0 for async DB access, and dependency injection for authentication and other cross‑cutting concerns. The skill guides you through planning, design, implementation, and testing.

## When to use
- Adding a new CRUD or custom action to a FastAPI service.
- Need async database queries with SQLAlchemy 2.0.
- Require JWT, API‑key, or custom auth via FastAPI dependencies.
- Want cursor‑ or offset‑based pagination, response caching, or rate limiting.
- Must deliver full test coverage with pytest‑asyncio.

## Workflow
### 1. Explore the project
1. Locate the FastAPI entry point (`main.py`, `app.py`, or `app/__init__.py`).
2. Identify router organization (`router.py` vs `routers/` package).
3. Find ORM setup (`app/database.py`, `Base`, async engine).
4. Note existing auth dependencies (e.g., `OAuth2PasswordBearer`).
5. Review test framework (usually `tests/` with `httpx.AsyncClient`).

### 2. Interview the requirements
Ask the user in short rounds:
- **Resource** – new model, existing model, or nested relationship?
- **HTTP methods** – full CRUD, read‑only, or custom action?
- **Fields** – simple (<6), medium (6‑15 with relations), or complex (nested, polymorphic)?
- **Authentication** – JWT bearer, API key, public, or reuse existing dependency?
- **RBAC** – none, role‑based, or ownership check?
- **Pagination** – cursor (recommended), offset/limit, or none?
- **Caching** – none, `Cache‑Control` headers, or Redis cache?

### 3. Plan the implementation
Produce a concise plan that lists:
- Files to create/modify (e.g., `app/schemas/resource.py`, `app/models/resource.py`, `app/crud/resource.py`, `app/routers/resource.py`).
- Pydantic schemas: `Create`, `Update`, `Response`, `ListResponse`.
- SQLAlchemy model definition.
- Async CRUD functions.
- Router endpoints with dependencies.
- Tests to cover happy path, validation errors, auth failures, and not‑found cases.

### 4. Implement (order matters)
#### 4.1 Pydantic schemas (resource_schemas.py)
```python
from pydantic import BaseModel, ConfigDict
from datetime import datetime
from uuid import UUID

class ResourceBase(BaseModel):
    name: str
    # add other fields here

class ResourceCreate(ResourceBase):
    pass

class ResourceUpdate(BaseModel):
    name: str | None = None
    # other optional fields

class ResourceResponse(ResourceBase):
    model_config = ConfigDict(from_attributes=True)
    id: UUID
    created_at: datetime
    updated_at: datetime

class ResourceListResponse(BaseModel):
    data: list[ResourceResponse]
    next_cursor: str | None = None
    has_more: bool
```
#### 4.2 SQLAlchemy model (resource_model.py)
```python
from sqlalchemy import Column, String, DateTime, func
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
import uuid
from app.database import Base

class Resource(Base):
    __tablename__ = "resources"

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )
```
#### 4.3 CRUD / service layer (resource_crud.py)
```python
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from uuid import UUID
from app.models.resource import Resource
from app.schemas.resource import ResourceCreate, ResourceUpdate

async def get_resource(db: AsyncSession, resource_id: UUID) -> Resource | None:
    result = await db.execute(select(Resource).where(Resource.id == resource_id))
    return result.scalar_one_or_none()

async def list_resources(
    db: AsyncSession, cursor: str | None = None, limit: int = 20
) -> tuple[list[Resource], str | None]:
    query = select(Resource).order_by(Resource.created_at.desc()).limit(limit + 1)
    if cursor:
        query = query.where(Resource.created_at < decode_cursor(cursor))
    result = await db.execute(query)
    items = list(result.scalars().all())
    next_cursor = encode_cursor(items[-1].created_at) if len(items) > limit else None
    return items[:limit], next_cursor

async def create_resource(db: AsyncSession, data: ResourceCreate) -> Resource:
    obj = Resource(**data.model_dump())
    db.add(obj)
    await db.commit()
    await db.refresh(obj)
    return obj

async def update_resource(
    db: AsyncSession, resource_id: UUID, data: ResourceUpdate
) -> Resource | None:
    obj = await get_resource(db, resource_id)
    if not obj:
        return None
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, field, value)
    await db.commit()
    await db.refresh(obj)
    return obj

async def delete_resource(db: AsyncSession, resource_id: UUID) -> bool:
    obj = await get_resource(db, resource_id)
    if not obj:
        return False
    await db.delete(obj)
    await db.commit()
    return True
```
#### 4.4 Router with dependencies (resource_router.py)
```python
from fastapi import APIRouter, Depends, HTTPException, Query, status
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.resource import (
    ResourceCreate,
    ResourceUpdate,
    ResourceResponse,
    ResourceListResponse,
)
from app.crud.resource import (
    get_resource,
    list_resources,
    create_resource,
    update_resource,
    delete_resource,
)
from app.dependencies import get_db, get_current_user, require_role

router = APIRouter(prefix="/resources", tags=["resources"])

@router.get("", response_model=ResourceListResponse)
async def list_resources_endpoint(
    cursor: str | None = Query(None),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user),  # adjust type as needed
):
    items, next_cursor = await list_resources(db, cursor=cursor, limit=limit)
    return ResourceListResponse(data=items, next_cursor=next_cursor, has_more=bool(next_cursor))

@router.get("/{resource_id}", response_model=ResourceResponse)
async def get_resource_endpoint(
    resource_id: UUID,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user),
):
    obj = await get_resource(db, resource_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Resource not found")
    return obj

@router.post("", response_model=ResourceResponse, status_code=status.HTTP_201_CREATED)
async def create_resource_endpoint(
    payload: ResourceCreate,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user),
):
    return await create_resource(db, payload)

@router.patch("/{resource_id}", response_model=ResourceResponse)
async def update_resource_endpoint(
    resource_id: UUID,
    payload: ResourceUpdate,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user),
):
    obj = await update_resource(db, resource_id, payload)
    if not obj:
        raise HTTPException(status_code=404, detail="Resource not found")
    return obj

@router.delete("/{resource_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_resource_endpoint(
    resource_id: UUID,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user),
):
    ok = await delete_resource(db, resource_id)
    if not ok:
        raise HTTPException(status_code=404, detail="Resource not found")
```
#### 4.5 Auth dependency (auth.py)
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.models.user import User
from app.utils.jwt import decode_jwt

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/token")

async def get_current_user(
    token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)
) -> User:
    payload = decode_jwt(token)
    user = await db.get(User, payload["sub"])
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user

def require_role(*roles: str):
    async def checker(current_user: User = Depends(get_current_user)):
        if current_user.role not in roles:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        return current_user
    return checker
```
#### 4.6 Cursor pagination helpers (pagination.py)
```python
import base64
from datetime import datetime

def encode_cursor(dt: datetime) -> str:
    return base64.urlsafe_b64encode(dt.isoformat().encode()).decode()

def decode_cursor(cursor: str) -> datetime:
    return datetime.fromisoformat(base64.urlsafe_b64decode(cursor).decode())
```
#### 4.7 Tests (tests/test_resource.py)
```python
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.fixture
async def client():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac

@pytest.mark.asyncio
async def test_create_resource(client: AsyncClient, auth_headers: dict):
    resp = await client.post("/resources", json={"name": "Demo"}, headers=auth_headers)
    assert resp.status_code == 201
    data = resp.json()
    assert data["name"] == "Demo"
    assert "id" in data

@pytest.mark.asyncio
async def test_get_not_found(client: AsyncClient, auth_headers: dict):
    resp = await client.get("/resources/00000000-0000-0000-0000-000000000000", headers=auth_headers)
    assert resp.status_code == 404

@pytest.mark.asyncio
async def test_list_pagination(client: AsyncClient, auth_headers: dict):
    for i in range(5):
        await client.post("/resources", json={"name": f"R{i}"}, headers=auth_headers)
    resp = await client.get("/resources?limit=2", headers=auth_headers)
    assert resp.status_code == 200
    payload = resp.json()
    assert len(payload["data"]) == 2
    assert payload["has_more"] is True
    assert payload["next_cursor"] is not None

@pytest.mark.asyncio
async def test_update_partial(client: AsyncClient, auth_headers: dict):
    create = await client.post("/resources", json={"name": "Old"}, headers=auth_headers)
    rid = create.json()["id"]
    resp = await client.patch(f"/resources/{rid}", json={"name": "New"}, headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json()["name"] == "New"

@pytest.mark.asyncio
async def test_delete_resource(client: AsyncClient, auth_headers: dict):
    create = await client.post("/resources", json={"name": "Tmp"}, headers=auth_headers)
    rid = create.json()["id"]
    del_resp = await client.delete(f"/resources/{rid}", headers=auth_headers)
    assert del_resp.status_code == 204
    get_resp = await client.get(f"/resources/{rid}", headers=auth_headers)
    assert get_resp.status_code == 404
```

## Application Patterns

Use these patterns when you set up a new FastAPI app, or when you clean up the base of an existing one.

### Project layout

```text
my_app/
|-- app/
|   |-- main.py           # App factory, lifespan, middleware
|   |-- config.py         # Settings with pydantic-settings
|   |-- dependencies.py   # Shared dependencies (DB session, current user)
|   |-- database.py       # Async engine and session factory
|   |-- routers/
|   |-- models/           # SQLAlchemy ORM models
|   |-- schemas/          # Pydantic request and response models
|   `-- services/         # Business logic and transactions
|-- tests/
|   `-- conftest.py
`-- pyproject.toml
```

### App factory and lifespan

```python
# app/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import engine
from app.routers import users

@asynccontextmanager
async def lifespan(app: FastAPI):
    yield                      # Startup work goes before yield
    await engine.dispose()     # Close pooled connections on shutdown

def create_app() -> FastAPI:
    app = FastAPI(title=settings.app_name, version=settings.app_version, lifespan=lifespan)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.allowed_origins,
        allow_credentials=True,
        allow_methods=["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
        allow_headers=["Authorization", "Content-Type"],
    )
    app.include_router(users.router, prefix="/users", tags=["users"])
    return app

app = create_app()
```

Manage the schema with Alembic migrations. Use `Base.metadata.create_all` only in demos and tests.

### Settings

```python
# app/config.py
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_name: str = "My App"
    app_version: str = "0.1.0"
    database_url: str              # Required: startup fails if it is missing
    secret_key: str
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    allowed_origins: list[str] = ["http://localhost:3000"]

settings = Settings()
```

### Cross-field validation

```python
from pydantic import BaseModel, EmailStr, Field, model_validator

class UserCreate(BaseModel):
    email: EmailStr
    username: str = Field(min_length=3, max_length=50)
    password: str = Field(min_length=8)
    password_confirm: str

    @model_validator(mode="after")
    def passwords_match(self) -> "UserCreate":
        if self.password != self.password_confirm:
            raise ValueError("Passwords do not match")
        return self
```

### Annotated dependencies

```python
# app/dependencies.py
from typing import Annotated, AsyncGenerator
import jwt  # PyJWT
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from app.config import settings
from app.database import AsyncSessionLocal
from app.models.user import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/users/token")

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise

async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User:
    unauthorized = HTTPException(status.HTTP_401_UNAUTHORIZED, "Could not validate credentials",
                                 headers={"WWW-Authenticate": "Bearer"})
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        user_id = int(payload["sub"])
    except (jwt.PyJWTError, KeyError, TypeError, ValueError):
        raise unauthorized
    user = await db.get(User, user_id)
    if user is None:
        raise unauthorized
    return user

async def get_active_user(user: Annotated[User, Depends(get_current_user)]) -> User:
    if not user.is_active:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Inactive user")
    return user

DbDep = Annotated[AsyncSession, Depends(get_db)]
ActiveUserDep = Annotated[User, Depends(get_active_user)]
```

Keep authentication (401) and authorization (403) in different dependencies so that the status code is correct.

### Service with database constraints

```python
from sqlalchemy.exc import IntegrityError

class DuplicateUserError(Exception):
    pass

class UserService:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def create(self, payload: UserCreate) -> User:
        user = User(email=payload.email, username=payload.username,
                    hashed_password=hash_password(payload.password))
        self.db.add(user)
        try:
            await self.db.commit()       # The unique index stops duplicates, also under concurrency
        except IntegrityError as exc:
            await self.db.rollback()
            raise DuplicateUserError from exc
        await self.db.refresh(user)
        return user

    async def list(self, skip: int, limit: int) -> tuple[list[User], int]:
        total = (await self.db.execute(select(func.count(User.id)))).scalar_one()
        rows = await self.db.execute(select(User).order_by(User.id).offset(skip).limit(limit))
        return list(rows.scalars()), total
```

```python
@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(payload: UserCreate, db: DbDep):
    try:
        return await UserService(db).create(payload)
    except DuplicateUserError:
        raise HTTPException(status.HTTP_409_CONFLICT, "Email already registered")
```

Do not check "email exists" before the insert. Two requests can pass that check at the same time. Use a unique index and catch `IntegrityError`.

### Test fixtures with dependency overrides

```python
# tests/conftest.py
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine
from app.database import Base
from app.dependencies import get_db
from app.main import create_app

engine = create_async_engine("sqlite+aiosqlite:///:memory:")
TestingSession = async_sessionmaker(engine, expire_on_commit=False)

@pytest_asyncio.fixture(autouse=True)
async def setup_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest_asyncio.fixture
async def client():
    app = create_app()
    async def override_get_db():
        async with TestingSession() as session:
            yield session
    app.dependency_overrides[get_db] = override_get_db
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac

@pytest_asyncio.fixture
async def auth_client(client: AsyncClient) -> AsyncClient:
    await client.post("/users/", json={"email": "t@example.com", "username": "tester",
                                       "password": "securepass1", "password_confirm": "securepass1"})
    token = (await client.post("/users/token", data={"username": "t@example.com", "password": "securepass1"})).json()["access_token"]
    client.headers["Authorization"] = f"Bearer {token}"
    return client
```

### Anti-patterns

- Business logic (hashing, commits) in route handlers. Keep the route thin and put the logic in a service.
- A sync `Session` in an `async def` route. It blocks the event loop. Use `AsyncSession` and `await db.execute(...)`.
- No `response_model`. Always declare it so that private fields do not leak and the OpenAPI schema is correct.
- Offset pagination without `order_by`. Rows can be skipped or repeated between pages.

## Rules & Patterns
- **Async‑first**: Declare all route handlers with `async def`. Use `await` for DB calls.
- **ORM mode**: Set `model_config = ConfigDict(from_attributes=True)` on response schemas so Pydantic can read SQLAlchemy objects.
- **Dependency injection**: Use `Depends` for DB session, auth, pagination, and role checks. Keep dependencies small and reusable.
- **Error handling**: Raise `HTTPException` with appropriate status codes (404, 409, 403, 422). Let Pydantic handle validation errors.
- **Pagination**: Prefer cursor‑based pagination for real‑time data; encode timestamps with base64 to avoid leaking internal IDs.
- **Caching**: For server‑side caching, wrap service functions with a Redis `GET/SET` pattern and a TTL. For client‑side, add `Cache‑Control` headers.
- **Testing**: Use `httpx.AsyncClient` with `ASGITransport` for integration tests. Include fixtures for auth headers and a temporary test database.
- **Logging**: Add structured logs (e.g., `loguru` or `structlog`) inside CRUD functions to trace request IDs and execution time.
- **OpenAPI**: FastAPI auto‑generates docs. Add `summary` and `description` strings to route decorators for better UI.

## Checklist before shipping
- [ ] All route handlers are `async` and use the async DB session.
- [ ] Pydantic response models have `model_config = ConfigDict(from_attributes=True)`.
- [ ] Auth dependency applied to every non‑public endpoint.
- [ ] Cursor pagination works and returns `next_cursor` only when more data exists.
- [ ] Rate limiting or circuit breaker added if external APIs are called (optional).
- [ ] Tests cover happy path, validation errors, auth failures, and 404 cases.
- [ ] Router is included in the main FastAPI app (`app.include_router(resource_router.router)`).
- [ ] Dockerfile uses a multi‑stage build and runs `uvicorn app.main:app --host 0.0.0.0 --port 80` in production.
- [ ] Health‑check endpoint (`/health`) returns 200.
- [ ] Prometheus metrics exporter is configured if observability is required.

## Related skills

Load these when the task spans more than this skill.

- [`backend-development`](../SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`database-design`](../../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`unit-testing-patterns`](../../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`secure-coding`](../../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
