@REF:flutter-code-review
§USE{PR/branch/codebase_review|pre-release_audit|any_state_mgmt(Riverpod_3,BLoC_9,Provider,GetX,MobX,Signals,ValueNotifier)}
§REL{../../code-review/SKILL.md:workflow,report_fmt|dart-flutter-patterns.md:fix_patterns|project-workflow.md:release_ci}

§CHK:HEALTH{
  consistent_structure(feature-first+official_MVVM∨Clean_Arch)|SoC(UI/logic/data)|¬logic∈widget|
  clean `pubspec.yaml`(¬unused,pinned,¬unmaintained `hive`)|strict `analysis_options.yaml`|
  ¬`print()`∈prod⇒`dart:developer` `log()`∨logger|¬`dart:html`/`dart:js`(breaks Wasm)|
  generated(`.g.dart`,`.freezed.dart`) synced∨`.gitignore`|platform_code behind abstractions
}

§CHK:DART{
  ¬implicit `dynamic`⇒`strict-casts`,`strict-inference`,`strict-raw-types`|
  ¬excessive `!`⇒null_checks∨`if(value case var v?)`|type_promo:¬`this.field` where local promotes|
  ¬broad `catch(e)` without `on`|¬catch `Error`(bugs)|¬unused `async` without `await`|
  ¬`late` overuse⇒nullable∨ctor_init|loop string concat⇒`StringBuffer`|¬mutable∈`const`_ctor|
  ¬ignore `Future`⇒`await`∨`unawaited()`|`final` locals,`const` compile-time|`package:` imports(¬relative)|
  ¬expose mutable `List`/`Map`⇒unmodifiable views|Dart3 `switch`/`if-case`≻`is`+cast|records `(String,int)`≻throwaway DTOs|
  Dart_3.10-3.14:primary_ctors reduce data boilerplate|dot_shorthands only when static context clear|`Isolate.run()` for one-shot CPU work
}

§CHK:WIDGETS{
  decomp:`build()`≤80-100L|split by encapsulation∧rebuild_boundary|extract `_build*()`→classes(reuse,`const`,opt)|`StatelessWidget`≻`StatefulWidget`(no local mutable)|reusable→own files;
  const:`const` ctors|`const []`/`const {}`|`const` ctor if ∀fields `final`;
  keys:`ValueKey`(list/grid reorder)|`GlobalKey` sparingly(cross-tree)|¬`UniqueKey`∈`build()`(rebuild/frame)|`ObjectKey`(data identity);
  theme:`Theme.of(context).colorScheme`(¬`Colors.red`/hex)|`Theme.of(context).textTheme`(¬raw fontSize)|dark_mode verified|design tokens(¬magic nums);
  modern_APIs:`Color.withValues()`(¬deprecated `.withOpacity()`/`.withAlpha()`/`.withRed()`)|`PopScope`(`onPopInvokedWithResult`,¬removed `WillPopScope`)|`WidgetStateProperty`(¬`MaterialStateProperty`)|`@Preview` for reusable UI;
  build:¬net/fileIO/heavy_cpu/`Future.then()`/`async`/`.listen()`∈`build()`|`setState()` smallest subtree
}

§CHK:STATE{
  arch:logic∉widget|DI(¬internal new)|repo/svc abstracts API/DB|SRP(¬god mgr)|cross_dep:{Riverpod:`ref.watch` OK(flag circular);BLoC:¬bloc→bloc(shared repo∨UI coord);other:convention};
  immut(BLoC,Riverpod,Redux):`copyWith()`/ctor(¬in-place)|`==`∧`hashCode` ∀fields|Freezed_3(`abstract` data|`sealed` union,¬plain `class`,native `switch`≻`.when()`/`.map()`)|¬raw mutable `List`/`Map`;
  react(MobX,GetX,Signals):mutate via API only(`@action`,`.value`,`.obs`)|computed for derived|cleanup(`ReactionDisposer`,effect);
  Riverpod_3:flag removed `.valueOrNull`(→`.value`)|flag legacy `StateProvider`/`StateNotifierProvider`(→`Notifier`/`AsyncNotifier`)|check `ref.mounted` after `await`(¬`UnmountedRefException`)|verify auto-retry opt-out on non-idempotent ops;
  BLoC_9:flag removed `BlocOverrides`(→`Bloc.observer`/`Bloc.transformer`)|`BlocListener`/`BlocConsumer` already check `mounted`;
  shape:mutually_exclusive⇒`sealed`/union/`AsyncValue`(¬bool soup `isLoading`/`hasError`/`hasData`)|exhaustive UI switch|error carries info,loading ¬stale data|¬nullable data as loading indicator;
  rebuild:narrow consumer(`Builder`,`Consumer`,`Observer`,`Obx`,`Watch`)|selectors|`const` propagation stop|reactive derived;
  lifecycle:cancel `.listen()`∈`dispose()`/`close()`|close `StreamController`|cancel `Timer`|declarative≻`.listen()`|`mounted` before `setState`|`context.mounted` after `await`(nav/dialog/`ScaffoldMessenger`)|¬store `BuildContext`∈singleton/state_mgr/static;
  scope:ephemeral(checkbox/slider/anim)⇒`setState`/`ValueNotifier`|shared lifted min height|feature-scoped disposed when inactive
}

