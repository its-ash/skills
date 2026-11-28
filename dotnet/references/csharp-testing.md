@REF:csharp-testing
§USE{new_tests|review_quality|setup_infra|debug_flaky_slow}
§STK{
  test:xUnit_v3(xunit.v3,preferred)⊕TUnit(source_gen/AOT);
  runner:Microsoft.Testing.Platform(MTP,.NET_10+_native,¬legacy_VSTest_for_new);
  assert:Shouldly⊕AwesomeAssertions(FOSS_FluentAssertions_fork)∧¬FluentAssertions_8+(commercial_license);
  mock:NSubstitute(preferred)⊕Moq;
  time:FakeTimeProvider(Microsoft.Extensions.TimeProvider.Testing);
  integ:Testcontainers+WebApplicationFactory(¬EF_UseInMemoryDatabase);
  data:Bogus
}
§CFG{
  global_json:`{"test":{"runner":"Microsoft.Testing.Platform"}}`(@solution_root,routes `dotnet test`→MTP);
  csproj:`<OutputType>Exe</OutputType>`+`xunit.v3`+`Microsoft.Testing.Extensions.CodeCoverage`(¬`xunit.runner.visualstudio`∈pure_MTP);
  zero_tests_ci:`<TestingPlatformCommandLineArguments>$(TestingPlatformCommandLineArguments) --ignore-exit-code 8</TestingPlatformCommandLineArguments>`(MTP_exits_8_when_filter_matches_0)
}
§PAT{
  unit_aaa:sealed_cls+fresh_sut_in_ctor(xUnit_1_inst/test)∧[Fact]async_Task_Method_Expected_WhenCondition∧pass_`TestContext.Current.CancellationToken`(¬CancellationToken.None);
  assert_shouldly:`res.IsSuccess.ShouldBeFalse(); res.Error.ShouldContain(err);` | assert_awesome:`res.IsSuccess.Should().BeFalse(); res.Error.Should().Contain(err);`;
  theory:[Theory][InlineData(...)]⊕[Theory][MemberData(nameof(Cases))]←public_static_TheoryData<T1,T2>;
  nsubstitute:setup⇒`_repo.FindByIdAsync(id,Arg.Any<CancellationToken>()).Returns((Order?)null)`|verify⇒`await _repo.Received(1).AddAsync(Arg.Is<Order>(o=>...),Arg.Any<CancellationToken>())`;
  fake_time:`var time=new FakeTimeProvider(DateTimeOffset.Parse("2026-01-01T00:00:00Z")); time.Advance(TimeSpan.FromMinutes(5));`;
  async_lifetime:xUnit_v3_`IAsyncLifetime`⇒`public async ValueTask InitializeAsync()`∧`public async ValueTask DisposeAsync()`(ValueTask,¬Task);
  builder:sealed_fluent_cls(`With*(...)=>this`,`Build()=>Domain.Create(...)`)
}
```csharp
public sealed class OrderServiceTests {
    private readonly IOrderRepository _repo = Substitute.For<IOrderRepository>();
    private readonly FakeTimeProvider _time = new();
    private readonly OrderService _sut;
    public OrderServiceTests() => _sut = new OrderService(_repo, _time, Substitute.For<ILogger<OrderService>>());
    [Theory, MemberData(nameof(InvalidCases))]
    public async Task PlaceOrderAsync_RejectsInvalid(CreateOrderRequest req, string err) {
        var res = await _sut.PlaceOrderAsync(req, TestContext.Current.CancellationToken);
        res.IsSuccess.ShouldBeFalse();
        res.Error.ShouldNotBeNull();
        res.Error.ShouldContain(err);
    }
    public static TheoryData<CreateOrderRequest, string> InvalidCases => new() { { new() { CustomerId = "", Items = [] }, "CustomerId" } };
}
```
§INT{
  db_rule:prefer_Testcontainers(real_DB)⊕SQLite_in_mem(relational_parity)∧¬EF_UseInMemoryDatabase(no_FK/tx/SQL_parity);
  testcontainers:xUnit_v3_`IAsyncLifetime`(ValueTask)→`new PostgreSqlBuilder("postgres:18-alpine").Build()`(explicit_image_ctor,¬obsolete_parameterless_ctor);Init⇒`StartAsync()`+`UseNpgsql(_pg.GetConnectionString())`+`MigrateAsync()`;Dispose⇒`DisposeAsync()`;
  waf:`IClassFixture<ApiFactory>`(`WebApplicationFactory<Program>`+`IAsyncLifetime`)→`ConfigureTestServices(s=>{s.RemoveAll<DbContextOptions<AppDbContext>>();s.AddDbContext<AppDbContext>(o=>o.UseNpgsql(_pg.GetConnectionString()));})`→`CreateClient()`
}
```csharp
var res = await _client.PostAsJsonAsync("/api/orders", req, TestContext.Current.CancellationToken);
res.StatusCode.ShouldBe(HttpStatusCode.Created);
res.Headers.Location.ShouldNotBeNull();
```
§ORG{tests/{MyApp.UnitTests/{Services,Validators},MyApp.IntegrationTests/{Api,Repositories},MyApp.TestHelpers/{Builders,Fixtures}}}
§ANTI{
  FluentAssertions_8+⇒Shouldly⊕AwesomeAssertions(FOSS);
  EF_UseInMemoryDatabase⇒Testcontainers(real_DB)⊕SQLite_in_mem;
  CancellationToken.None∈xUnit_v3⇒TestContext.Current.CancellationToken;
  parameterless_PostgreSqlBuilder()⇒`new PostgreSqlBuilder("postgres:18-alpine")`;
  test_impl_details⇒test_behavior_outcomes;
  shared_mutable_state⇒fresh_instance/test(xUnit_ctor);
  Thread.Sleep⇒FakeTimeProvider∨Task.Delay+timeout∨polling_helpers;
  assert_ToString()⇒assert_typed_props;
  giant_multi_assert⇒1_logical_assert/test;
  impl_test_names⇒Method_ExpectedResult_WhenCondition
}
§CMD{
  new_proj:dotnet new install xunit.v3.templates && dotnet new xunit3 -n MyApp.UnitTests;
  all:dotnet test;
  proj_mtp:dotnet test --project tests/MyApp.UnitTests/MyApp.UnitTests.csproj;
  cov_mtp:dotnet test -- --coverage;
  filt_mtp:dotnet test -- --filter "FullyQualifiedName~OrderService";
  trx_mtp:dotnet test -- --report-trx;
  watch:dotnet watch test --project tests/MyApp.UnitTests/;
  vstest_legacy:dotnet test --collect:"XPlat Code Coverage" --filter "FullyQualifiedName~OrderService"
}
