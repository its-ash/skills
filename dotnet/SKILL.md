---
name: dotnet
description: "Provides patterns and checklists for modern C# development and ASP.NET Core backend services covering language features, EF Core, authentication, background jobs, performance, testing, and deployment. Use when writing C# .NET ASP.NET Core EF Core Entity Framework minimal API controller JWT authentication background service hosted service Hangfire MassTransit xUnit NUnit integration test Docker Kubernetes Azure performance memory leak dependency injection middleware Swagger OpenAPI migration LINQ async await cancellation token ILogger Serilog appsettings.json Program.cs csproj nuget dotnet CLI build publish deploy."
---

# .NET Development Skill
Write modern C# code and build ASP.NET Core backend services. Include records, pattern matching, async/await, EF Core data access, JWT authentication, background workers, performance tuning, and automated testing.

## When to Use
- You need to create or refactor a C# project targeting .NET 6+ or .NET 8+. 
- You are building RESTful, gRPC, or GraphQL APIs with ASP.NET Core. 
- You must implement data access with Entity Framework Core or Dapper. 
- You need authentication/authorization (JWT, Identity, Azure AD). 
- You require background processing, scheduled jobs, or real‑time communication. 
- You want to apply SOLID principles, modern language features, and comprehensive unit tests.

## Workflow
1. Clarify the project goal, target .NET version, and required libraries. 
2. Scaffold the solution with `dotnet new webapi` (or `minimalapi`). 
3. Add NuGet packages for EF Core, authentication, validation, logging, and testing. 
4. Define domain models using `record` types and enable nullable reference types (`<Nullable>enable</Nullable>`). 
5. Configure `DbContext` and migrations. 
6. Implement API endpoints (Minimal API or Controllers). 
7. Add authentication middleware and policy handlers. 
8. Create background services if needed. 
9. Write unit and integration tests. 
10. Run benchmarks, static analysis, and generate OpenAPI docs. 
11. Deploy configuration via `appsettings.json` and User Secrets.

## Rules & Best Practices
- **Enable nullable reference types** to catch null‑related bugs at compile time.
- **Prefer records** for immutable data transfer objects.
- **Apply SOLID**: single responsibility, dependency injection, interface segregation.
- **Use async/await** for all I/O; never block with `.Result` or `.Wait()`.
- **Scope DbContext** per request; use `AsNoTracking` for read‑only queries.
- **Validate inputs** with FluentValidation or data annotations before processing.
- **Centralize error handling** in middleware that returns consistent problem details.
- **Configure logging** with Serilog and include correlation IDs.
- **Secure secrets** with User Secrets (development) and environment variables (production).
- **Version APIs** using URL segments or header versioning.
- **Document endpoints** with Swagger/OpenAPI (`AddEndpointsApiExplorer`, `AddSwaggerGen`).
- **Write tests** with xUnit, Moq, and FluentAssertions; aim for high coverage of business logic.
- **Benchmark critical paths** with BenchmarkDotNet.
- **Cache responses** with response caching or output caching (ASP.NET Core 8+).
- **Use health checks** (`AddHealthChecks`) for observability.

## Code Patterns
### Minimal API with EF Core
```csharp
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<AppDbContext>(o =>
    o.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddAuthentication().AddJwtBearer();
builder.Services.AddAuthorization();

var app = builder.Build();

app.MapPost("/api/users", async (CreateUserRequest req, AppDbContext db) =>
{
    if (string.IsNullOrWhiteSpace(req.Email))
        return Results.BadRequest("Email required");

    var user = new User
    {
        Email = req.Email,
        PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password),
        Name = req.Name
    };
    db.Users.Add(user);
    await db.SaveChangesAsync();
    return Results.Created($"/api/users/{user.Id}", new UserResponse(user));
})
.WithName("CreateUser")
.WithOpenApi();

app.Run();

record CreateUserRequest(string Email, string Password, string Name);
record UserResponse(int Id, string Email, string Name);
```