§SM{
  BLoC_9/Cubit:{box:`Bloc`/`Cubit`,UI:`BlocBuilder`,sel:`BlocSelector`/`buildWhen`,fx:`BlocListener`(auto-mounted),disp:auto(`BlocProvider`),test:`blocTest()`};
  Riverpod_3:{box:`Notifier`/`AsyncNotifier`,UI:`ConsumerWidget`,sel:`ref.watch(p.select(...))`,fx:`ref.listen`,disp:autoDispose+`ref.mounted`,test:`ProviderContainer`};
  Provider:{box:`ChangeNotifier`,UI:`Consumer`,sel:`Selector`,fx:`Consumer` cb,disp:auto(`Provider`),test:`ChangeNotifier`};
  GetX:{box:`GetxController`,UI:`Obx`/`GetBuilder`,sel:∅,fx:`ever()`/`once()`,disp:`onClose()`,test:`Get.put`};
  MobX:{box:`Store`,UI:`Observer`,sel:computed,fx:`reaction`,disp:`ReactionDisposer`,test:store};
  Signals:{box:`signal()`,UI:`Watch`,sel:`computed()`,fx:`effect()`,disp:manual,test:signal};
  Built-in:{box:`StatefulWidget`,UI:`setState`,sel:∅,fx:callbacks,disp:`dispose()`,test:widget test}
}

§CHK:PERF{
  rebuilds:¬root `setState()`|`const`|`RepaintBoundary` independent complex subtrees|`AnimatedBuilder` `child` for static subtree;
  build:¬sort/filter/map large collections∈`build()`|¬regex∈`build()`|`MediaQuery.sizeOf(context)`/`paddingOf(context)`≻`MediaQuery.of(context)`;
  images:cached net|target res(¬4K thumbnail)|`Image.asset` `cacheWidth`/`cacheHeight`|placeholder+error;
  lazy:`ListView.builder`/`GridView.builder`/`SliverList` large/dynamic|pagination|`deferred as`+`--enable-wasm-deferred-loading` heavy web libs;
  render:verify custom shaders/blends/filters under Impeller(iOS,Android_10+,macOS)|Web Wasm(Skwasm/CanvasKit,flag defunct `--web-renderer html`);
  other:¬`Opacity`∈anim⇒`AnimatedOpacity`/`FadeTransition`|¬clip∈anim⇒pre-clip|¬override `operator ==` on widgets⇒`const`|sparse `IntrinsicHeight`/`IntrinsicWidth`(extra layout pass)
}

§CHK:TEST{
  types:unit(VM/repo/util)|widget(UI/interaction/output)|integration(E2E)|golden(pixel-perfect critical UI)|Patrol(native OS perms/notifs/webviews);
  targets:≥80% line cov(logic)|∀state transitions(loading→success/error,retry)|edges(empty/error/loading/boundary);
  isolation:fakes≻mocks(`mocktail`)|1 class/unit per file|behavior ¬impl|minimal stubbing|¬shared mutable state|`addTearDown` disposes containers;
  quality:`pumpWidget`+`pump`(async)|`find.byType`/`find.text`/`find.byKey`|¬timing-flaky⇒`pumpAndSettle`∨`pump(Duration)`|CI blocks merge
}

§CHK:A11Y{
  semantics:`Semantics`(labels)|`ExcludeSemantics`(decorative)|`MergeSemantics`(group)|`Image` `semanticLabel`;
  reader:focusable+meaningful desc|logical focus=visual reading order;
  visual:contrast≥4.5:1|tap≥48x48dp|¬color-only state(icons+text)|scales w/ `MediaQuery.textScalerOf(context)`;
  interact:¬no-op `onPressed`(acts∨disabled)|error suggests fix|¬unexpected ctx change on input
}

