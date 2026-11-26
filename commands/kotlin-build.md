---
description: "Fix Kotlin/Gradle build errors, warnings, and deps incrementally via kotlin-build-resolver"
---
@CMD:kotlin-build
§AGENT:kotlin-build-resolver
§USE:build_fail∨kotlinc_err∨detekt_fail∨dep_err∨post_pull_break
§DIAG{
`./gradlew build 2>&1`
`./gradlew detekt 2>&1 || echo "detekt not configured"`
`./gradlew ktlintCheck 2>&1 || echo "ktlint not configured"`
`./gradlew dependencies --configuration runtimeClasspath 2>&1 | head -100`
`./gradlew build --refresh-dependencies` (stale_cache|metadata)
}
§FLOW{
1:run(§DIAG)→parse∧group_by_file∧sort_severity
2:order:build_errs→detekt→ktlint
3:fix_1_at_a_time(minimal_Δ,¬refactor)→verify(`./gradlew build`)
4:final_verify:`./gradlew build`∧`./gradlew detekt`∧`./gradlew test`
5:report→§OUT
}
§FIX_MAP{
`Unresolved reference: X`→add_import|dep
`Type mismatch`→fix_conv|assign
`'when' must be exhaustive`→add_sealed_branches
`Suspend function can only be called from coroutine`→add_`suspend`
`Smart cast impossible`→local_`val`|`let`
`None of the following candidates is applicable`→fix_arg_types
`Could not resolve dependency`→fix_version|add_repo
}
§GATE{
stop_if:same_err≥3_attempts∨fix_adds_errs∨needs_arch_Δ∨missing_ext_deps
}
§OUT{diagnostics;per_fix(file:line,err,cause,Δ);summary{build_errs_fixed,detekt_fixed,files_modified,remaining,`Build Status: PASS: SUCCESS`}}
§REL:/kotlin-test,/kotlin-review,`kotlin/SKILL.md`
