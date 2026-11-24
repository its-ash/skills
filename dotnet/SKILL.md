---
name: dotnet
description: "AUTO_INVOKE(silent)⇔prompt∈{.cs,.fs,.csproj,.sln,.slnx,C#,F#,.NET,ASP.NET_Core,EF_Core,dotnet_build,dotnet_test,xUnit,NSubstitute,Shouldly,AwesomeAssertions,Testcontainers,WebApplicationFactory,minimal_API,middleware,DI,CancellationToken,Result<T>,sealed_record,IOptions,AsNoTracking,TypedResults,WPF,WinForms,Win32,MFC,Qt,pywinauto,Windows_desktop,FsUnit,Unquote,FsCheck}|SUB:{csharp-testing,fsharp-testing,windows-desktop-e2e}"
---
@SKL:dotnet
§R{
  target:.NET_10_LTS(C#14);note:.NET_11(C#15,STS)_GA=2026-11-10∧EOL(.NET_8,.NET_9)=2026-11-10;
  proj:SDK_style∧Nullable=on∧ImplicitUsings=on∧TreatWarningsAsErrors∧CPM∧.slnx;
  json_openapi:System.Text.Json∧Microsoft.AspNetCore.OpenApi∧¬add_new(Newtonsoft.Json,Swashbuckle);
  types:value_obj⇒sealed_record;DTO⇒required+init;mutability⇒explicit_choice;
  collections(models,repos)⇒expose(IReadOnlyList<T>)∧¬List<T>;
  NRT=enabled∧nullable_ret⇒T?;
  classes⇒sealed_default∧explicit_access_modifiers;
  DI:depend_on(interfaces@svc_bounds)∧reg(AddScoped|AddSingleton|AddTransient)∧primary_ctor_DI;
  async_all_way∧∀async_call⇒accept+pass(CancellationToken);
  ¬block_async(.Result∨.Wait())(deadlock_risk);
  ret(Task)∧¬async_void(except:event_handlers);
  independent_async⇒Task.WhenAll;
  cfg:options_pattern(Configure<T>(GetSection(T.SectionName)),inject(IOptions<T>));
  expected_fail⇒Result<T>;throw⇔programmer_err∨invalid_arg;
  guard_early(ArgumentNullException.ThrowIfNull,ArgumentOutOfRangeException,ArgumentException)∧happy_path_unnested;
  EF_Core_read⇒AsNoTracking()∧Include(needed_navs_only);
  minimal_API:MapGroup(...).RequireAuthorization().WithTags(...)∧ret(TypedResults);
  log:msg_templates({Name})∧¬string_interpolation;
}
§D{
  expected_biz_fail(validation,not_found)⇒Result<T>⊕TypedResults.NotFound() ¬exceptions_for_control_flow;
  unexpected_exc⇒handle⊕rethrow_with_ctx ¬`catch (Exception) { }`;
  need_collaborator⇒ctor_DI ¬`new Service()`∈ctors;
  shared_state⇒DI_scope⊕ConcurrentDictionary ¬mutable_static_state;
  type_data⇒properties_w_right_accessors ¬public_fields;
  unknown_shape∈biz_logic⇒generics⊕explicit_types ¬dynamic;
  str_build∈loop⇒StringBuilder⊕interpolated_str_handlers ¬string.Format∈loops;
  cross_cutting_HTTP(timing,headers)⇒middleware(RequestDelegate+try/finally) ¬repeat_per_endpoint;
  read_only_EF_query⇒AsNoTracking() ¬tracked_entities_for_reads;
}
§REF{
  records,DI,async,WhenAll,options,Result<T>,EF_Core_repo,middleware,minimal_API,guard_clauses→references/csharp-patterns.md;
  C#_tests(xUnit_v3,Shouldly⊕AwesomeAssertions,¬FluentAssertions_8+_commercial,NSubstitute,WebApplicationFactory,Testcontainers,test_data_builders)→references/csharp-testing.md;
  F#_tests(xUnit,FsUnit,Unquote,FsCheck,fn_stubs,ASP.NET_Core_integration)→references/fsharp-testing.md;
  desktop_E2E(WPF,WinForms,Win32/MFC,Qt,pywinauto,UI_Automation,sandbox,CI=windows-latest)→references/windows-desktop-e2e.md;
}
§REL{
  ../backend-development/SKILL.md:API,service_design,ASP.NET_Core;
  ../database-design/SKILL.md:schema,migration_design,EF_Core;
  ../secure-coding/SKILL.md:auth,secrets,input_val;
  ../unit-testing-patterns/SKILL.md:TDD,mock_patterns;
}
