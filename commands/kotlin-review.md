---
description: "Comprehensive Kotlin code review (idioms, null/coroutine safety, security) via kotlin-reviewer"
---
@CMD:kotlin-review
§AGENT:kotlin-reviewer
§USE:post_edit_kt∨pre_commit∨PR_review∨onboarding∨idiom_check
§CHECKS{
`./gradlew build`
`./gradlew detekt`
`./gradlew ktlintCheck`
`./gradlew test`
}
§FLOW{
1:`git diff`(modified `.kt`/`.kts`)
2:run(§CHECKS)
3:scan(security,null_safety,coroutines,idioms)
4:categorize(CRITICAL|HIGH|MEDIUM)→§OUT
}
§SEV{
CRITICAL:{SQL|cmd_inj,unjustified_`!!`,platform_type_null_unsafe,`GlobalScope`,hardcoded_creds,unsafe_deser}
HIGH:{mutable_over_immutable,blocking_in_coroutine,missing_cancel_check_loop,non_exhaustive_`when`_sealed,fn>50L,nesting>4}
MEDIUM:{Java_style_non_idiomatic,missing_trailing_comma,scope_fn_misuse|nesting,missing_`Sequence`_large_chain,redundant_explicit_type}
}
§GATE{
`PASS: Approve`⇔CRITICAL=0∧HIGH=0
`WARNING: Warning`⇔CRITICAL=0∧HIGH=0∧MEDIUM>0
`FAIL: Block`⇔CRITICAL>0∨HIGH>0
}
§OUT{files_reviewed;static_analysis(build,detekt,ktlint);issues(`[SEV] Title`,File:path:line,Issue,Fix);summary(CRITICAL,HIGH,MEDIUM);recommendation(PASS|WARNING|FAIL)}
§REL:/kotlin-test,/kotlin-build,/code-review,`kotlin/SKILL.md`,`kotlin/references/kotlin-testing.md`
