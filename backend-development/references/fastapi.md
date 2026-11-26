@REF:fastapi
§USE{CRUD|custom_action∈FastAPI∧(async_SQLAlchemy2|Pydantic_v2|DI_auth(JWT|API_key)|pagination(cursor|offset)|cache|rate_limit|pytest-asyncio)}
§WF{
  1_explore:{entry∈{main.py,app.py,app/__init__.py},router∈{router.py,routers/},ORM:(app/database.py,Base,async_engine),auth:OAuth2PasswordBearer,tests:(tests/,httpx.AsyncClient)};
  2_interview(short_rounds):{resource:(new|existing|nested),methods:(CRUD|read_only|custom),fields:(<6|6-15+rel|nested/poly),auth:(JWT_bearer|API_key|public|existing),RBAC:(none|role|ownership),pagination:(cursor[rec]|offset_limit|none),cache:(none|Cache-Control|Redis)};
  3_plan:{files:(app/schemas/resource.py,app/models/resource.py,app/crud/resource.py,app/routers/resource.py),schemas:(Create,Update,Response,ListResponse),ORM,async_CRUD,router+deps,tests:(happy,validation,auth_fail,404)};
  4_impl_order:schemas→ORM→CRUD/service→router→auth_DI→pagination→tests
}
§PAT{
  layout:my_app/{app/{main.py,config.py,dependencies.py,database.py,routers/,models/,schemas/,services/},tests/conftest.py,pyproject.toml};
  lifespan_cors:```python
@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    await engine.dispose()
def create_app() -> FastAPI:
    app = FastAPI(title=settings.app_name, version=settings.app_version, lifespan=lifespan)
    app.add_middleware(CORSMiddleware, allow_origins=settings.allowed_origins, allow_credentials=True,
        allow_methods=["GET","POST","PATCH","DELETE","OPTIONS"], allow_headers=["Authorization","Content-Type"])
    app.include_router(users.router, prefix="/users", tags=["users"])
    return app
```
  settings:```python
class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")
    app_name: str = "My App"; app_version: str = "0.1.0"; database_url: str; secret_key: str
    algorithm: str = "HS256"; access_token_expire_minutes: int = 30; allowed_origins: list[str] = ["http://localhost:3000"]
```
  schemas:```python
class ResourceBase(BaseModel): name: str
class ResourceCreate(ResourceBase): pass
class ResourceUpdate(BaseModel): name: str | None = None
class ResourceResponse(ResourceBase):
    model_config = ConfigDict(from_attributes=True)
    id: UUID; created_at: datetime; updated_at: datetime
class ResourceListResponse(BaseModel): data: list[ResourceResponse]; next_cursor: str | None = None; has_more: bool
class UserCreate(BaseModel):
    email: EmailStr; username: str = Field(min_length=3, max_length=50); password: str = Field(min_length=8); password_confirm: str
    @model_validator(mode="after")
    def passwords_match(self) -> "UserCreate":
        if self.password != self.password_confirm: raise ValueError("Passwords do not match")
        return self
```
  orm_model:```python
class Resource(Base):
    __tablename__ = "resources"
    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
```
  crud_cursor_service:```python
encode_cursor = lambda dt: base64.urlsafe_b64encode(dt.isoformat().encode()).decode()
decode_cursor = lambda c: datetime.fromisoformat(base64.urlsafe_b64decode(c).decode())
async def list_resources(db: AsyncSession, cursor: str | None = None, limit: int = 20) -> tuple[list[Resource], str | None]:
    q = select(Resource).order_by(Resource.created_at.desc()).limit(limit + 1)
    if cursor: q = q.where(Resource.created_at < decode_cursor(cursor))
    items = list((await db.execute(q)).scalars().all())
    return items[:limit], (encode_cursor(items[-1].created_at) if len(items) > limit else None)
class DuplicateUserError(Exception): pass
class UserService:
    def __init__(self, db: AsyncSession) -> None: self.db = db
    async def create(self, payload: UserCreate) -> User:
        self.db.add(user := User(email=payload.email, username=payload.username, hashed_password=hash_password(payload.password)))
        try: await self.db.commit()
        except IntegrityError as exc: await self.db.rollback(); raise DuplicateUserError from exc
        await self.db.refresh(user); return user
    async def list(self, skip: int, limit: int) -> tuple[list[User], int]:
        total = (await self.db.execute(select(func.count(User.id)))).scalar_one()
        rows = await self.db.execute(select(User).order_by(User.id).offset(skip).limit(limit))
        return list(rows.scalars()), total
```
  crud_ops:{get:`select(Resource).where(Resource.id==id)`→`scalar_one_or_none()`;create:`add`→`commit`→`refresh`;update:`data.model_dump(exclude_unset=True)`→`setattr`→`commit`→`refresh`;delete:`db.delete(obj)`→`commit`};
  router:`APIRouter(prefix="/resources", tags=["resources"])`:{GET `""`(cursor:`str|None=Query(None)`, limit:`int=Query(20,ge=1,le=100)`, `DbDep`, `get_current_user`)→`ResourceListResponse(data,next_cursor,has_more=bool(next_cursor))`; GET `"/{resource_id}"`→200|`HTTPException(404,"Resource not found")`; POST `""`→201(`DuplicateUserError`→409); PATCH `"/{resource_id}"`→200|404; DELETE `"/{resource_id}"`→`HTTP_204_NO_CONTENT`|404};
  deps_auth:```python
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/users/token") # or "/auth/token"
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as s:
        try: yield s
        except Exception: await s.rollback(); raise
async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)], db: Annotated[AsyncSession, Depends(get_db)]) -> User:
    unauth = HTTPException(status.HTTP_401_UNAUTHORIZED, "Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    try: uid = int(jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])["sub"])
    except (jwt.PyJWTError, KeyError, TypeError, ValueError): raise unauth
    if (user := await db.get(User, uid)) is None: raise unauth
    return user
async def get_active_user(u: Annotated[User, Depends(get_current_user)]) -> User:
    if not u.is_active: raise HTTPException(status.HTTP_403_FORBIDDEN, "Inactive user")
    return u
def require_role(*roles: str):
    async def checker(u: Annotated[User, Depends(get_current_user)]):
        if u.role not in roles: raise HTTPException(status.HTTP_403_FORBIDDEN, "Insufficient permissions")
        return u
    return checker
DbDep = Annotated[AsyncSession, Depends(get_db)]
ActiveUserDep = Annotated[User, Depends(get_active_user)]
```
  tests_conftest:```python
engine = create_async_engine("sqlite+aiosqlite:///:memory:")
TestingSession = async_sessionmaker(engine, expire_on_commit=False)
@pytest_asyncio.fixture(autouse=True)
async def setup_db():
    async with engine.begin() as c: await c.run_sync(Base.metadata.create_all)
    yield
    async with engine.begin() as c: await c.run_sync(Base.metadata.drop_all)
@pytest_asyncio.fixture
async def client():
    app = create_app()
    async def override_get_db():
        async with TestingSession() as s: yield s
    app.dependency_overrides[get_db] = override_get_db
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac: yield ac
```
  test_cases:{`auth_client`:POST `/users/`→POST `/users/token`→`headers["Authorization"]=f"Bearer {token}"`; `@pytest.mark.asyncio`:POST→201; GET `00000000-0000-0000-0000-000000000000`→404; GET `?limit=2`→`has_more`&`next_cursor`; PATCH→200; DELETE→204→GET 404}
}
§R{
  async_first:∀route⇒`async def`∧`await` DB;
  migrations:Alembic(prod)∧`Base.metadata.create_all`∈{demos,tests};
  ORM_mode:`ConfigDict(from_attributes=True)`∀response_schema;
  DI:`Depends`+`Annotated` small/reusable;split authn(401)≠authz(403);
  errors:`HTTPException`∈{404,409,403,422};Pydantic handles validation;
  uniqueness:unique_index+catch `IntegrityError`→rollback→409(¬pre-check SELECT);
  pagination:prefer cursor(base64 timestamps⇒hide internal IDs);offset requires `order_by`;
  caching:server=Redis GET/SET+TTL|client=`Cache-Control`;
  logging:structured(`loguru`|`structlog`)∈CRUD(request_id,exec_time);
  OpenAPI:declare `response_model`,`summary`,`description`;
  testing:`httpx.AsyncClient(ASGITransport(app=app))`+DB_override+auth_fixtures
}
§ANTI{
  business_logic_in_routes(hashing,commits)⇒move_to_service;
  sync_Session_in_async_route⇒blocks_event_loop;
  missing_response_model⇒leaks_private_fields∧breaks_OpenAPI;
  offset_without_order_by⇒skipped/repeated_rows;
  pre_insert_exists_check⇒concurrency_race
}
§CHK{
  routes_async∧AsyncSession;
  response_models:`ConfigDict(from_attributes=True)`;
  auth_dep∀non-public_route;
  cursor_pagination:`next_cursor`≠None⇔has_more;
  rate_limit/circuit_breaker(if_external_APIs);
  tests:(happy,validation,auth_fail,404);
  `app.include_router(resource_router.router)`;
  Dockerfile:multi-stage+`uvicorn app.main:app --host 0.0.0.0 --port 80`;
  `/health`→200;
  Prometheus_exporter(if_observability_req)
}
§REL{
  [backend-development](../SKILL.md);
  [database-design](../../database-design/SKILL.md);
  [unit-testing-patterns](../../unit-testing-patterns/SKILL.md);
  [secure-coding](../../secure-coding/SKILL.md)
}
