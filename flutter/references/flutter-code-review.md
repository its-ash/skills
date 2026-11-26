@REF:flutter-code-review
§USE{PR/branch/codebase_review|pre-release_audit|any_state_mgmt(BLoC,Riverpod,Provider,GetX,MobX,Signals,ValueNotifier)}
§REL{../../code-review/SKILL.md:workflow,report_fmt|dart-flutter-patterns.md:fix_patterns}

§CHK:HEALTH{
  consistent_structure(feature-first∨layer-first)|SoC(UI/logic/data)|¬logic∈widget|
  clean `pubspec.yaml`(¬unused,pinned)|strict `analysis_options.yaml`|
  ¬`print()`∈prod⇒`dart:developer` `log()`∨logger|
  generated(`.g.dart`,`.freezed.dart`,`.gr.dart`) synced∨`.gitignore`|platform_code behind abstractions
}

§CHK:DART{
  ¬implicit `dynamic`⇒`strict-casts`,`strict-inference`,`strict-raw-types`|
  ¬excessive `!`⇒null_checks∨`if(value case var v?)`|type_promo:¬`this.field` where local promotes|
  ¬broad `catch(e)` without `on`|¬catch `Error`(bugs)|¬unused `async` without `await`|
  ¬`late` overuse⇒nullable∨ctor_init|loop string concat⇒`StringBuffer`|¬mutable∈`const`_ctor|
  ¬ignore `Future`⇒`await`∨`unawaited()`|`final` locals,`const` compile-time|`package:` imports(¬relative)|
  ¬expose mutable `List`/`Map`⇒unmodifiable views|Dart3 `switch`/`if-case`>`is`+cast|records `(String,int)`>throwaway DTOs|
  ¬`print()`(no levels/filter)⇒`dart:developer` `log()`
}

§CHK:WIDGETS{
  decomp:`build()`≤80-100L|split by encapsulation∧rebuild_boundary|extract `_build*()`→classes(reuse,`const`,opt)|`StatelessWidget`>`StatefulWidget`(no local mutable)|reusable→own files;
  const:`const` ctors|`const []`/`const {}`|`const` ctor if ∀fields `final`;
  keys:`ValueKey`(list/grid reorder)|`GlobalKey` sparingly(cross-tree)|¬`UniqueKey`∈`build()`(rebuild/frame)|`ObjectKey`(data object identity);
  theme:`Theme.of(context).colorScheme`(¬`Colors.red`/hex)|`Theme.of(context).textTheme`(¬raw fontSize)|dark_mode verified|design tokens(¬magic nums);
  build:¬net/fileIO/heavy_cpu/`Future.then()`/`async`/`.listen()`∈`build()`|`setState()` smallest subtree
}

§CHK:STATE{
  arch:logic∉widget|DI(¬internal new)|repo/svc abstracts API/DB|SRP(¬god mgr)|cross_dep:{Riverpod:`ref.watch` OK(flag circular/tangled);BLoC:¬bloc→bloc(shared repo∨UI coord);other:convention};
  immut(BLoC,Riverpod,Redux):`copyWith()`/ctor(¬in-place)|`==`∧`hashCode` ∀fields|consistent mech(manual/`Equatable`/`freezed`/records)|¬raw mutable `List`/`Map`;
  react(MobX,GetX,Signals):mutate via API only(`@action`,`.value`,`.obs`)|computed for derived|cleanup(`ReactionDisposer`,effect);
  shape:mutually_exclusive⇒`sealed`/union/`AsyncValue`(¬bool soup `isLoading`/`hasError`/`hasData`)|distinct loading/success/error|exhaustive UI switch|error carries info,loading ¬stale data|¬nullable data as loading indicator;
  rebuild:narrow consumer(`Builder`,`Consumer`,`Observer`,`Obx`,`Watch`)|selectors|`const` propagation stop|reactive derived;
  lifecycle:cancel `.listen()`∈`dispose()`/`close()`|close `StreamController`|cancel `Timer`|declarative>`.listen()`|`mounted` before `setState`|`context.mounted`(Flutter≥3.7) after `await`(nav/dialog/`ScaffoldMessenger`)|¬store `BuildContext`∈singleton/state_mgr/static;
  scope:ephemeral(checkbox/slider/anim)⇒`setState`/`ValueNotifier`|shared lifted min height|feature-scoped disposed when inactive
}
// BAD: bool isLoading,hasError (impossible state); GOOD: sealed UserState(Initial|Loading|Loaded(User)|Error(String)) ∨ reactive enum UserStatus{initial,loading,loaded,error}