§CHK:PLATFORM{
  iOS:SPM default(flag CocoaPods-only lock-in)|`UIScene` lifecycle(`UIWindowSceneDelegate` for custom native setup,¬window init in `AppDelegate`)|min iOS_15+/macOS_12+|swipe back;
  Android:16KB page-aligned native NDK libs(Play Store mandate)|edge-to-edge default(API_35+⇒verify `SafeArea`/`MediaQuery.paddingOf`)|Predictive Back via `PopScope`;
  native_interop:Direct Native Interop(`ffigen`/`jnigen`+`hook/build.dart`/`hook/link.dart`)∨`Pigeon`≻untyped `MethodChannel` strings;
  responsive:`LayoutBuilder`/`MediaQuery.sizeOf`|breakpoints(phone/tablet/desktop)|¬overflow⇒`Flexible`/`Expanded`/`FittedBox`|landscape tested∨locked|web:mouse/keyboard/hover+`dart:js_interop`
}

§CHK:SEC{
  storage:iOS Keychain/`flutter_secure_storage` v10+(`AndroidOptions(dataStore:true)`,RSA-OAEP/AES-GCM,¬deprecated `EncryptedSharedPreferences`)|¬plaintext secrets|biometric gate sensitive ops;
  keys:¬hardcoded⇒`--dart-define`/`--dart-define-from-file`,`.env`∉VCS|check `.gitignore`|backend proxy for server secrets(client binary extractable);
  input:validate before API|form validation|¬raw SQL/interpolated input|validate+sanitize deep links before nav;
  net:HTTPS|cert pinning(high-sec)|serialized token refresh(`QueuedInterceptorsWrapper`+retry flag)|¬log/print sensitive
}

§CHK:PKG{
  pub.dev:points≥130/160|likes/downloads|verified publisher|active maintenance(flag unmaintained `hive`→`hive_ce`)|license compat|target platforms(incl Wasm);
  constraints:caret `^1.2.3`|exact only if req|`flutter pub outdated`|¬`dependency_overrides`∈prod `pubspec.yaml`(temp fix+comment/issue)|min transitive deps;
  monorepo:Dart Pub Workspaces(root `workspace:`,member `resolution: workspace`,single `pubspec.lock`,¬`path: ../../`)|public API only(¬`package:other/src/`)|inherit root `analysis_options.yaml`
}

§CHK:NAV{
  1 approach(¬mix `Navigator.push`+declarative)|`go_router`+`go_router_builder`(`@TypedGoRoute`,¬string paths/`Object?` casts)|`StatefulShellRoute.indexedStack` for persistent tabs|centralized auth guards/redirects|Android+iOS deep links validated+sanitized|testable nav|back(`PopScope`) valid ∀platforms
}

§CHK:ERR{
  fw:`FlutterError.onError`(build/layout/paint)|`PlatformDispatcher.instance.onError`(uncaught async)|`ErrorWidget.builder`∈release|Crashlytics/Sentry;
  report:non-fatal+stacks|obfuscated release symbols uploaded(`--split-debug-info`)|state observer(`BlocObserver`,`ProviderObserver`)|user ID attached(PII-safe);
  graceful:API err→user UI|retry transient net|offline handled|error state carries info|map raw exceptions→localized user msgs(¬raw)
}

§CHK:L10N{
  setup:`flutter_localizations`+ARB(`l10n.yaml`)|supported locales declared;
  content:¬hardcoded user strings|translator context/desc|ICU(plurals/genders/selects)|typed placeholders|¬missing keys across locales;
  review:consistent accessor|locale date/time/num/currency|RTL(`EdgeInsetsDirectional`)|¬string concat⇒parameterized
}

§CHK:DI{
  abstractions/interfaces at boundaries|external injection(ctor/DI/graph,¬internal)|lifetime(singleton/factory/lazySingleton)|env bindings(dev/staging/prod) via cfg(¬runtime `if`)|¬circular deps|¬scattered service locator∈logic
}

§CHK:ANALYSIS{
  `analysis_options.yaml`:`strict-casts:true`,`strict-inference:true`,`strict-raw-types:true`|lints(`very_good_analysis`,`flutter_lints`)|custom lints via `plugins:`(`analysis_server_plugin`,¬legacy `analyzer_plugin`)|monorepo inherits root;
  enforce:0 warnings|`// ignore:` justified|`flutter analyze`+`dart format --output=none --set-exit-if-changed` block CI merge;
  rules:`prefer_const_constructors`,`avoid_print`,`unawaited_futures`,`prefer_final_locals`,`always_declare_return_types`,`avoid_catches_without_on_clauses`,`always_use_package_imports`
}

§SRC{https://dart.dev/effective-dart/style|https://dart.dev/effective-dart/usage|https://dart.dev/effective-dart/design|https://docs.flutter.dev/app-architecture|https://docs.flutter.dev/perf/best-practices|https://docs.flutter.dev/testing/overview|https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility|https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization|https://docs.flutter.dev/ui/navigation|https://docs.flutter.dev/testing/errors|https://docs.flutter.dev/data-and-backend/state-mgmt/options}