### Controller‑Based API
```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly ILogger<UsersController> _log;

    public UsersController(AppDbContext db, ILogger<UsersController> log)
    {
        _db = db;
        _log = log;
    }

    [HttpGet]
    public async Task<ActionResult<List<UserDto>>> Get()
    {
        var users = await _db.Users
            .AsNoTracking()
            .Select(u => new UserDto(u.Id, u.Email, u.Name))
            .ToListAsync();
        return Ok(users);
    }

    [HttpPost]
    public async Task<ActionResult<UserDto>> Create(CreateUserDto dto)
    {
        var user = new User
        {
            Email = dto.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
            Name = dto.Name
        };
        _db.Users.Add(user);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Get), new { id = user.Id }, new UserDto(user));
    }
}
```

### JWT Token Service
```csharp
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

public class TokenService
{
    private readonly IConfiguration _cfg;
    public TokenService(IConfiguration cfg) => _cfg = cfg;

    public string GenerateToken(User user)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_cfg["Jwt:Key"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Name, user.Name)
        };
        var token = new JwtSecurityToken(
            issuer: _cfg["Jwt:Issuer"],
            audience: _cfg["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(1),
            signingCredentials: creds);
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
```

### Background Service
```csharp
public class EmailSenderService : BackgroundService
{
    private readonly ILogger<EmailSenderService> _log;
    private readonly IServiceProvider _services;

    public EmailSenderService(ILogger<EmailSenderService> log, IServiceProvider services)
    {
        _log = log;
        _services = services;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope = _services.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

            var pending = await db.PendingEmails
                .Where(e => !e.Sent)
                .Take(10)
                .ToListAsync(stoppingToken);

            foreach (var email in pending)
            {
                await SendEmailAsync(email);
                email.Sent = true;
            }

            await db.SaveChangesAsync(stoppingToken);
            await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
        }
    }

    private Task SendEmailAsync(PendingEmail email)
    {
        _log.LogInformation("Sending email to {Email}", email.To);
        // Insert real email logic here
        return Task.CompletedTask;
    }
}
```

## Testing Guidance
- Use **xUnit** for test projects (`dotnet new xunit`).
- Mock dependencies with **Moq** and assert with **FluentAssertions**.
- Write unit tests for services, token generation, and validation logic.
- Write integration tests with `WebApplicationFactory<T>` for API endpoints.
- Run tests via `dotnet test` and enforce coverage thresholds in CI.

## Performance & Optimization
- Apply **async/await** to all database and I/O calls.
- Use **AsNoTracking** for read‑only queries to avoid change‑tracking overhead.
- Enable **connection pooling** (default in ADO.NET) and configure max pool size if needed.
- Cache expensive results with **MemoryCache** or **ResponseCaching** middleware.
- Profile hot paths with **BenchmarkDotNet**.
- Use **Span<T>** and **Memory<T>** for high‑throughput data processing.

## Common Pitfalls
- Blocking async code with `.Result` or `.Wait()` – can cause deadlocks.
- Registering scoped services in a singleton background worker – resolve a scope inside the worker.
- Forgetting to call `await db.SaveChangesAsync()` after modifications.
- Exposing raw exception details; always map to a generic error response.
- Over‑using `Include` for deep eager loading – consider projection or separate queries.
- Not configuring JWT token validation parameters (issuer, audience, clock skew).

## Checklist
- [ ] Target .NET 8 (or latest LTS) in the project file.
- [ ] Enable nullable reference types.
- [ ] Add `record` types for DTOs.
- [ ] Register `DbContext` with appropriate provider.
- [ ] Create and apply EF Core migrations.
- [ ] Implement input validation (FluentValidation).
- [ ] Add authentication middleware and JWT settings.
- [ ] Configure global exception handling middleware.
- [ ] Register background services (`AddHostedService`).
- [ ] Set up Serilog (or preferred logger) with structured output.
- [ ] Add Swagger/OpenAPI generation.
- [ ] Write unit tests for each service and controller.
- [ ] Run BenchmarkDotNet on critical methods.
- [ ] Verify health checks endpoint.
- [ ] Review code with static analysis (`dotnet format`, Roslyn analyzers).

## Related skills

Load these when the task spans more than this skill.

- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`database-design`](../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`database-migration`](../database-migration/SKILL.md) — Provides step‑by‑step guidance for database schema and data migrations using Sequelize, TypeORM, and Prisma, c…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`docker`](../docker/SKILL.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
