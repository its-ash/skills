---
description: "Fix Dart/Flutter analyzer & build errors incrementally via dart-build-resolver"
---
@CMD:flutter-build
@AGENT:dart-build-resolver
§WHEN{flutter_analyze_err ∨ flutter_build_fail ∨ pub_get_conflict ∨ build_runner_fail ∨ post_pull_break}
§FLOW{1:diag(flutter analyze,flutter pub get) → 2:parse(group_by_file,sort_by_sev) → 3:fix_1_at_a_time → 4:reanalyze_after_each_Δ → 5:verify(flutter test) → 6:emit(§OUT)}
§CMD_RUN{
analyze: "flutter analyze 2>&1"
deps: "flutter pub get 2>&1"
codegen(if_build_runner): "dart run build_runner build --delete-conflicting-outputs 2>&1"
build: "flutter build apk 2>&1" ; "flutter build web 2>&1"
test: "flutter test"
}
§STRAT{order:[1:analysis_errs,2:runtime_risk_warns,3:pub_conflicts] ∧ 1_fix/step ∧ verify_each ∧ minimal_surgical_Δ(¬refactor)}
§FIX_MAP{
'X?'→'X' ⇒ ?? default ∨ null_guard
undef('X') ⇒ add_import ∨ fix_typo
uninit_non_null_field ⇒ init ∨ late
version_solve_fail ⇒ adjust_pubspec_constraints
missing_concrete_impl ⇒ impl_iface_method
build_runner_part_expected ⇒ rm_stale('.g.dart') → rebuild
immutable_state_list_add ⇒ Cubit.addItem()¬Bloc.add(event)
}
§GATE:STOP{same_err≥3_tries ∨ fix_adds_errs ∨ needs_arch_Δ ∨ pkg_upgrade_needs_user}
§OUT{metrics:{errs_fixed,files_modified,remaining_issues}, status:PASS|BLOCKED}
§REL{cmd:{/flutter-test,/flutter-review}, agent:dart-build-resolver, skill:flutter/SKILL.md}
