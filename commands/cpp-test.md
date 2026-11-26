---
description: "Enforce C++ TDD workflow: GoogleTest first, minimal impl, verify gcov/lcov coverage"
---
@CMD:cpp-test
§WHEN{new_fn_or_class ∨ add_cov ∨ bugfix(failing_test_first) ∨ critical_logic ∨ cpp_tdd}
§FLOW{1:define_iface(hdr,sigs) → 2:write_gtest(RED) → 3:run_fail(verify_right_reason) → 4:impl_min(GREEN) → 5:run_pass → 6:refactor(keep_green) → 7:check_cov(≥80%) → repeat(next_case)}
§CMD_RUN{
test: "cmake --build build && ctest --test-dir build --output-on-failure"
cov_cfg: "cmake -DCMAKE_CXX_FLAGS=\"--coverage\" -DCMAKE_EXE_LINKER_FLAGS=\"--coverage\" -B build"
cov_run: "cmake --build build && ctest --test-dir build"
cov_rpt: "lcov --capture --directory build --output-file coverage.info && lcov --remove coverage.info '/usr/*' --output-file coverage.info && lcov --list coverage.info && genhtml coverage.info --output-directory coverage_html"
}
§TPL{
basic: TEST(SuiteName,TestName){EXPECT_EQ/NE/TRUE/THROW(...);}
fixture: class S:public ::testing::Test{protected:void SetUp()override;void TearDown()override;}; TEST_F(S,Name){...}
param: class S:public ::testing::TestWithParam<T>{}; TEST_P(S,Name){auto [in,exp]=GetParam();...} INSTANTIATE_TEST_SUITE_P(Inst,S,::testing::Values(...));
}
§COV{critical_logic:100%, public_api:≥90%, general:≥80%, generated:exclude}
§R{
DO: test_first(before_impl) ∧ run_after_each_Δ ∧ prefer(EXPECT_*,ASSERT_*) ∧ test(behavior¬impl) ∧ edge_cases(empty,null,max,bounds)
¬DO: impl_before_test ∨ skip_RED ∨ test_private_direct(via_public_api) ∨ sleep_in_test ∨ ignore_flaky
}
§REL{cmd:{/cpp-build,/cpp-review}, agent:tdd-guide, skill:{cpp/references/cpp-testing.md,unit-testing-patterns/references/test-driven-development.md}}
