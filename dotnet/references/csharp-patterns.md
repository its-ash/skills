@REF:csharp-patterns
§R{
  ref:[dotnet](../SKILL.md);
  immutability:sealed_record∧required_init_props∧IReadOnlyList<T>(¬public_set,¬List<T>);
  lang:C#14(field_kw,extension_members,null_cond_assign)∧C#15(.NET_11:union_types,closed_hierarchies,extension_indexers);
  async:async+CancellationToken_ct∧¬.Result/.Wait()∧parallel⇒Task.WhenAll;
  sync_time:System.Threading.Lock(¬lock(object))∧TimeProvider(¬DateTime.Now/UtcNow);
  options:AddOptions<T>().BindConfiguration(T.SectionName).ValidateDataAnnotations().ValidateOnStart();
  errors:expected⇒Result<T>;HTTP_unhandled⇒IExceptionHandler+AddProblemDetails()(RFC9457);
  caching:HybridCache(L1+L2,stampede_protection,¬manual_IMemoryCache+IDistributedCache);
  ef_core:AsNoTracking()+Select_proj∧EF10(LeftJoin,RightJoin,named_filters,JSON_cols)∧EF11(join_pruning,SqlVector,MaxBy/MinBy,FullJoin,net-ef.json);
  openapi_val:Microsoft.AspNetCore.OpenApi+Scalar.AspNetCore(¬Swashbuckle)∧AddValidation()(.NET_10+,async_.NET_11);
  log_perf:[LoggerMessage]_source_gen⊕msg_templates∧Stopwatch.GetTimestamp()+GetElapsedTime()(0_alloc)
}
§PAT{
  immutability:`sealed record Money(decimal Amount,string Currency);`|`sealed class CreateOrderRequest{[Required] public required string CustomerId{init;} [MinLength(1)] public required IReadOnlyList<OrderItem> Items{init;}}`;
  csharp14_15:`public string Name{get;set=>field=string.IsNullOrWhiteSpace(value)?throw new ArgumentException("Required",nameof(value)):value.Trim();}`|`customer?.LastOrder=order;`(.NET_10/C#14)|native `union`+exhaustive `switch`(.NET_11/C#15);
  di_time:`builder.Services.AddSingleton(TimeProvider.System);builder.Services.AddScoped<IOrderRepository,SqlOrderRepository>();`|primary ctor `sealed class OrderService(IOrderRepository repo,TimeProvider time,ILogger<OrderService> log)`→`time.GetUtcNow()`;
  async:`await repo.FindByIdAsync(id,ct)??throw new NotFoundException($"Order {id} not found")`|`var(o,m,a)=(oSvc.GetRecentAsync(ct),mSvc.GetCurrentAsync(ct),aSvc.GetActiveAsync(ct)); await Task.WhenAll(o,m,a);`;
  lock:`private readonly Lock _gate=new(); using(_gate.EnterScope()){...}`(or `lock(_gate)` lowered to EnterScope);
  options:`sealed class SmtpOptions{public const string SectionName="Smtp"; [Required] public required string Host{init;} [Range(1,65535)] public required int Port{init;} public bool UseSsl{init;}=true;}`|`builder.Services.AddOptions<SmtpOptions>().BindConfiguration(SmtpOptions.SectionName).ValidateDataAnnotations().ValidateOnStart();`|inject `IOptions<SmtpOptions>`;
  result:`sealed record Result<T>(bool IsSuccess,T? Value,string? Error)`(private ctor)+`Success(T)`/`Failure(string)`(expected/validation failures⇒`Failure`,¬throw);
  exception_handler:`sealed class GlobalExceptionHandler(ILogger<GlobalExceptionHandler> log):IExceptionHandler{public async ValueTask<bool> TryHandleAsync(HttpContext ctx,Exception ex,CancellationToken ct){...await ctx.Response.WriteAsJsonAsync(new ProblemDetails{Status=500,Title="Server Error"},ct);return true;}}`|reg:`builder.Services.AddExceptionHandler<GlobalExceptionHandler>().AddProblemDetails();`+`app.UseExceptionHandler();`;
  hybrid_cache:`builder.Services.AddHybridCache();`|`await cache.GetOrCreateAsync($"order:{id}",async cancel=>await repo.FindByIdAsync(id,cancel),cancellationToken:ct);`;
  ef_repo:`SqlOrderRepository(AppDbContext db)`:`db.Orders.AsNoTracking().Include(o=>o.Items).FirstOrDefaultAsync(o=>o.Id==id,ct)`|`db.Orders.AsNoTracking().Where(o=>o.CustomerId==cid).OrderByDescending(o=>o.CreatedAt).Select(o=>new OrderDto(o.Id,o.Total)).ToListAsync(ct)`|`db.Orders.Add(o);await db.SaveChangesAsync(ct);`|bulk:`await db.Orders.Where(...).ExecuteUpdateAsync(...,ct)`;
  ef_10_11:EF10:`LeftJoin`/`RightJoin`+named_query_filters(`HasQueryFilter("Tenant",...)`+`IgnoreQueryFilters(["Tenant"])`)+complex_type_JSON_cols+JSON_indexes|EF11:auto_join_pruning+`SqlVector<float>`(excluded_by_default_from_regular_queries)+`MaxBy`/`MinBy`/`FullJoin`+`net-ef.json`;
  middleware:`sealed class RequestTimingMiddleware(RequestDelegate next,ILogger<RequestTimingMiddleware> log)`→`InvokeAsync(HttpContext ctx)`:`long ts=Stopwatch.GetTimestamp();try{await next(ctx);}finally{LogReq(log,ctx.Request.Method,ctx.Request.Path,Stopwatch.GetElapsedTime(ts).TotalMilliseconds,ctx.Response.StatusCode);}`;
  logger_gen:`[LoggerMessage(Level=LogLevel.Information,Message="{Method} {Path} {ElapsedMs:F1}ms {StatusCode}")] static partial void LogReq(ILogger log,string method,string path,double elapsedMs,int statusCode);`;
  minimal_api:`builder.Services.AddValidation();builder.Services.AddOpenApi();`|`if(app.Environment.IsDevelopment()){app.MapOpenApi();app.MapScalarApiReference();}`|`var g=app.MapGroup("/api/orders").RequireAuthorization().WithTags("Orders");`|`g.MapGet("/{id:guid}",...=>o is not null?TypedResults.Ok(o):TypedResults.NotFound())`|`g.MapPost("/",...=>r.IsSuccess?TypedResults.Created($"/api/orders/{r.Value!.Id}",r.Value):TypedResults.BadRequest(r.Error))`;
  guards:`ArgumentNullException.ThrowIfNull(req)`|`ArgumentOutOfRangeException.ThrowIfNegativeOrZero(req.Amount)`|`ArgumentException.ThrowIfNullOrWhiteSpace(req.Currency)`
}
§CFG{
  proj:`<Nullable>enable</Nullable><ImplicitUsings>enable</ImplicitUsings><TreatWarningsAsErrors>true</TreatWarningsAsErrors>`+`Directory.Packages.props`(`ManagePackageVersionsCentrally=true`);
  file_app:`.NET_10+: app.cs` w/ `#:sdk Microsoft.NET.Sdk.Web` ∧ `#:package Scalar.AspNetCore@*` (single-file scripts/nano-services,¬.csproj)
}
§ANTI{
  Stopwatch.StartNew()⇒Stopwatch.GetTimestamp()+Stopwatch.GetElapsedTime()(0_alloc);
  DateTime.Now/UtcNow⇒inject_TimeProvider;
  lock(new object())⇒System.Threading.Lock;
  Configure<T>_unvalidated⇒AddOptions<T>().BindConfiguration(...).ValidateDataAnnotations().ValidateOnStart();
  Swashbuckle/Newtonsoft.Json_new⇒Microsoft.AspNetCore.OpenApi+Scalar.AspNetCore+System.Text.Json;
  LogInformation($"...")⇒[LoggerMessage]⊕structured_template
}
§CMD{
  slnx_mig:dotnet sln migrate;
  file_run:dotnet run app.cs;
  ef_script:dotnet ef migrations script --idempotent
}
