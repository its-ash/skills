---
name: flutter
description: "AUTO_INVOKE(silent)⇔prompt∈{Flutter,Dart,Dart_3,.dart,pubspec.yaml,Widget,Riverpod,Bloc,Cubit,Equatable,Provider,GetX,GetIt,GoRouter,Freezed,json_serializable,Drift,hive_ce,Hive,ObjectBox,Dio,Ferry,graphql_codegen,SliverList,SliverGrid,flutter_secure_storage,flutter_test,Patrol,Impeller,Skwasm,dart2wasm,Wasm,FFIgen,JNIgen,Build_Hooks,Widget_Preview,Shorebird,Pub_Workspaces,material_ui,cupertino_ui,PopScope,Semantics,platform_channel,isolate,Firebase,iOS,Android,web,desktop,flavors}|SUB:{dart-flutter-patterns,flutter-code-review,project-workflow}"
---
@SKL:flutter
§R{
  target:Flutter_3.50+,Dart_3.14+(null_safety,records,patterns,sealed,dot_shorthands,primary_ctors)@(mobile,web,desktop,embedded);
  arch:feature_first(features/,core/)∧official_MVVM(UI:View+ViewModel,Data:Repo+Service)⊕Clean_Arch;
  widgets:immutable⇒const;extract(small_widget_classes)∧¬_build*_methods;prefer(material_ui|cupertino_ui_pkgs,@Preview);
  render:Impeller(iOS,Android_10+,macOS);Web⇒dart2wasm+Skwasm⊕CanvasKit(¬HTML_renderer_removed);
  APIs:Color.withValues()¬withOpacity;PopScope¬WillPopScope;WidgetStateProperty¬MaterialStateProperty;dart:js_interop¬dart:html/dart:js;
  ¬heavy_CPU@main_isolate⇒Isolate.run()⊕worker_Isolate;
  large_scrollable⇒SliverList|SliverGrid|ListView.builder;
  ∀interactive_widget⇒Semantics_labels∧contrast≥4.5:1∧tap≥48px∧focus_order∧SafeArea(edge-to-edge);
  secrets⇒flutter_secure_storage(v10+Android_DataStore/AES-GCM,iOS_Keychain,¬EncryptedSharedPreferences)∧¬hardcode_keys;
  immutable_models⇒Freezed_3(abstract_data|sealed_union)+json_serializable⊕Dart_primary_ctors/sealed;
  native_interop:direct(FFIgen(C/ObjC),JNIgen(Java/Kotlin),Build_Hooks)≻Pigeon≻MethodChannel;
  platform:iOS(SPM_default¬CocoaPods,UIScene_lifecycle,iOS_15+);Android(16KB_page_aligned_NDK,edge-to-edge_API_35+);
  monorepo⇒Dart_Pub_Workspaces(workspace:+resolution:workspace)∧shared_root_analysis_options;
  test@∀target_platform(unit,widget,golden,Patrol_native_E2E;note:web_lacks_some_plugins);
  flavors(dev,staging,prod)⇒--flavor+--dart-define-from-file∧separate_cfg_files;
  Δtheme⇒shared_theme_repo_flow∈root_convs;
}
§D{
  simple_UI,ephemeral|few_states⇒ValueNotifier|ChangeNotifier|Riverpod_3_Notifier ¬legacy_StateProvider|Bloc_boilerplate;
  complex_events,strict_FSM⇒Bloc_9|Cubit+sealed_states|Equatable ¬setState_chains|BlocOverrides;
  quick_prototype⇒GetX ¬GetX∈large_long_lived_apps;
  large_codebase,strict_layers⇒MVVM|Clean_Arch+Riverpod_3(@riverpod)|Bloc_9+GetIt ¬global_singletons;
  heavy_bg_work⇒Isolate.run()|worker_Isolate ¬async@main_isolate;
  web_perf,bundle_size⇒dart2wasm+Skwasm+deferred_loading+dart:js_interop ¬HTML_renderer|dart:html|unused_assets;
  native_APIs(BLE,camera,C/ObjC/Kotlin)⇒FFIgen|JNIgen+Build_Hooks|Pigeon|plugin ¬untyped_MethodChannel|pure_Dart_hacks;
  high_sec(keys,pinning)⇒flutter_secure_storage(DataStore/Keychain)∧Dio_cert_pinning ¬SharedPreferences|EncryptedSharedPreferences;
  local_DB⇒Drift(SQL,reactive)⊕hive_ce|ObjectBox(NoSQL) ¬unmaintained_hive|raw_SQL_strings;
  network⇒Dio(REST)⊕Ferry|graphql_codegen(GraphQL) ¬ad_hoc_http_no_interceptors;
  routing,bottom_tabs⇒go_router+go_router_builder(@TypedGoRoute)+StatefulShellRoute.indexedStack ¬string_paths|mixed_Navigator;
  OTA_hotfix⇒Shorebird ¬store_wait;native_E2E(perms,webviews)⇒Patrol ¬integration_test_alone;
  SDK_upgrade⇒dart_migrate+dart_fix;custom_lints⇒analysis_server_plugin ¬legacy_analyzer_plugin;
}
§REF{
  workflow,CLI,Pub_Workspaces,flavors,Shorebird_OTA,SPM/UIScene,16KB_NDK,release_checklist→references/project-workflow.md;
  Dart_3.14(primary_ctors,dot_shorthands),MVVM,Freezed_3,Riverpod_3,Bloc_9,GoRouter_typed,Dio,secure_storage_v10,FFIgen/JNIgen/Hooks,Wasm,tests→references/dart-flutter-patterns.md;
  review_checklist(health,Dart,widgets,state,perf,testing,a11y,platform,sec,pkgs,routing,l10n,DI,analysis_server_plugin)→references/flutter-code-review.md;
}
§REL{
  ../design/references/mobile-design.md:mobile_first_UI,touch_targets;
  ../backend-development/references/firebase-backend.md:Firebase_auth,Firestore,functions;
  ../swift-ios/SKILL.md:native_iOS,SPM,UIScene,FFIgen_ObjC;
  ../kotlin/SKILL.md:native_Android,JNIgen_Kotlin,16KB_NDK,edge_to_edge;
  ../unit-testing-patterns/SKILL.md:unit_test_patterns,fakes,mocks;
}
