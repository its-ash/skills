@REF:csharp-testing
§USE{new_tests|review_quality|setup_infra|debug_flaky_slow}
§STK{test:xUnit(preferred)|assert:FluentAssertions|mock:NSubstitute⊕Moq|integ:Testcontainers+WebApplicationFactory|data:Bogus}
§PAT{
  unit_aaa:sealed_cls+fresh_sut_in_ctor(xUnit_1_inst/test)∧[Fact]async_Task_Method_Expected_WhenCondition(CancellationToken.None)∧FluentAssertions(.Should().BeTrue()|.BeFalse()|.NotBeNull()|.Be()|.Contain()|.BeNull()|.HaveCount(n));
  theory:[Theory][InlineData(...)]⊕[Theory][MemberData(nameof(Cases))]←public_static_TheoryData<T1,T2>;
  nsubstitute:setup=>_repo.FindByIdAsync(id,Arg.Any<CancellationToken>()).Returns((Order?)null)|verify=>await _repo.Received(1).AddAsync(Arg.Is<Order>(o=>...),Arg.Any<CancellationToken>());
  builder:sealed_fluent_cls(With*(...)=>this,Build()=>Domain.Create(...))
}
```csharp
public sealed class OrderServiceTests {
    private readonly IOrderRepository _repo = Substitute.For<IOrderRepository>();
    private readonly OrderService _sut;
    public OrderServiceTests() => _sut = new OrderService(_repo, Substitute.For<ILogger<OrderService>>());
    [Theory, MemberData(nameof(InvalidCases))]
    public async Task PlaceOrderAsync_RejectsInvalid(CreateOrderRequest req, string err) {
        var res = await _sut.PlaceOrderAsync(req, CancellationToken.None);
        res.IsSuccess.Should().BeFalse(); res.Error.Should().Contain(err);
    }
    public static TheoryData<CreateOrderRequest, string> InvalidCases => new() { { new() { CustomerId = "", Items = [] }, "CustomerId" } };
}
```
§INT{
  waf:IClassFixture<WebApplicationFactory<Program>>→factory.WithWebHostBuilder(b=>b.ConfigureServices(s=>{s.RemoveAll<DbContextOptions<AppDbContext>>();s.AddDbContext<AppDbContext>(o=>o.UseInMemoryDatabase("TestDb"));})).CreateClient();
  testcontainers:IAsyncLifetime→PostgreSqlContainer(new PostgreSqlBuilder().WithImage("postgres:16-alpine").Build());Init=>StartAsync()+UseNpgsql(_pg.GetConnectionString())+db.Database.MigrateAsync();Dispose=>db.DisposeAsync()+pg.DisposeAsync()
}
```csharp
var res = await _client.PostAsJsonAsync("/api/orders", req);
res.StatusCode.Should().Be(HttpStatusCode.Created);
res.Headers.Location.Should().NotBeNull();
```
§ORG{tests/{MyApp.UnitTests/{Services,Validators},MyApp.IntegrationTests/{Api,Repositories},MyApp.TestHelpers/{Builders,Fixtures}}}
§ANTI{
  test_impl_details⇒test_behavior_outcomes;
  shared_mutable_state⇒fresh_instance/test(xUnit_ctor);
  Thread.Sleep⇒Task.Delay+timeout∨polling_helpers;
  assert_ToString()⇒assert_typed_props;
  giant_multi_assert⇒1_logical_assert/test;
  impl_test_names⇒Method_ExpectedResult_WhenCondition;
  ignore_CancellationToken⇒pass∧verify_cancellation
}
§CMD{
  all:dotnet test;
  cov:dotnet test --collect:"XPlat Code Coverage";
  proj:dotnet test tests/MyApp.UnitTests/;
  filt:dotnet test --filter "FullyQualifiedName~OrderService";
  watch:dotnet watch test --project tests/MyApp.UnitTests/
}
