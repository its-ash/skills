---
description: "Review Flutter/Dart idioms, widgets, state, perf, a11y, security via flutter-reviewer"
---
@CMD:flutter-review
@AGENT:flutter-reviewer
§GATE:PRE{build_pass(/flutter-build) ∧ tests_pass(/flutter-test) ∧ ¬merge_conflicts ∧ flutter_analyze_clean}
§WHEN{pre_PR(post_build_test) ∨ post_feature ∨ peer_review ∨ audit(widget,state,service) ∨ pre_release}
§FLOW{1:diff(git diff --staged, git diff) → 2:inspect(pubspec.yaml,analysis_options.yaml,state_mgmt,arch) → 3:sec_prescan(secrets,cleartext_http) → 4:audit(§AREAS) → 5:emit(§OUT)}
§AREAS{
CRITICAL:{hardcoded_secrets,cleartext_http,arch_violations,state_mgmt_antipatterns}
HIGH:{widget_rebuilds,resource_leaks,missing_dispose,BuildContext_after_await(¬mounted),null_safety,missing_err_loading_states(AsyncValue.error),const_prop,widget_comp,expensive_work_in_build,missing_state_transition_tests}
MEDIUM:{a11y_semantics,hardcoded_strings_l10n}
LOW:{pub_dep_hygiene}
}
§OUT{
ctx:{changed_files,state_mgmt,arch}
sec_prescan:{secrets,cleartext_http}
finding_fmt: "[SEVERITY] <title>\nFile: <path>:<line>\nIssue: <what>\nFix: <concrete_Δ>"
summary:{CRITICAL,HIGH,MEDIUM,LOW counts+status(pass|block|info|note)}
verdict: (CRITICAL=0 ∧ HIGH=0) ⇒ APPROVE | else ⇒ BLOCK(fix_before_merge)
}
§REL{cmd:{/flutter-build,/flutter-test,/code-review}, agent:flutter-reviewer, skill:flutter/SKILL.md}
