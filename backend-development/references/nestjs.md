# NestJS

Provide concise, actionable advice for NestJS projects. Use this skill when you need to design or refactor module structure, resolve DI errors, set up middleware/guards/interceptors, write tests, integrate databases, configure authentication, manage environment variables, or improve performance.

## When to use
- New NestJS project or major feature addition.
- Dependency‑injection errors such as "cannot resolve dependencies" or circular dependencies.
- Missing or mis‑configured controllers, DTO validation, or response serialization.
- Database connection or entity issues with TypeORM or Mongoose.
- JWT/Passport authentication problems.
- Need to write unit, integration, or e2e tests.
- Performance bottlenecks, caching, or memory‑leak concerns.

---

## Module Architecture & Dependency Injection
- **Goal**: Keep modules small, focused, and loosely coupled.
- **Pattern**:
  ```typescript
  @Module({
    imports: [CommonModule, DatabaseModule],
    controllers: [FeatureController],
    providers: [FeatureService, FeatureRepository],
    exports: [FeatureService], // expose to other modules
  })
  export class FeatureModule {}
  ```
- **Common errors**:
  1. Provider not listed in `providers` → "cannot resolve dependencies".
  2. Provider needed in another module but not exported → add to `exports`.
  3. Circular dependency → use `forwardRef(() => OtherModule)` on both sides or extract shared logic to a third module.
- **Tools**: `nest generate module <name>`, `nest generate service <name>`.

## Controllers & Request Handling
- Use decorators (`@Controller`, `@Get`, `@Post`, etc.) correctly.
- Validate DTOs with **class‑validator** and **class‑transformer**.
- Add global validation pipe in `main.ts`:
  ```typescript
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }));
  ```
- Common fixes:
  - Route conflicts → ensure unique paths and HTTP methods.
  - Missing validation → add `@Body()` DTOs with `@IsString()`, etc.
  - Serialization issues → use `class-transformer` `@Exclude()` / `@Expose()`.

## Middleware, Guards, Interceptors & Pipes
- **Execution order**: Middleware → Guards → Interceptors (before) → Pipes → Handler → Interceptors (after).
- **Guard example** (JWT auth):
  ```typescript
  @Injectable()
  export class JwtAuthGuard extends AuthGuard('jwt') {}
  ```
- **Interceptor for logging**:
  ```typescript
  @Injectable()
  export class LoggingInterceptor implements NestInterceptor {
    intercept(context: ExecutionContext, next: CallHandler) {
      const req = context.switchToHttp().getRequest();
      console.log(`Incoming ${req.method} ${req.url}`);
      return next.handle();
    }
  }
  ```
- Common pitfalls:
  - Forget `await` in async guards/interceptors → request hangs.
  - Incorrect `@UseGuards` placement → guard not applied.

## Testing Strategies (Jest & Supertest)
- **Unit test module**:
  ```typescript
  beforeEach(async () => {
    const moduleRef = await Test.createTestingModule({
      providers: [MyService, { provide: DepService, useValue: mockDep }],
    }).compile();
    service = moduleRef.get(MyService);
  });
  ```
- **Mock TypeORM repository**:
  ```typescript
  { provide: getRepositoryToken(User), useValue: mockRepository }
  ```
- **Integration test** (e2e) with Supertest:
  ```typescript
  import * as request from 'supertest';
  const app = module.createNestApplication();
  await app.init();
  await request(app.getHttpServer())
    .post('/auth/login')
    .send({ username, password })
    .expect(201);
  ```
- Validation order before running tests: `npm run build` (typecheck) → `npm test` (unit) → `npm test:e2e` (e2e).

## Database Integration
### TypeORM
- Register entities:
  ```typescript
  TypeOrmModule.forFeature([User, Post])
  ```
- Common errors:
  - `@Column()` misuse → ensure correct decorator syntax.
  - Connection failure → verify `ormconfig.json` or `TypeOrmModule.forRoot` options (host, port, credentials).
  - Multiple DBs → use named connections:
    ```typescript
    TypeOrmModule.forRoot({ name: 'users', ... }),
    TypeOrmModule.forFeature([User], 'users')
    ```
- Enable retry logic:
  ```typescript
  retryAttempts: 3,
  retryDelay: 2000,
  ```
### Mongoose
- Register schemas:
  ```typescript
  MongooseModule.forFeature([{ name: Cat.name, schema: CatSchema }])
  ```
- Ensure schema decorators (`@Prop()`) are present.

## Authentication & Authorization (Passport JWT)
- Install packages:
  ```bash
  npm i @nestjs/passport @nestjs/jwt passport-jwt
  ```
- **Strategy setup**:
  ```typescript
  @Injectable()
  export class JwtStrategy extends PassportStrategy(Strategy) {
    constructor(private readonly config: ConfigService) {
      super({
        jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
        secretOrKey: config.get('JWT_SECRET'),
      });
    }
    validate(payload: any) {
      return { userId: payload.sub, username: payload.username };
    }
  }
  ```
- **Guard usage**:
  ```typescript
  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@Request() req) { return req.user; }
  ```
- Common fixes:
  - "Unknown authentication strategy 'jwt'" → import `Strategy` from `passport-jwt`.
  - `secretOrPrivateKey must have a value` → set `JWT_SECRET` in `.env` and load with `ConfigModule` before `JwtModule`.
  - 401 errors → verify `Authorization: Bearer <token>` header and token expiration.