§SM{
  BLoC/Cubit:{box:`Bloc`/`Cubit`,UI:`BlocBuilder`,sel:`BlocSelector`/`buildWhen`,fx:`BlocListener`,disp:auto(`BlocProvider`),test:`blocTest()`};
  Riverpod:{box:`Notifier`/`AsyncNotifier`,UI:`ConsumerWidget`,sel:`ref.watch(p.select(...))`,fx:`ref.listen`,disp:`.autoDispose`,test:`ProviderContainer`};
  Provider:{box:`ChangeNotifier`,UI:`Consumer`,sel:`Selector`,fx:`Consumer` cb,disp:auto(`Provider`),test:`ChangeNotifier`};
  GetX:{box:`GetxController`,UI:`Obx`/`GetBuilder`,sel:∅,fx:`ever()`/`once()`,disp:`onClose()`,test:`Get.put`};
  MobX:{box:`Store`,UI:`Observer`,sel:computed,fx:`reaction`,disp:`ReactionDisposer`,test:store};
  Signals:{box:`signal()`,UI:`Watch`,sel:`computed()`,fx:`effect()`,disp:manual,test:signal};
  Built-in:{box:`StatefulWidget`,UI:`setState`,sel:∅,fx:callbacks,disp:`dispose()`,test:widget test}
}

§CHK:PERF{
  rebuilds:¬root `setState()`|`const`|`RepaintBoundary` independent complex subtrees|`AnimatedBuilder` `child` for static subtree;
  build:¬sort/filter/map large collections∈`build()`|¬regex∈`build()`|`MediaQuery.sizeOf(context)`>`MediaQuery.of(context)`;
  images:cached net|target res(¬4K thumbnail)|`Image.asset` `cacheWidth`/`cacheHeight`|placeholder+error;
  lazy:`ListView.builder`/`GridView.builder` large/dynamic(concrete OK small/static)|pagination|`deferred as` heavy web libs;
  other:¬`Opacity`∈anim⇒`AnimatedOpacity`/`FadeTransition`|¬clip∈anim⇒pre-clip|¬override `operator ==` on widgets⇒`const`|sparse `IntrinsicHeight`/`IntrinsicWidth`(extra layout pass)
}

§CHK:TEST{
  types:unit(state_mgr/repo/util)|widget(UI/interaction/output)|integration(E2E)|golden(pixel-perfect critical UI);
  targets:≥80% line cov(logic)|∀state transitions(loading→success/error,retry)|edges(empty/error/loading/boundary);
  isolation:mock/fake deps(API/DB/svc)|1 class/unit per file|behavior ¬impl|minimal stubbing|¬shared mutable state;
  quality:`pumpWidget`+`pump`(async)|`find.byType`/`find.text`/`find.byKey`|¬timing-flaky⇒`pumpAndSettle`∨`pump(Duration)`|CI blocks merge
}

§CHK:A11Y{
  semantics:`Semantics`(labels)|`ExcludeSemantics`(decorative)|`MergeSemantics`(group)|`Image` `semanticLabel`;
  reader:focusable+meaningful desc|logical focus=visual reading order;
  visual:contrast≥4.5:1|tap≥48x48px|¬color-only state(icons+text)|scales w/ system font;
  interact:¬no-op `onPressed`(acts∨disabled)|error suggests fix|¬unexpected ctx change on input
}

