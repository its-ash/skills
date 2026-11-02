# C# / .NET Code Patterns

Code examples for the rules in [`dotnet`](../SKILL.md).

## Immutability
```csharp
public sealed record Money(decimal Amount, string Currency);

public sealed class CreateOrderRequest
{
    public required string CustomerId { get; init; }
    public required IReadOnlyList<OrderItem> Items { get; init; }
}

// Bad: public setters, mutable List<T>
public class Order { public string CustomerId { get; set; } public List<OrderItem> Items { get; set; } }
```

## Explicit modifiers, nullability, DI
```csharp
public interface IOrderRepository
{
    Task<Order?> FindByIdAsync(Guid id, CancellationToken ct);
    Task<IReadOnlyList<Order>> FindByCustomerAsync(string customerId, CancellationToken ct);
    Task AddAsync(Order order, CancellationToken ct);
}

builder.Services.AddScoped<IOrderRepository, SqlOrderRepository>();

public sealed class UserService(IUserRepository repository, ILogger<UserService> logger)
{
    public Task<User?> FindByIdAsync(Guid id, CancellationToken ct) => repository.FindByIdAsync(id, ct);
}
```

## Async
```csharp
// Good: async all the way, token passed through
public async Task<OrderSummary> GetOrderSummaryAsync(Guid orderId, CancellationToken ct)
{
    var order = await _repository.FindByIdAsync(orderId, ct)
        ?? throw new NotFoundException($"Order {orderId} not found");
    var customer = await _customerService.GetAsync(order.CustomerId, ct);
    return new OrderSummary(order, customer);
}

// Bad: .Result blocks; deadlock risk
var order = _repository.FindByIdAsync(orderId, CancellationToken.None).Result;

// Independent calls: start all, then Task.WhenAll
var ordersTask = _orderService.GetRecentAsync(ct);
var metricsTask = _metricsService.GetCurrentAsync(ct);
var alertsTask = _alertService.GetActiveAsync(ct);
await Task.WhenAll(ordersTask, metricsTask, alertsTask);
return new DashboardData(Orders: await ordersTask, Metrics: await metricsTask, Alerts: await alertsTask);
```

## Options pattern
```csharp
public sealed class SmtpOptions
{
    public const string SectionName = "Smtp";
    public required string Host { get; init; }
    public required int Port { get; init; }
    public required string Username { get; init; }
    public bool UseSsl { get; init; } = true;
}

builder.Services.Configure<SmtpOptions>(builder.Configuration.GetSection(SmtpOptions.SectionName));

public class EmailService(IOptions<SmtpOptions> options)
{
    private readonly SmtpOptions _smtp = options.Value;
}
```

## Result pattern (expected failures)
```csharp
public sealed record Result<T>
{
    public bool IsSuccess { get; }
    public T? Value { get; }
    public string? Error { get; }
    private Result(T value) { IsSuccess = true; Value = value; }
    private Result(string error) { IsSuccess = false; Error = error; }
    public static Result<T> Success(T value) => new(value);
    public static Result<T> Failure(string error) => new(error);
}

public async Task<Result<Order>> PlaceOrderAsync(CreateOrderRequest request, CancellationToken ct)
{
    if (request.Items.Count == 0) return Result<Order>.Failure("Order must contain at least one item");
    var order = Order.Create(request);
    await _repository.AddAsync(order, ct);
    return Result<Order>.Success(order);
}
```

## EF Core repository
```csharp
public sealed class SqlOrderRepository(AppDbContext db) : IOrderRepository
{
    public Task<Order?> FindByIdAsync(Guid id, CancellationToken ct) =>
        db.Orders.Include(o => o.Items).AsNoTracking().FirstOrDefaultAsync(o => o.Id == id, ct);

    public async Task<IReadOnlyList<Order>> FindByCustomerAsync(string customerId, CancellationToken ct) =>
        await db.Orders.Where(o => o.CustomerId == customerId)
            .OrderByDescending(o => o.CreatedAt).AsNoTracking().ToListAsync(ct);

    public async Task AddAsync(Order order, CancellationToken ct)
    {
        db.Orders.Add(order);
        await db.SaveChangesAsync(ct);
    }
}
```

## Middleware
```csharp
public sealed class RequestTimingMiddleware(RequestDelegate next, ILogger<RequestTimingMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        var sw = Stopwatch.StartNew();
        try { await next(context); }
        finally
        {
            logger.LogInformation("Request {Method} {Path} completed in {ElapsedMs}ms with status {StatusCode}",
                context.Request.Method, context.Request.Path, sw.ElapsedMilliseconds, context.Response.StatusCode);
        }
    }
}
```

## Minimal API with route groups
```csharp
var orders = app.MapGroup("/api/orders").RequireAuthorization().WithTags("Orders");

orders.MapGet("/{id:guid}", async (Guid id, IOrderRepository repo, CancellationToken ct) =>
    await repo.FindByIdAsync(id, ct) is { } order ? TypedResults.Ok(order) : TypedResults.NotFound());

orders.MapPost("/", async (CreateOrderRequest request, IOrderService service, CancellationToken ct) =>
{
    var result = await service.PlaceOrderAsync(request, ct);
    return result.IsSuccess
        ? TypedResults.Created($"/api/orders/{result.Value!.Id}", result.Value)
        : TypedResults.BadRequest(result.Error);
});
```

## Guard clauses
```csharp
public async Task<ProcessResult> ProcessPaymentAsync(PaymentRequest request, CancellationToken ct)
{
    ArgumentNullException.ThrowIfNull(request);
    if (request.Amount <= 0)
        throw new ArgumentOutOfRangeException(nameof(request.Amount), "Amount must be positive");
    if (string.IsNullOrWhiteSpace(request.Currency))
        throw new ArgumentException("Currency is required", nameof(request.Currency));
    return await _gatewayFactory.Create(request.Currency).ChargeAsync(request, ct);
}
```
