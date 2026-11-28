@REF:cpp-testing

§R{
  stack:C++20/23(min:C++17)+GoogleTest(v1.18.0)/GoogleMock+Catch2(v3.16.1)+FuzzTest/libFuzzer+CMake(3.28+/4.5)/CTest+coverage+sanitizers+STL_hardening;
  use:write/fix_tests|unit/int_coverage|CI_gating|CMake/CTest|flaky/failure_debug|sanitizers|fuzzing;
  ¬use:prod_feats_no_tests|unrelated_refactors|perf_no_regression|non_C++;
  core:TDD(RED→GREEN→REFACTOR);isolation(DI+fakes>globals);layout(`tests/unit`,`tests/integration`,`tests/testdata`);mock(interactions)⊕fake(stateful);`gtest_discover_tests()`/`catch_discover_tests()`;CI:subset→full(`--output-on-failure`+`--gtest_fail_if_no_test_linked`)
}

§PAT:GTest_GMock{
  unit:`TEST(Suite,Case){EXPECT_EQ(Add(2,3),5);}`;
  fixture:`class T:public ::testing::Test{protected:void SetUp()override{...}}; TEST_F(T,Case){ASSERT_TRUE(...);EXPECT_EQ(...);}`;
  matchers(prefer>raw_cmp):`EXPECT_THAT(val,AllOf(Ge(0),Le(10)));`+`EXPECT_THAT(vec,ElementsAre(1,2,3));`;
  mock:`MOCK_METHOD(void,Send,(std::string_view),(override));` + `EXPECT_CALL(notifier,Send("hello")).Times(1);`;
  assertions:`EXPECT_*`(default_non_fatal_multi_check)⊕`ASSERT_*`(fatal_preconditions_only);
  zero_test_guard:`--gtest_fail_if_no_test_linked`(v1.18+,prevents_silent_empty_CI_pass)
}

§CFG:CMake{
```cmake
cmake_minimum_required(VERSION 3.28) # use 4.5 for native `import std;`
project(example LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
# Prefer find_package(GTest CONFIG REQUIRED) with vcpkg/Conan2; FetchContent for standalone:
include(FetchContent)
set(GTEST_VERSION v1.18.0) # requires C++17+
FetchContent_Declare(googletest URL https://github.com/google/googletest/archive/refs/tags/${GTEST_VERSION}.zip)
FetchContent_MakeAvailable(googletest)
add_executable(example_tests tests/calculator_test.cpp src/calculator.cpp)
target_link_libraries(example_tests PRIVATE GTest::gtest GTest::gmock GTest::gtest_main)
enable_testing()
include(GoogleTest)
gtest_discover_tests(example_tests)
```
  coverage(target_level>global):
    GNU:`target_compile_options(... PRIVATE --coverage)`+`target_link_options(... PRIVATE --coverage)`;
    Clang:`-fprofile-instr-generate -fcoverage-mapping`(compile)+`-fprofile-instr-generate`(link);
  sanitizers(target_level;TSan_mutually_exclusive_w/_ASan):
    ASAN_UBSAN:`-fsanitize=address,undefined -fno-omit-frame-pointer`+link`-fsanitize=address,undefined`;
    TSAN:`-fsanitize=thread -fno-omit-frame-pointer`+link`-fsanitize=thread`;
    MSAN(Clang):`-fsanitize=memory -fno-omit-frame-pointer`;
  STL_hardening(test/CI):
    libc++:`-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_EXTENSIVE`(or`_DEBUG`);
    libstdc++:`-D_GLIBCXX_ASSERTIONS`;MSVC:`/D_MSVC_STL_HARDENING=1 /D_MSVC_STL_DESTRUCTOR_TOMBSTONES=1`
}

§CMD{
  presets:`cmake --preset dev-asan && cmake --build --preset dev-asan && ctest --preset dev-asan --output-on-failure`;
  direct:`cmake -G Ninja -S . -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build -j && ctest --test-dir build --output-on-failure`;
  filter:`ctest --test-dir build -R ClampTest` | `./build/example_tests --gtest_filter=ClampTest.* --gtest_fail_if_no_test_linked`;
  cov_gcc:`cmake -G Ninja -S . -B build-cov -DENABLE_COVERAGE=ON && cmake --build build-cov && ctest --test-dir build-cov && lcov --capture --directory build-cov --output-file coverage.info && lcov --remove coverage.info '/usr/*' --output-file coverage.info && genhtml coverage.info --output-directory coverage`;
  cov_clang:`cmake -G Ninja -S . -B build-llvm -DENABLE_COVERAGE=ON -DCMAKE_CXX_COMPILER=clang++ && cmake --build build-llvm && LLVM_PROFILE_FILE="build-llvm/default.profraw" ctest --test-dir build-llvm && llvm-profdata merge -sparse build-llvm/default.profraw -o build-llvm/default.profdata && llvm-cov report build-llvm/example_tests -instr-profile=build-llvm/default.profdata`;
  debug_loop:1:gtest_filter_single→2:scoped_logging→3:re_run_ASan+UBSan+TSan→4:full_suite
}

§ANTI{
  sleep_sync⇒CV/latch+bounded_wait;
  fixed_tmp_paths⇒unique_tmp_per_test+cleanup;
  wall_clock/network/FS_in_unit⇒inject_clock/fakes;
  hidden_global_state⇒reset_in_fixture∨remove;
  over_mock_values⇒fakes_for_state;
  brittle_log_match⇒assert_behavior;
  logic_in_test_body⇒declarative_tests+TEST_P;
  zero_tests_silent_pass⇒--gtest_fail_if_no_test_linked;
  missing_CI_sanitizers_or_hardening⇒ASan+UBSan+TSan+STL_hardening_in_CI;
  cov_flag_mismatch⇒consistent_target_flags;
  non_deterministic_rng⇒deterministic_seeds
}

§PAT:Fuzz_And_Alt{
  FuzzTest(Google,GTest_integrated;prefer_for_parsers/serializers/pure_fns):`FUZZ_TEST(Suite,Prop).WithDomains(fuzztest::Arbitrary<std::string>(),fuzztest::InRange(0,100));`;
  libFuzzer(LLVM):`-fsanitize=fuzzer,address,undefined`+`extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)`;
  Catch2(v3.16.1):compiled_static_lib(¬single_header;fast_builds;link_`Catch2::Catch2WithMain`;`catch_discover_tests`;`SECTION`>fixtures;BDD:`SCENARIO`/`GIVEN`/`WHEN`/`THEN`;`TEMPLATE_TEST_CASE`);
  doctest:lightweight_single_header+min_compile_overhead;
  RapidCheck:property_invariants(FuzzTest_preferred_for_coverage_guided_fuzzing)
}
