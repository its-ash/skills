---
description: "Run Flutter/Dart tests, diagnose failures, fix incrementally (unit|widget|golden|integration)"
---
@CMD:flutter-test
§WHEN{post-feature|post-/flutter-build|new-code-coverage|failing-test|pre-PR}
§FLOW{
  1:run(`flutter test` ⊕ scoped Δ files)
  2:parse_failures(type,cause)
  3:fix_incrementally(1_at_a_time)
  4:verify(re-run targeted test after ∀fix)
  5:final_run(`flutter test --coverage 2>&1`)→report(summary,remaining)
}
§CMD{
  all:`flutter test 2>&1`
  cov:`flutter test --coverage 2>&1` # target≥80%
  file:`flutter test test/unit/domain/usecases/get_user_test.dart 2>&1`
  name:`flutter test --name "CartBloc" 2>&1`
  int:`flutter test integration_test/ 2>&1` # req device/emulator
  gold:`flutter test --update-goldens 2>&1` # intentional visual Δ only
}
§FIX{
  `Expected: <X> Actual: <Y>`⇒upd assertion ⊕ fix impl
  `Widget not found`⇒fix finder selector ⊕ upd test copy
  `Golden file not found`⇒`flutter test --update-goldens`
  `Golden mismatch`⇒inspect diff;intentional⇒`--update-goldens`
  `MissingPluginException`⇒mock platform channel in setup
  `LateInitializationError`⇒init `late` fields in `setUp()`
  `pumpAndSettle timed out`⇒use explicit `pump(Duration)`
}
§OUT{
  per_fix:{file,failure,root_cause,fix,re-run_output}
  summary:{total,passed,failed,coverage%,status(PASS|FAIL)}
}
§REL{
  cmds:/flutter-build,/flutter-review
  agents:flutter-reviewer,dart-build-resolver
  refs:unit-testing-patterns/references/test-driven-development.md,flutter/SKILL.md
}