## Configuration & Environment Management
- Load env variables with `@nestjs/config` and validate using **Joi**:
  ```typescript
  ConfigModule.forRoot({
    isGlobal: true,
    validationSchema: Joi.object({
      DB_HOST: Joi.string().required(),
      JWT_SECRET: Joi.string().required(),
    }),
  })
  ```
- Async configuration example (e.g., TypeORM):
  ```typescript
  TypeOrmModule.forRootAsync({
    imports: [ConfigModule],
    useFactory: (config: ConfigService) => ({
      type: 'postgres',
      host: config.get('DB_HOST'),
      // ...other options
    }),
    inject: [ConfigService],
  })
  ```

## Error Handling & Logging
- **Exception filter** for HTTP errors:
  ```typescript
  @Catch(HttpException)
  export class HttpExceptionFilter implements ExceptionFilter {
    catch(exception: HttpException, host: ArgumentsHost) {
      const ctx = host.switchToHttp();
      const response = ctx.getResponse<Response>();
      const status = exception.getStatus();
      response.status(status).json({
        statusCode: status,
        message: exception.message,
      });
    }
  }
  ```
- Register globally in `main.ts`:
  ```typescript
  app.useGlobalFilters(new HttpExceptionFilter());
  ```
- Use built‑in `Logger` or a custom logger (e.g., Winston) for structured logs.
- Ensure all promises are awaited or have `.catch()` to avoid unhandled rejections.

## Detection & Diagnostic Commands
```bash
# Verify Nest project
test -f nest-cli.json && echo "Nest CLI detected"
grep -q "@nestjs/core" package.json && echo "Nest core installed"
# Show Nest version
grep "@nestjs/core" package.json | sed -E 's/.*"([0-9\.]+)".*/Nest version: \1/'
# List modules (first 5)
find src -name "*.module.ts" | head -5 | xargs -n1 basename -s .module.ts
# Check DB integration
grep -q "@nestjs/typeorm" package.json && echo "TypeORM present"
grep -q "@nestjs/mongoose" package.json && echo "Mongoose present"
# Check auth packages
grep -q "@nestjs/passport" package.json && echo "Passport present"
grep -q "@nestjs/jwt" package.json && echo "JWT present"
```
- Run lint and build to catch circular dependencies:
  ```bash
  npm run lint
  npm run build -- --watch=false
  ```
- Validation order after changes:
  ```bash
  npm run build   # typecheck
  npm test        # unit tests
  npm run test:e2e   # e2e tests (optional)
  ```

## Common Patterns & Solutions
- **Custom decorator for role‑based auth**:
  ```typescript
  export const Roles = (...roles: string[]) => SetMetadata('roles', roles);
  export const Auth = (...roles: string[]) =>
    applyDecorators(UseGuards(JwtAuthGuard, RolesGuard), Roles(...roles));
  ```
- **Global module** (e.g., Config):
  ```typescript
  @Global()
  @Module({ providers: [ConfigService], exports: [ConfigService] })
  export class ConfigModule {}
  ```
- **Dynamic module** for optional features:
  ```typescript
  @Module({})
  export class FeatureModule {
    static forRoot(options: FeatureOptions): DynamicModule {
      return {
        module: FeatureModule,
        providers: [{ provide: 'FEATURE_OPTIONS', useValue: options }],
        exports: ['FEATURE_OPTIONS'],
      };
    }
  }
  ```

## Checklist for Review
- **Modules**
  - [ ] All services have `@Injectable()`.
  - [ ] Providers are listed in `providers` and exported when needed.
  - [ ] No circular dependencies (use `forwardRef` only if unavoidable).
  - [ ] Module names follow feature‑first convention.
- **Controllers**
  - [ ] Routes are unique and use proper HTTP verbs.
  - [ ] DTOs validated with `class-validator`.
  - [ ] Response objects are serialized (`class-transformer`).
- **DI & Tokens**
  - [ ] Custom tokens use `Symbol` or unique strings.
  - [ ] `@Inject()` matches provider token.
- **Database**
  - [ ] Entities/schemas have correct decorators.
  - [ ] Connection options are validated.
  - [ ] Multiple DBs use named connections.
- **Auth**
  - [ ] JWT strategy imports from `passport-jwt`.
  - [ ] `JwtModule` secret matches environment variable.
  - [ ] Guards applied to protected routes.
- **Testing**
  - [ ] Unit tests mock external providers.
  - [ ] Integration tests use an in‑memory or test DB.
  - [ ] E2E tests run with Supertest against a real server.
- **Performance**
  - [ ] Caching applied where appropriate (CacheInterceptor, Redis).
  - [ ] No N+1 queries (use DataLoader or query builder).
  - [ ] Memory leaks checked (`onModuleDestroy` cleans listeners).
- **Error Handling & Logging**
  - [ ] Global exception filter registered.
  - [ ] Logger outputs structured JSON in production.
  - [ ] Unhandled promise rejections are caught.

---

**Success criteria**: The application builds without type errors, all tests pass, no circular dependencies exist, authentication works with valid JWTs, database connections are stable, and performance metrics meet the project’s SLA.

## Related skills

Load these when the task spans more than this skill.

- [`backend-development`](../SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`typescript`](../../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`node`](../../node/SKILL.md) — Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js projec…
- [`database-design`](../../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
