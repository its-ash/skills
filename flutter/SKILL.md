---
name: flutter
description: "AUTO_INVOKE(silent)⇔prompt∈{Flutter,Dart,Dart_3,.dart,pubspec.yaml,Widget,Riverpod,Bloc,Cubit,Equatable,Provider,GetX,GetIt,GoRouter,Freezed,json_serializable,Drift,Hive,ObjectBox,Dio,Ferry,Artemis,SliverList,SliverGrid,flutter_secure_storage,flutter_test,Impeller,dart2js,Semantics,platform_channel,compute,isolate,Firebase,iOS,Android,web,desktop,flavors}|SUB:{dart-flutter-patterns,flutter-code-review}"
---
@SKL:flutter
§R{
  target:latest_stable(Flutter_3.x,Dart_3(full_null_safety,records,patterns,sealed_classes))@(mobile,web,desktop,embedded);
  arch:clean_arch(features/,core/);
  widgets:immutable⇒const;extract(small_widget_classes)∧¬helper_methods;
  ¬heavy_CPU@main_isolate;use(compute⊕isolates);
  large_scrollable⇒SliverList⊕SliverGrid;
  ∀interactive_widget⇒Semantics_labels∧contrast∧focus_order;
  secrets⇒flutter_secure_storage⊕native_keychain∧¬hardcode_API_keys;
  immutable_models⇒freezed+json_serializable;
  test@∀target_platform(note:web_can_lack_plugins);
  flavors(dev,staging,prod)⇒separate_cfg_files;
  Δtheme⇒shared_theme_repo_flow∈root_convs;
}
§D{
  simple_UI,few_shared_states⇒Provider⊕Riverpod_StateProvider ¬Bloc_boilerplate;
  complex_logic,many_events⇒Bloc|Cubit+Equatable ¬setState_chains;
  quick_prototype,reactive_DI⇒GetX ¬GetX∈large_long_lived_apps;
  large_codebase,strict_layers⇒Clean_Arch+Riverpod+GetIt ¬global_singletons;
  heavy_bg_work⇒isolates+compute ¬async@main_isolate;
  web_strict_bundle_size⇒Impeller∧tree_shaking∧dart2js_opt ¬unused_assets;
  native_sensors(BLE,camera)⇒platform_channel+native_plugin ¬pure_Dart_workarounds;
  high_sec(keys,pinning)⇒flutter_secure_storage∧dio_interceptor_cert_pinning ¬SharedPreferences_for_secrets;
  local_DB⇒Drift(SQL)⊕Hive|ObjectBox(NoSQL) ¬raw_SQL_strings;
  network⇒Dio(REST)⊕Ferry|Artemis(GraphQL) ¬ad_hoc_http_no_interceptors;
}
§REF{
  workflow,patterns,pitfalls_tbl,release_checklist(CI/CD,signing,OTA)→references/project-workflow.md;
  Dart3_null_safety,sealed|Freezed_state,async_mounted,scoped_rebuilds,BLoC|Cubit,Riverpod_notifiers,GoRouter_auth_redirect,Dio_interceptors,global_err_capture,tests→references/dart-flutter-patterns.md;
  review_checklist(health,Dart_pitfalls,widgets,state,perf,testing,a11y,sec,pkgs,routing,l10n,DI,static_analysis)→references/flutter-code-review.md;
}
§REL{
  ../design/references/mobile-design.md:mobile_first_UI,touch_targets;
  ../backend-development/references/firebase-backend.md:Firebase_auth,Firestore,functions;
  ../swift-ios/SKILL.md:native_iOS,platform_channels;
  ../unit-testing-patterns/SKILL.md:unit_test_patterns,mocks;
}
