@REF:dart-flutter-patterns
§USE{feature(MVVM,state,nav,data,native,web)|review(null_safety,Freezed_3,Riverpod_3,Bloc_9,async)|http/graphql/storage|tests|GoRouter_typed}

§PAT:LANG{
  null_safety:¬`!`⇒`?.`|`??`|Dart3_pattern|early_guard(`if(u==null)return` promotes non-null);
  `late`⇒avoid;prefer `T?`∨ctor_init;`late final`⇔guaranteed_before_read(e.g.`initState` `AnimationController`);
  primary_ctors(Dart_3.13+):declaring params(`final`/`var`)∈class header eliminate field/ctor boilerplate;named/factory ctors stay in-body;
  dot_shorthands(Dart_3.10+):omit type prefix when static context infers type(`.center`,`.all(16)`,`case .loading =>`);
  upgrade:`dart migrate`+`dart fix --apply` automate SDK bumps∧syntax migrations
}
```dart
class Point(final int x, final int y) { factory Point.origin() => const Point(0, 0); }
final pad = Padding(padding: .all(16), child: Align(alignment: .center, child: Text(user?.name ?? 'Guest')));
```

§PAT:ARCH{
  official_MVVM:2_layers(UI:{View(Widget),ViewModel(ChangeNotifier|Notifier|Cubit)}→Data:{Repository(SSOT),Service(API/DB/Platform)});
  layout:feature_first(`lib/features/<feat>/{ui,data}/`+`lib/core/`);
  actions:wrap async UI commands∈`Result<T>`(`Ok<T>|Err<T>`)∨Command pattern(prevent double-tap,centralize loading/error)
}

§PAT:STATE{
  native:`sealed class`+`final class`(primary ctors)⇒exhaustive `switch`(0 impossible states);
  Freezed_3(BREAKING):single data class MUST use `abstract class`;union/state class MUST use `sealed class`(¬plain `class`);
  matching:Dart_3 native `switch` expressions ≻ legacy Freezed `.when()`/`.map()`;
  codegen:`part '<f>.freezed.dart';part '<f>.g.dart';`→`copyWith`,`toJson`,`fromJson`
}
```dart
@freezed abstract class User with _$User {
  const factory User({required String id, required String name, @Default(false) bool isAdmin}) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
@freezed sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(User user) = AuthAuthenticated;
  const factory AuthState.error(String message) = AuthError;
}
```

§PAT:ASYNC{
  concurrent⇒record `.wait`(¬sequential):`final (users,orders)=await (uRepo.getAll(),oRepo.getRecent()).wait;`;
  heavy_CPU⇒`await Isolate.run(() => parseLargeJson(raw))`∨long-lived worker `Isolate`(¬main isolate);
  stream⇒repo `Stream<T>`(`_db.watchCart().map(...)`)+`StreamBuilder`+exhaustive `switch(snap)`;
  post_await⇒CRITICAL `if(!mounted)return;`∨`if(!context.mounted)return;` before nav/`ScaffoldMessenger`/`setState`
}

§PAT:WIDGETS{
  extract `_build*()`→`StatelessWidget` classes(element reuse,`const`,rebuild isolation);
  `const` on leaf/parent(`const Padding`,`const Icon`) stops rebuild propagation;
  scope `ConsumerWidget`/`BlocBuilder` to leaf;prefer `MediaQuery.sizeOf(ctx)`/`paddingOf(ctx)`(¬`MediaQuery.of(ctx)`);
  modern_APIs:`color.withValues(alpha:0.5)`(¬`.withOpacity()`);`PopScope(canPop:...,onPopInvokedWithResult:...)`(¬`WillPopScope`);`WidgetStateProperty`(¬`MaterialStateProperty`);
  UI_pkgs:standalone `material_ui`/`cupertino_ui`(Flutter_3.50+ defaults);
  previews:`@Preview(name:'Card') Widget previewCard() => ...;` via stable `flutter widget-preview`
}

§PAT:BLOC_CUBIT{
  `bloc`/`flutter_bloc` 9+:global config via `Bloc.observer`/`Bloc.transformer`(¬removed `BlocOverrides`);
  `BlocListener`/`BlocConsumer` auto-check `mounted` before `listener` fires(¬redundant `if(!mounted)` in listeners);
  `class AuthCubit extends Cubit<AuthState>`:emit `AuthLoading()`→`AuthAuthenticated(u)`|`on AuthException catch(e){emit(AuthError(e.message));}`;
  UI:`BlocBuilder<AuthCubit,AuthState>`+exhaustive `switch(state)`(`AuthInitial()|AuthLoading()|AuthAuthenticated(:final user)|AuthError(:final message)`);
  test_streams:`BlocBase` implements `EmittableStateStreamableSource`→lightweight stream fakes
}