§CHK:PLATFORM{
  native:platform-adaptive widgets|back nav(Android back,iOS swipe)|`SafeArea`|perms∈`AndroidManifest.xml`∧`Info.plist`;
  responsive:`LayoutBuilder`/`MediaQuery`|breakpoints(phone/tablet/desktop)|¬overflow⇒`Flexible`/`Expanded`/`FittedBox`|landscape tested∨locked|web:mouse/keyboard/hover
}

§CHK:SEC{
  storage:Keychain(iOS)/`EncryptedSharedPreferences`(Android)|¬plaintext secrets|biometric gate sensitive ops;
  keys:¬hardcoded⇒`--dart-define`,`.env`∉VCS,compile-time|check `.gitignore`|backend proxy for server secrets;
  input:validate before API|form validation|¬raw SQL/interpolated input|validate+sanitize deep links before nav;
  net:HTTPS|cert pinning(high-sec)|token refresh+expiry|¬log/print sensitive
}

§CHK:PKG{
  pub.dev:points≥130/160|likes/popularity|verified publisher|publish≤1yr(stale risk)|open issues+response|license compat|target platforms;
  constraints:caret `^1.2.3`|exact only if req|`flutter pub outdated`|¬`dependency_overrides`∈prod `pubspec.yaml`(temp fix+comment/issue)|min transitive deps;
  monorepo(melos/workspace):public API only(¬`package:other/src/internal.dart`)|workspace resolution(¬`path: ../../`)|inherit root `analysis_options.yaml`
}

§CHK:NAV{
  1 approach(¬mix `Navigator.push`+declarative)|typed args(¬`Map<String,dynamic>`/`Object?` cast)|paths=constants/enums/generated(¬magic strings)|centralized auth guards/redirects|Android+iOS deep links|deep links validated+sanitized|testable nav|back valid ∀platforms
}

§CHK:ERR{
  fw:`FlutterError.onError`(build/layout/paint)|`PlatformDispatcher.instance.onError`(uncaught async)|`ErrorWidget.builder`∈release|global `runApp` wrapper(`runZonedGuarded`,Sentry/Crashlytics);
  report:Crashlytics/Sentry|non-fatal+stacks|state observer(`BlocObserver`,`ProviderObserver`)|user ID attached;
  graceful:API err→user UI|retry transient net|offline handled|error state carries info|map raw exceptions→localized user msgs(¬raw)
}

§CHK:L10N{
  setup:ARB/l10n,`easy_localization`|supported locales declared;
  content:¬hardcoded user strings|translator context/desc|ICU(plurals/genders/selects)|typed placeholders|¬missing keys across locales;
  review:consistent accessor|locale date/time/num/currency|RTL(Arabic,Hebrew)|¬string concat⇒parameterized
}

§CHK:DI{
  abstractions/interfaces at boundaries|external injection(ctor/DI/graph,¬internal)|lifetime(singleton/factory/lazySingleton)|env bindings(dev/staging/prod) via cfg(¬runtime `if`)|¬circular deps|¬scattered service locator∈logic
}

§CHK:ANALYSIS{
  `analysis_options.yaml`:`strict-casts:true`,`strict-inference:true`,`strict-raw-types:true`|lints(`very_good_analysis`,`flutter_lints`,custom)|monorepo inherits root;
  enforce:0 warnings|`// ignore:` justified|`flutter analyze` blocks CI merge;
  rules:`prefer_const_constructors`,`avoid_print`,`unawaited_futures`,`prefer_final_locals`,`always_declare_return_types`,`avoid_catches_without_on_clauses`,`always_use_package_imports`
}

§SRC{https://dart.dev/effective-dart/style|https://dart.dev/effective-dart/usage|https://dart.dev/effective-dart/design|https://docs.flutter.dev/perf/best-practices|https://docs.flutter.dev/testing/overview|https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility|https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization|https://docs.flutter.dev/ui/navigation|https://docs.flutter.dev/testing/errors|https://docs.flutter.dev/data-and-backend/state-mgmt/options}
