@REF:dart-flutter-patterns
§USE{feature(state,nav,data)|review(null_safety,sealed,async)|setup(BLoC,Riverpod,Provider)|http/webview/storage|tests|GoRouter_auth}

§PAT:NULL{
  ¬`!`⇒`?.`|`??`|Dart3_pattern|early_guard(`if(u==null)return` promotes non-null);
  `late`⇒avoid;prefer `T?`∨ctor_init;`late final`⇔guaranteed_before_read(e.g.`initState` `AnimationController(vsync:this,duration:const Duration(milliseconds:300))`)
}
```dart
final name = user?.name ?? 'Unknown';
final s = switch (user) { User(:final name, :final email) => '$name <$email>', null => 'Guest' };
```

§PAT:STATE{
  `sealed class`+`final class`⇒exhaustive `switch`(no impossible states);
  `AsyncState<T>`=`Loading<T>|Success<T>(T data)|Failure<T>(Object error)`;
  `UserState`=`UserInitial|UserLoading|UserLoaded(User user)|UserError(String message)`;
  `freezed`:`part '<f>.freezed.dart';part '<f>.g.dart';`→`copyWith`,`toJson`,`fromJson`
}
```dart
@freezed class User with _$User {
  const factory User({required String id, required String name, required String email, @Default(false) bool isAdmin}) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

§PAT:ASYNC{
  concurrent⇒record `.wait`(¬sequential):`final (users,orders)=await (uRepo.getAll(),oRepo.getRecent()).wait;`;
  stream⇒repo `Stream<T>`(`_db.watchTable('cart_items').map((r)=>r.map(Item.fromRow).toList())`)+`StreamBuilder`+`switch(snap)`(`ConnectionState.waiting`,`:final error?`,`:final data?`,`_`);
  post_await⇒CRITICAL `if(!mounted)return;` before `context.go(...)`|`ScaffoldMessenger.of(context)`|`setState`∈`finally`(`if(mounted)setState(...)`)
}

§PAT:WIDGETS{
  extract `_build*()`→`StatelessWidget` classes(element reuse,`const`,opts);
  `const` on leaf/parent(`const Padding`,`const Icon`) stops rebuild propagation;
  scope `ConsumerWidget`/`BlocBuilder` to leaf(parent=`StatelessWidget`+`const` children)
}

§PAT:BLOC_CUBIT{
  `class AuthCubit extends Cubit<AuthState>`:`super(const AuthState.initial())`,emit `AuthState.loading()`→`AuthState.authenticated(u)`|`on AuthException catch(e){emit(AuthState.error(e.message));}`,`logout()`;
  UI:`BlocBuilder<AuthCubit,AuthState>`+exhaustive `switch(state)`(`AuthInitial|AuthLoading|AuthAuthenticated(:final user)|AuthError(:final message)`)
}

§PAT:RIVERPOD{
  `@riverpod Future<List<Product>> products(Ref ref)`|`@riverpod class CartNotifier extends _$CartNotifier`(`build()=>[]`,immutable `state=[...]`/`copyWith`);
  derived selectors:`@riverpod int cartCount(Ref ref)`|`@riverpod double cartTotal(Ref ref)` via `.valueOrNull??[]`+`firstWhereOrNull`(`package:collection`,avoids `StateError`)
}

§PAT:GOROUTER{
  `GoRouter(initialLocation:'/',refreshListenable:GoRouterRefreshStream(authCubit.stream),redirect:(ctx,s){...})`
  guard:`ctx.read<AuthCubit>().state is AuthAuthenticated`∧`s.matchedLocation=='/login'`→`'/login'`|`'/'`|`null`;
  `ShellRoute(builder:(_,__,child)=>AppShell(child:child),routes:[GoRoute(path:'/products/:id',builder:(_,s)=>ProductDetailPage(id:s.pathParameters['id']!))])`
}

§PAT:DIO{
  `Dio(BaseOptions(baseUrl:const String.fromEnvironment('API_URL'),connectTimeout:Duration(seconds:10),receiveTimeout:Duration(seconds:30),headers:{'Content-Type':'application/json'}))`;
  `InterceptorsWrapper`:`onRequest`→`secureStorage.read(key:'auth_token')`→`Authorization:Bearer $t`;
  `onError`:401∧`extra['_isRetry']!=true`⇒`attemptTokenRefresh()`→`extra['_isRetry']=true`→`handler.resolve(await dio.fetch(err.requestOptions))`(prevents infinite retry loop);
  DataSource:`_dio.get<Map<String,dynamic>>('/users/$id')`→`User.fromJson(res.data!)`
}

§PAT:ERRORS{
  `main()`:`FlutterError.onError=(d){FlutterError.presentError(d);crashlytics.recordFlutterFatalError(d);};`
  `PlatformDispatcher.instance.onError=(e,s){crashlytics.recordError(e,s,fatal:true);return true;};`;
  `App.build()`:`ErrorWidget.builder=(d)=>ProductionErrorWidget(d);MaterialApp.router(routerConfig:router)`
}

§PAT:TEST{
  fakes>mocks;
  unit:`test(...,()async=>expect(await GetUserUseCase(FakeUserRepository())('missing-id'),isNull))`;
  BLoC:`blocTest<AuthCubit,AuthState>(...,build:()=>AuthCubit(FakeAuthService(throwsOn:'login')),act:(c)=>c.login(...),expect:()=>[const AuthState.loading(),isA<AuthError>()])`;
  widget:`testWidgets(..., (t)async{await t.pumpWidget(ProviderScope(overrides:[cartNotifierProvider.overrideWith(()=>FakeCartNotifier(count:3))],child:const MaterialApp(home:CartBadge())));expect(find.text('3'),findsOneWidget);})`
}

§SRC{https://dart.dev/effective-dart/design|https://docs.flutter.dev/perf/best-practices|https://riverpod.dev/|https://bloclibrary.dev/|https://pub.dev/packages/go_router|https://pub.dev/packages/freezed}
§REL{flutter-code-review.md|../SKILL.md}