§PAT:RIVERPOD{
  Riverpod_3(BREAKING):`StateProvider`/`StateNotifierProvider`/`ChangeNotifierProvider` moved to `legacy.dart`⇒use `@riverpod` `Notifier`/`AsyncNotifier`;
  `AsyncValue`:`.valueOrNull` REMOVED⇒use `.value`(returns `T?` safely without throwing);
  lifecycle:check `if(!ref.mounted)return;` after `await`∈providers(prevents `UnmountedRefException`)∧cancel in-flight ops∈`ref.onDispose`;
  auto_retry:throwing providers retry up to 10x exp backoff(skips `Error`/`ProviderException`);override via `ProviderScope(retry:...)`∨`@Riverpod(retry:...)`(return `null` to disable);
  mutations(experimental):`final saveMut = Mutation<void>();` decouples submit loading/error from core data state
}
```dart
@riverpod Future<List<Product>> products(Ref ref) async {
  final token = await ref.watch(authTokenProvider.future);
  if (!ref.mounted) return [];
  return ref.read(productRepoProvider).fetchAll(token);
}
@riverpod int cartCount(Ref ref) => (ref.watch(cartProvider).value ?? []).length;
```

§PAT:GOROUTER{
  typed_routes:`go_router`+`go_router_builder` `@TypedGoRoute<ProductRoute>(path:'/products/:id')`→`const ProductRoute(id:'42').go(context)`(¬string paths/`pathParameters['id']!`);
  tabs:`StatefulShellRoute.indexedStack(builder:(_,__,shell)=>AppShell(shell:shell),branches:[...])` preserves per-tab state∧scroll offset(¬plain `ShellRoute`);
  auth_guard:`GoRouter(refreshListenable:authNotifier,redirect:(ctx,s){...})` checks auth∧`s.matchedLocation=='/login'`→`'/login'`|`'/'`|`null`
}

§PAT:STORAGE_NET{
  secure_storage:`flutter_secure_storage` v10+:use `const AndroidOptions(dataStore:true)`(DataStore+RSA-OAEP/AES-GCM;¬deprecated `EncryptedSharedPreferences`;temp migration sets both flags before v11 removal);
  local_DB:`Drift`(reactive SQLite streams,ACID,typed migrations)⊕`hive_ce`(maintained Hive fork,¬unmaintained `hive`)⊕`ObjectBox`;
  Dio:`BaseOptions(baseUrl:const String.fromEnvironment('API_URL'),connectTimeout:Duration(seconds:10),receiveTimeout:Duration(seconds:30))`;
  auth_refresh:`QueuedInterceptorsWrapper`(serializes concurrent 401 refreshes)∧`onRequest` attaches `Bearer $t`∧`onError` checks `401 && extra['_isRetry']!=true`→refresh→`extra['_isRetry']=true`→`dio.fetch(...)`;
  GraphQL:`Ferry`(normalized cache+`ferry_generator`)⊕`graphql_codegen`+`graphql_flutter`+`AuthLink`
}

§PAT:NATIVE_WEB{
  direct_interop(Flutter_3.50_stable):`package:ffigen`(C/ObjC,Dart-configured in Dart_3.14)+`package:jnigen`(Java/Kotlin)⇒sync/isolate native calls without `MethodChannel` serialization overhead;
  build_hooks:`hook/build.dart`(`package:hooks`+`package:native_toolchain_c`) compiles/bundles native libs automatically;`hook/link.dart` tree-shakes unused `@Native` symbols via `input.recordedUses`;
  structured_fallback:`Pigeon`(type-safe+native-interop mode)≻raw `MethodChannel`/`EventChannel`;
  web_wasm:compile w/ `dart2wasm`+Skwasm(`--wasm`,optional `--enable-wasm-deferred-loading`);use `dart:js_interop`(`JSIterable`,`JSIterator`,`--no-deprecated-js-interop`)∧¬`dart:html`/`dart:js`
}

§PAT:ERRORS{
  `main()`:`FlutterError.onError=(d){FlutterError.presentError(d);crashlytics.recordFlutterFatalError(d);};`
  `PlatformDispatcher.instance.onError=(e,s){crashlytics.recordError(e,s,fatal:true);return true;};`;
  `App.build()`:`ErrorWidget.builder=(d)=>ProductionErrorWidget(d);MaterialApp.router(routerConfig:router)`
}

§PAT:TEST{
  fakes≻mocks(`mocktail` for concise runtime mocks;`package:checks` optional modern assertions);
  unit:`test(...,()async=>expect(await GetUser(FakeUserRepo())('missing'),isNull))`;
  BLoC:`blocTest<AuthCubit,AuthState>(...,build:()=>AuthCubit(FakeAuth(throwsOn:'login')),act:(c)=>c.login(...),expect:()=>[const AuthLoading(),isA<AuthError>()])`;
  Riverpod:`ProviderContainer(overrides:[...])`+`addTearDown(c.dispose)`|widget `ProviderScope(overrides:[...])`;
  E2E:`Patrol`(`patrolTest`) for native OS flows(permission dialogs,notifications,webviews,WiFi/GPS)⊕`integration_test`
}

§SRC{https://dart.dev/effective-dart/design|https://docs.flutter.dev/app-architecture|https://docs.flutter.dev/perf/best-practices|https://docs.flutter.dev/platform-integration/web/wasm|https://dart.dev/interop/c-interop|https://riverpod.dev/|https://bloclibrary.dev/|https://pub.dev/packages/go_router|https://pub.dev/packages/freezed}
§REL{flutter-code-review.md|project-workflow.md|../SKILL.md}
