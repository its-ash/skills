@REF:fsharp-testing
§USE{new_tests|review_quality|setup_infra|debug_flaky_slow}
§STK{test:xUnit|assert:FsUnit.xUnit+Unquote(Swensen.Unquote,quotations_show_full_failed_expr)|prop:FsCheck.xUnit|mock:fn_stubs(preferred)⊕NSubstitute|integ:Testcontainers+WebApplicationFactory}
§PAT{
  unit:module *Tests + open Xunit + FsUnit.Xunit([<Fact>] let ``desc`` () = x |> should equal Y | should be (ofCase <@ UnionCase @>));
  unquote:open Swensen.Unquote → test <@ expr @> (prints full failing AST, ¬just expected/actual);
  async:[<Fact>] let ``desc`` () = task { let! r = ...; test <@ Result.isOk r @> };
  theory:[<Theory>][<InlineData(...)>];
  fscheck:open FsCheck+FsCheck.Xunit → [<Property>] (NonEmptyList<PositiveInt * decimal>, .Get, JSON roundtrip) | custom_gen:type Gen = static member M() = gen { let! x = Gen.elements [...] ... } |> Arb.fromGen + [<Property(Arbitrary=[|typeof<Gen>|])>];
  mock:fn_stubs=>{ createTestDeps () with SaveOrder = fun o -> task { ... } } | nsubstitute=>Substitute.For<I>(...) + .Returns(Task.FromResult(Some x)) + do! repo.Received(1).Method(id, Arg.Any<CancellationToken>())
}
```fsharp
[<Property(Arbitrary = [| typeof<OrderGenerators> |])>]
let ``valid emails pass`` (email: string) = EmailValidator.isValid email
type OrderGenerators =
    static member ValidEmail () = gen {
        let! u = Gen.elements [ "alice"; "bob" ]
        let! d = Gen.elements [ "example.com"; "test.org" ]
        return $"{u}@{d}" } |> Arb.fromGen
```
§INT{
  waf:type ApiTests(factory: WebApplicationFactory<Program>) = interface IClassFixture<WebApplicationFactory<Program>> → WithWebHostBuilder(fun b -> b.ConfigureServices(fun s -> s.RemoveAll<DbContextOptions<AppDbContext>>() |> ignore; s.AddDbContext<AppDbContext>(fun o -> o.UseInMemoryDatabase("TestDb") |> ignore) |> ignore)).CreateClient();
  async_member:[<Fact>] member _. ``GET 404`` () = task { let! r = client.GetAsync(...); test <@ r.StatusCode = HttpStatusCode.NotFound @> }
}
§ORG{tests/MyApp.Tests/{Unit,Integration,Properties,Helpers/{TestData.fs,TestDeps.fs}}}
§ANTI{
  test_impl_details⇒test_behavior_outcomes;
  mutable_shared_state⇒fresh_state/test;
  Thread.Sleep⇒Task.Delay+timeout∨polling_helpers;
  assert_sprintf⇒assert_typed_values∧pattern_matches;
  ignore_CancellationToken⇒pass∧verify_cancellation;
  skip_property_tests⇒FsCheck_∀fn_with_clear_invariants
}
§REL{[dotnet](../SKILL.md):DI_arch;[csharp-testing](csharp-testing.md):WAF+Testcontainers}
§CMD{
  all:dotnet test;
  cov:dotnet test --collect:"XPlat Code Coverage";
  proj:dotnet test tests/MyApp.Tests/;
  filt:dotnet test --filter "FullyQualifiedName~OrderService";
  watch:dotnet watch test --project tests/MyApp.Tests/
}
