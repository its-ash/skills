---
description: "Enforce Kotlin TDD (Kotest/MockK/Kover): tests first, RED→GREEN→REFACTOR, ≥80% coverage"
---
@CMD:kotlin-test
§AGENT:tdd-guide
§USE:new_fn|class,add_coverage,bug_fix(test_1st),critical_biz_logic
§FLOW{
1:TYPES→scaffold_interfaces|signatures(`TODO("not implemented")`)
2:RED→write_Kotest_specs
3:VERIFY_FAIL→`./gradlew test`(confirm expected fail e.g.`NotImplementedError`)
4:GREEN→minimal_impl→`./gradlew test`(PASS)
5:REFACTOR→improve_code(tests_stay_green)
6:COVERAGE→Kover≥targets→REPEAT
}
§PATTERNS{
`StringSpec({"name"{a shouldBe b}})`
`BehaviorSpec({Given(..){When(..){Then(..){}}}})`
data_driven:`FunSpec({context(..){withData(..){...}}})`
coroutine:`FunSpec({test(..){runTest{...}}})`
matchers:`shouldBe`,`shouldBeInstanceOf<T>()`,`shouldNotBeNull()`,`shouldNotBeEmpty()`
mock:MockK `coEvery`/`coVerify`(`suspend`)
}
§CMDS{
`./gradlew test`
`./gradlew test --tests "com.example.UserServiceTest"`
`./gradlew test --info`
`./gradlew koverHtmlReport` (`build/reports/kover/html/index.html`)
`./gradlew koverVerify`
`./gradlew koverXmlReport`
}
§TARGETS{critical_biz:100%,public_API:≥90%,general:≥80%,generated:exclude}
§R{
DO:{test_1st,run_after_Δ,Kotest_matchers,MockK_coEvery/coVerify,test_behavior¬impl,edge_cases(empty,null,max)}
¬DO:{impl_before_tests,skip_RED,test_private_fns,`Thread.sleep()`_in_coroutine_tests,ignore_flaky}
}
§REL:/kotlin-build,/kotlin-review,`kotlin/references/kotlin-testing.md`,`unit-testing-patterns/references/test-driven-development.md`
