@REF:fsharp-testing
§USE{new_tests|review_quality|setup_infra|debug_flaky_slow}
§STK{
  test:xUnit_v3(xunit.v3,F#_template_native)⊕Expecto(F#_native,parallel_default);
  runner:Microsoft.Testing.Platform(MTP,.NET_10+_native);
  assert:Unquote(Swensen.Unquote,AST_expr_diff)∧FsUnit.xUnit⊕Expecto.Flip;
  prop:FsCheck_3(`FsCheck.Xunit.v3`⇔xUnit_v3;¬mix_legacy_`FsCheck.Xunit`);
  mock:fn_stubs(record_of_fns,preferred)⊕NSubstitute;
  integ:Testcontainers+WebApplicationFactory(¬EF_UseInMemoryDatabase)
}
§CFG{
  global_json:`{"test":{"runner":"Microsoft.Testing.Platform"}}`(@solution_root);
  fsharp10_warn:scoped `#nowarn FS0025`..`#warnon FS0025`(breaking:single_line,code_req,¬space_after_`#`,¬string_literals);
  xunit_v3_pkg:`xunit.v3`+`FsCheck.Xunit.v3`+`Microsoft.Testing.Extensions.CodeCoverage`(<OutputType>Exe</OutputType>)
}
§PAT{
  unit:module *Tests + open Xunit + FsUnit.Xunit([<Fact>] let ``desc`` () = x |> should equal Y | should be (ofCase <@ UnionCase @>));
  unquote:open Swensen.Unquote → `test <@ expr @>`(prints_full_stepwise_AST_reduction,¬just_expected/actual);
  async_fsharp10:[<Fact>] let ``desc`` () = task { let ct = TestContext.Current.CancellationToken; let! a = fetchA ct and! b = fetchB ct; test <@ Result.isOk a && Result.isOk b @> }(F#10_`and!`_concurrent_await_in_task);
  theory:[<Theory>][<InlineData(...)>];
  fscheck3:open FsCheck + open FsCheck.FSharp + open FsCheck.Xunit → `[<Property(MaxTest=1000)>]`;`ArbMap.defaults`(replaces_global_`Arb.Default`/`Arb.register`);immutable_Config;custom_gen:`ArbMap.defaults |> ArbMap.generate<int>`⊕`gen { ... } |> Arb.fromGen`+`[<Property(Arbitrary=[|typeof<Gen>|])>]`;
  mock:fn_stubs⇒`{ createTestDeps () with SaveOrder = fun o ct -> task { ... } }` | nsubstitute⇒`Substitute.For<I>()`+`.Returns(Task.FromResult(Some x))`+`do! repo.Received(1).Method(id, Arg.Any<CancellationToken>())`;
  expecto:`testList "Order" [ testTask "creates" { ...; test <@ ... @> } ]`(parallel_by_default,works_w/_Unquote)
}
```fsharp
open FsCheck
open FsCheck.FSharp
open FsCheck.Xunit

type OrderGenerators =
    static member ValidEmail () =
        gen {
            let! u = Gen.elements [ "alice"; "bob" ]
            let! d = Gen.elements [ "example.com"; "test.org" ]
            return $"{u}@{d}"
        } |> Arb.fromGen

[<Property(Arbitrary = [| typeof<OrderGenerators> |])>]
let ``valid emails pass`` (email: string) = EmailValidator.isValid email
```
§INT{
  db_rule:Testcontainers(real_DB)⊕SQLite_in_mem∧¬EF_UseInMemoryDatabase;
  waf_tc:type ApiFactory() = inherit WebApplicationFactory<Program>() + interface IAsyncLifetime (ValueTask:`_pg.StartAsync()`/`_pg.DisposeAsync()`, `new PostgreSqlBuilder("postgres:18-alpine").Build()`) → `ConfigureTestServices(fun s -> s.RemoveAll<DbContextOptions<AppDbContext>>() |> ignore; s.AddDbContext<AppDbContext>(fun o -> o.UseNpgsql(_pg.GetConnectionString()) |> ignore) |> ignore)`;
  async_member:[<Fact>] member _.``GET 404`` () = task { let! r = client.GetAsync("/api/orders/...", TestContext.Current.CancellationToken); test <@ r.StatusCode = HttpStatusCode.NotFound @> }
}
§ORG{tests/MyApp.Tests/{Unit,Integration,Properties,Helpers/{TestData.fs,TestDeps.fs}}}
§ANTI{
  mix_FsCheck.Xunit+FsCheck.Xunit.v3⇒use_`FsCheck.Xunit.v3`_only_on_xUnit_v3;
  FsCheck2_Arb.Default/Arb.register⇒FsCheck3_`ArbMap.defaults`+`open FsCheck.FSharp`;
  EF_UseInMemoryDatabase⇒Testcontainers(real_DB)⊕SQLite_in_mem;
  F#10_`# nowarn "0025"`⇒`#nowarn FS0025`(no_space,no_quotes);
  test_impl_details⇒test_behavior_outcomes;
  mutable_shared_state⇒fresh_state/test;
  Thread.Sleep⇒FakeTimeProvider∨Task.Delay+timeout;
  assert_sprintf⇒assert_typed_values∧pattern_matches;
  ignore_CancellationToken⇒pass_`TestContext.Current.CancellationToken`∧verify_cancellation;
  skip_property_tests⇒FsCheck_∀fn_with_clear_invariants
}
§REL{[dotnet](../SKILL.md):DI_arch;[csharp-testing](csharp-testing.md):MTP+WAF+Testcontainers}
§CMD{
  new_proj:dotnet new xunit3 -lang F# -n MyApp.Tests;
  all:dotnet test;
  proj_mtp:dotnet test --project tests/MyApp.Tests/MyApp.Tests.fsproj;
  cov_mtp:dotnet test -- --coverage;
  filt_mtp:dotnet test -- --filter "FullyQualifiedName~OrderService";
  watch:dotnet watch test --project tests/MyApp.Tests/;
  vstest_legacy:dotnet test --collect:"XPlat Code Coverage" --filter "FullyQualifiedName~OrderService"
}
