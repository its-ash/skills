---
name: dotnet
description: "AUTO_INVOKE(silent)⇔prompt∈{.cs,.fs,.csproj,.sln,.slnx,C#,F#,.NET,ASP.NET_Core,EF_Core,dotnet_build,dotnet_test,xUnit,MTP,NSubstitute,Shouldly,AwesomeAssertions,Testcontainers,WebApplicationFactory,minimal_API,AddValidation,OpenApi,Scalar,HybridCache,IExceptionHandler,TimeProvider,Lock,middleware,DI,CancellationToken,Result<T>,sealed_record,IOptions,AsNoTracking,TypedResults,WPF,WinForms,WinUI3,Win32,MFC,Qt,FlaUI,pywinauto,Windows_desktop,FsUnit,Unquote,FsCheck,Expecto}|SUB:{csharp-patterns,csharp-testing,fsharp-testing,windows-desktop-e2e}"
---
@SKL:dotnet
§R{
  target:.NET_10_LTS(C#14,F#10,EOS=2028-11-14)⊕.NET_11_STS(C#15,GA=2026-11-10,EOS=2028-11-14);EOL(.NET_8,.NET_9)=2026-11-10;
  proj:SDK_style∧Nullable=on∧ImplicitUsings=on∧TreatWarningsAsErrors∧CPM∧.slnx(dotnet_sln_migrate)∧file_apps(dotnet_run_app.cs);
  json_openapi:System.Text.Json∧Microsoft.AspNetCore.OpenApi+Scalar.AspNetCore∧¬add_new(Newtonsoft.Json,Swashbuckle);
  types:value_obj⇒sealed_record;DTO⇒required+init;C#14_field_props∧C#15_unions(.NET_11);collections⇒IReadOnlyList<T>∧¬List<T>;
  classes_nrt:NRT=enabled∧nullable_ret⇒T?;classes⇒sealed_default∧explicit_access_modifiers;
  DI:depend_on(interfaces@svc_bounds)∧reg(AddScoped|AddSingleton|AddTransient)∧primary_ctor_DI∧inject(TimeProvider);
  async:async_all_way∧∀async⇒accept+pass(CancellationToken)∧¬block(.Result∨.Wait())∧ret(Task,¬async_void_except_events)∧parallel⇒Task.WhenAll;
  sync_cache:locks⇒System.Threading.Lock(¬lock(object));cache⇒HybridCache(L1+L2,stampede_safe);
  cfg:AddOptions<T>().BindConfiguration(T.SectionName).ValidateDataAnnotations().ValidateOnStart()∧inject(IOptions<T>);
  errors:expected_fail⇒Result<T>;unhandled_HTTP⇒IExceptionHandler+AddProblemDetails();throw⇔programmer_err∨invalid_arg;
  guards:guard_early(ArgumentNullException.ThrowIfNull,ArgumentOutOfRangeException,ArgumentException)∧happy_path_unnested;
  EF_Core:read⇒AsNoTracking()∧Select_proj⊕Include(needed_only);EF10+(LeftJoin,named_filters,JSON_cols);EF11+(join_pruning,SqlVector,net-ef.json);
  minimal_API:MapGroup(...).RequireAuthorization().WithTags(...)∧AddValidation()(.NET_10+,async_.NET_11)∧ret(TypedResults);
  log_perf:log⇒[LoggerMessage]⊕msg_templates({Name})∧¬str_interp;timing⇒Stopwatch.GetTimestamp()+GetElapsedTime()(0_alloc);
  tests:xUnit_v3+MTP(global.json:Microsoft.Testing.Platform)∧Shouldly⊕AwesomeAssertions(¬FluentAssertions_8+)∧NSubstitute∧Testcontainers(¬UseInMemoryDatabase);
}
§D{
  expected_biz_fail(validation,not_found)⇒Result<T>⊕TypedResults.NotFound() ¬exceptions_for_control_flow;
  unhandled_HTTP_exc⇒IExceptionHandler+AddProblemDetails() ¬`catch (Exception) { }`∨per_endpoint_try_catch;
  need_collaborator_or_clock⇒ctor_DI+TimeProvider ¬`new Service()`∈ctors∨DateTime.Now;
  shared_state_or_lock⇒DI_scope⊕ConcurrentDictionary⊕System.Threading.Lock ¬mutable_static_state∨lock(object);
  caching⇒HybridCache.GetOrCreateAsync ¬manual_IMemoryCache+IDistributedCache_chaining;
  type_data⇒properties_w_field_kw_or_init ¬public_fields;
  unknown_shape∈biz_logic⇒generics⊕explicit_types ¬dynamic;
  str_build∈loop⇒StringBuilder⊕interpolated_str_handlers ¬string.Format∈loops;
  cross_cutting_HTTP(timing,headers)⇒middleware(RequestDelegate+Stopwatch.GetTimestamp+try/finally) ¬repeat_per_endpoint;
  read_only_EF_query⇒AsNoTracking()+Select_proj ¬tracked_entities_for_reads;
  DB_integration_test⇒Testcontainers(real_DB)⊕SQLite_in_mem ¬EF_UseInMemoryDatabase;
  win_GUI_E2E⇒FlaUI(.NET/C#)⊕pywinauto(Py,UIA) ¬WinAppDriver_legacy∨sleep;
}
§REF{
  C#_patterns(records,C#14_field,C#15_unions,DI,TimeProvider,Lock,async,WhenAll,options_ValidateOnStart,HybridCache,Result<T>,IExceptionHandler,EF_Core_10/11,middleware,minimal_API_AddValidation,OpenApi+Scalar,LoggerMessage,guards)→references/csharp-patterns.md;
  C#_tests(xUnit_v3,MTP,TestContext.CancellationToken,Shouldly⊕AwesomeAssertions,¬FluentAssertions_8+,NSubstitute,FakeTimeProvider,WebApplicationFactory,Testcontainers,builders)→references/csharp-testing.md;
  F#_tests(F#10_task_and!,xUnit_v3,MTP,FsUnit,Unquote,FsCheck_3_ArbMap,FsCheck.Xunit.v3,Expecto,fn_stubs,WAF+Testcontainers)→references/fsharp-testing.md;
  desktop_E2E(WPF,WinForms,WinUI3,Win32/MFC,Qt,FlaUI,pywinauto,UIA,sandbox,CI=windows-latest)→references/windows-desktop-e2e.md;
}
§REL{
  ../backend-development/SKILL.md:API,service_design,ASP.NET_Core;
  ../database-design/SKILL.md:schema,migration_design,EF_Core;
  ../secure-coding/SKILL.md:auth,secrets,input_val;
  ../unit-testing-patterns/SKILL.md:TDD,mock_patterns;
}
