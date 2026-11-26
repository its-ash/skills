@REF:cpp-testing

§R{
  stack:C++17/20+GoogleTest/GoogleMock+CMake/CTest+coverage+sanitizers+fuzzing;
  use:write/fix_tests|unit/int_coverage|CI_gating|CMake/CTest|flaky/failure_debug|sanitizers;
  ¬use:prod_feats_no_tests|unrelated_refactors|perf_no_regression|non_C++;
  core:TDD(RED→GREEN→REFACTOR);isolation(DI+fakes>globals);layout(`tests/unit`,`tests/integration`,`tests/testdata`);mock(interactions)⊕fake(stateful);`gtest_discover_tests()`;CI:subset→full(`--output-on-failure`)
}

§PAT:GTest_GMock{
  unit:`TEST(Suite,Case){EXPECT_EQ(Add(2,3),5);}`;
  fixture:`class T:public ::testing::Test{protected:void SetUp()override{...}}; TEST_F(T,Case){ASSERT_TRUE(...);EXPECT_EQ(...);}`;
  mock:`MOCK_METHOD(void,Send,(const std::string&),(override));` + `EXPECT_CALL(notifier,Send("hello")).Times(1);`;
  assertions:`ASSERT_*`(preconditions/fatal)⊕`EXPECT_*`(non_fatal_multi_check)
}

§CFG:CMake{
```cmake
cmake_minimum_required(VERSION 3.20)
project(example LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
include(FetchContent)
set(GTEST_VERSION v1.17.0)
FetchContent_Declare(googletest URL https://github.com/google/googletest/archive/refs/tags/${GTEST_VERSION}.zip)
FetchContent_MakeAvailable(googletest)
add_executable(example_tests tests/calculator_test.cpp src/calculator.cpp)
target_link_libraries(example_tests GTest::gtest GTest::gmock GTest::gtest_main)
enable_testing()
include(GoogleTest)
gtest_discover_tests(example_tests)
```
  coverage(target_level>global):
    GNU:`target_compile_options(... PRIVATE --coverage)`+`target_link_options(... PRIVATE --coverage)`;
    Clang:`-fprofile-instr-generate -fcoverage-mapping`(compile)+`-fprofile-instr-generate`(link);
  sanitizers:
    ENABLE_ASAN:`-fsanitize=address -fno-omit-frame-pointer`+link`-fsanitize=address`;
    ENABLE_UBSAN:`-fsanitize=undefined -fno-omit-frame-pointer`+link`-fsanitize=undefined`;
    ENABLE_TSAN:`-fsanitize=thread`
}

§CMD{
  build_test:`cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build -j && ctest --test-dir build --output-on-failure`;
  filter:`ctest --test-dir build -R ClampTest` | `ctest --test-dir build -R "UserStoreTest.*" --output-on-failure` | `./build/example_tests --gtest_filter=ClampTest.*` | `--gtest_filter=UserStoreTest.FindsExistingUser`;
  cov_gcc:`cmake -S . -B build-cov -DENABLE_COVERAGE=ON && cmake --build build-cov -j && ctest --test-dir build-cov && lcov --capture --directory build-cov --output-file coverage.info && lcov --remove coverage.info '/usr/*' --output-file coverage.info && genhtml coverage.info --output-directory coverage`;
  cov_clang:`cmake -S . -B build-llvm -DENABLE_COVERAGE=ON -DCMAKE_CXX_COMPILER=clang++ && cmake --build build-llvm -j && LLVM_PROFILE_FILE="build-llvm/default.profraw" ctest --test-dir build-llvm && llvm-profdata merge -sparse build-llvm/default.profraw -o build-llvm/default.profdata && llvm-cov report build-llvm/example_tests -instr-profile=build-llvm/default.profdata`;
  debug_loop:1:gtest_filter_single→2:scoped_logging→3:re_run_sanitizers→4:full_suite
}

§ANTI{
  sleep_sync⇒CV/latch+bounded_wait;
  fixed_tmp_paths⇒unique_tmp_per_test+cleanup;
  wall_clock/network/FS_in_unit⇒inject_clock/fakes;
  hidden_global_state⇒reset_in_fixture∨remove;
  over_mock_values⇒fakes_for_state;
  brittle_log_match⇒assert_behavior;
  missing_CI_sanitizers⇒ASan+UBSan+TSan_in_CI;
  cov_flag_mismatch⇒consistent_target_flags;
  non_deterministic_rng⇒deterministic_seeds
}

§REF:Optional_And_Alt{
  fuzz(if_supported):libFuzzer(pure_fns,min_IO):`extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)`;RapidCheck(property_invariants);
  alt:{Catch2:header_only+expressive_matchers,doctest:lightweight+min_compile}
}
