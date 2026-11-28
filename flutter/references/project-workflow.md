@REF:project-workflow
§FLOW{
  1.clarify(targets:iOS/Android/web/desktop/embedded,fps/mem,offline_sync,sec,OTA);
  2.arch:feature_first(`lib/features/`,`lib/core/`)+official_MVVM(UI:View+VM,Data:Repo+Service)⊕Clean_Arch;
  3.state:simplest(../SKILL.md §D⇒ValueNotifier|Riverpod_3_Notifier|Bloc_9);
  4.data:`Drift`(SQLite,reactive)|`hive_ce`∨`ObjectBox`(NoSQL)|`Dio`(REST)|`Ferry`∨`graphql_codegen`(GraphQL);
  5.UI:`const`,standalone `material_ui`∨`cupertino_ui`,dot_shorthands,`LayoutBuilder`,`MediaQuery.sizeOf/paddingOf`,`SafeArea`,`PopScope`,`Color.withValues()`,`Semantics`,Widget_Previews(`@Preview`);
  6.native:Direct Native Interop(`ffigen` C/ObjC + `jnigen` Java/Kotlin + Build/Link Hooks `hook/build.dart`,`hook/link.dart`)≻`Pigeon`≻`MethodChannel`;
  7.perf:`const`,keys,scoped(`select`/`BlocSelector`),`SliverList`/`SliverGrid`,`Isolate.run()`,Impeller(iOS/Android_10+/macOS),Wasm/Skwasm(web),DevTools(CPU/mem/GPU);
  8.test:fakes+`mocktail`,`flutter_test`+goldens,`Patrol`(native OS E2E)∨`integration_test`,CI_matrix;
  9.CI:GitHub_Actions/Codemagic(format,analyze,test,flavors,Wasm_build,artifacts);
  10.rel:`--flavor`(dev/staging/prod)+`--dart-define-from-file`,obfuscate+symbols,sign(iOS_SPM/UIScene,Android_16KB_NDK,desktop),beta(TestFlight/Firebase_App_Distribution),OTA(`Shorebird` Dart patches)
}

§CMD{
  quality:`dart format --output=none --set-exit-if-changed . && flutter analyze && flutter test --coverage`;
  upgrade:`dart migrate && dart fix --apply && flutter pub outdated`;
  preview:`flutter widget-preview start`;
  web_wasm:`flutter build web --wasm --release`(opt `--enable-wasm-deferred-loading`);
  release_android:`flutter build appbundle --release --flavor prod --dart-define-from-file=config/prod.json --obfuscate --split-debug-info=build/symbols/android`;
  release_ios:`flutter build ipa --release --flavor prod --dart-define-from-file=config/prod.json --obfuscate --split-debug-info=build/symbols/ios`;
  ota_patch:`shorebird release android|ios --flavor prod`→hotfix:`shorebird patch android|ios --flavor prod`;
  native_e2e:`patrol test -t integration_test/app_test.dart`
}

§CFG{
  monorepo:Pub_Workspaces(root `pubspec.yaml`→`workspace:[apps/app,packages/core]`;members→`resolution: workspace`;single `pubspec.lock`;`melos` opt for scripts/versioning);
  analysis:root `analysis_options.yaml` w/ `strict-casts`,`strict-inference`,`strict-raw-types`+`very_good_analysis`/`flutter_lints`+`plugins:`(`analysis_server_plugin`);
  iOS:Swift Package Manager(SPM) default(¬CocoaPods);`UIScene` lifecycle(`UIWindowSceneDelegate`);min iOS_15+/macOS_12+;
  Android:16KB page-aligned NDK libs(AGP+modern NDK);edge-to-edge default(API_35+⇒`SafeArea`/`MediaQuery.paddingOf`);
  secure_storage:`flutter_secure_storage` v10+ `AndroidOptions(dataStore:true)`(¬deprecated `EncryptedSharedPreferences`);
  codegen:`dart run build_runner build --delete-conflicting-outputs`(`freezed` 3,`json_serializable`,`riverpod_generator`,`go_router_builder`,`drift_dev`)
}

§PAT{
  widgets:compose(¬inherit)|keys:`ValueKey`(list),`GlobalKey`(rare)|DI:`GetIt`+`injectable`∨`ProviderScope`;
  err:global handlers→user_msg→Sentry/Crashlytics(upload `--split-debug-info` symbols);
  i18n:`flutter_localizations`+ARB(`l10n.yaml`)|img:`cached_network_image`+`cacheWidth`/`placeholder`;
  routing:`go_router`+`go_router_builder`(`@TypedGoRoute`)+`StatefulShellRoute.indexedStack`
}

§ANTI{
  root_`setState`⇒scoped_Notifier/Bloc|non-`const`⇒`const`|CPU_main⇒`Isolate.run()`|
  unmaintained_`hive`⇒`hive_ce`|`EncryptedSharedPreferences`⇒`AndroidOptions(dataStore:true)`|
  `--web-renderer html`/`dart:html`⇒`--wasm`(Skwasm)+`dart:js_interop`|
  CocoaPods_lockin⇒SPM|untyped_`MethodChannel`⇒`ffigen`/`jnigen`/`Pigeon`|
  hardcoded_keys⇒`--dart-define-from-file`+keychain/backend_proxy|
  bloat⇒tree-shake+deferred_Wasm+compress|1-plat_CI⇒matrix(iOS,Android,web,desktop)
}

§CHK:REL{
  ∀§FLOW(1..10)∧DevTools(0_leak/jank)∧goldens_pass∧Patrol_E2E_pass∧store_meta∧
  sec(DataStore/Keychain,cert_pin,obfuscate+symbols_uploaded)∧a11y(semantics,48dp,contrast,textScaler)∧
  platform(iOS_SPM+UIScene,Android_16KB_NDK+edge-to-edge)∧
  render(Impeller_mobile/macOS_verified,Web_Wasm/Skwasm_bundle_analyzed)∧Shorebird_release_tagged
}

§REL{../SKILL.md|dart-flutter-patterns.md|flutter-code-review.md}
