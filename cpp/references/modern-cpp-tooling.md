@REF:modern-cpp-tooling

§R:Toolchain_Baseline{
  std:default=C++23(floor=C++20;exp=C++26_via`-std=c++26`);
  compilers(2026):GCC_16(16.2;default=gnu++20;GCC15+_ships_`libstdc++.modules.json`)|Clang/LLVM_23(23.1.6)|MSVC(VS2022_17.14+/preview);
  build:CMake_4.5+(4.5.1;CMake4_removed_compat_<3.5)+Ninja/Ninja_Multi-Config+`CMakePresets.json`+`CMAKE_EXPORT_COMPILE_COMMANDS=ON`+`CMAKE_CXX_EXTENSIONS=OFF`;
  deps:vcpkg_manifest(`vcpkg.json`)⊕Conan_2(`conanfile.py`);
  analysis:clangd(`compile_commands.json`+`.clangd`)+clang-tidy(`.clang-tidy`)+clang-format(`.clang-format`)
}

§PAT:Cpp23_Cpp26{
  expected(C++23,`<expected>`):recoverable_domain_err(parsing,IO,no_exc)+monadic(`.and_then`/`.transform`/`.or_else`)¬contract_bugs;
  print(C++23,`<print>`):`std::println("k={} v={:.2f}",k,v)`(compile_time_checked,buffered)>`printf`/`std::cout<<`;
  span(C++20,`<span>`):non_owning_contiguous_view;pass_by_val(`std::span<const T>`)¬`(const T*,size_t)`;¬ret_span_to_local;
  jthread(C++20,`<thread>`):RAII_auto_join+coop_cancel(`std::stop_token`)¬raw_`std::thread`;
  Cpp26_finalizing(exp`-std=c++26`):
    contracts:`pre(...)`,`post(...)`,`contract_assert(...)`(standardized_pre/post_conditions);
    reflection(`std::meta`):reflect_`^^T`(`std::meta::info`)+splice_`[:...:]`(zero_macro_JSON/ORM/RPC/enum_to_str;GCC16/Clang`-freflection`);
    hardening(P3471):standardized_trapping_STL_preconditions;
    containers:`std::inplace_vector<T,N>`(fixed_cap_inline_dynamic_vec,embedded/low_latency);
    async:`std::execution`(senders/receivers);
    core:`#embed`(binary_inclusion)|pack_index(`Pack...[0]`)|placeholder(`_`)|`=delete("reason")`|saturation_arith(`std::add_sat`)|`constexpr`_exc/placement_new|`std::text_encoding`
}

§PAT:STL_Hardening{
  prod_rule:enable_fast_bounds_checks_always(~0.3%_overhead;traps_OOB/empty_optional/span_UB);
  libc++(Clang):prod=`-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST`;CI/dev=`_EXTENSIVE`|`_DEBUG`;
  libstdc++(GCC):`-D_GLIBCXX_ASSERTIONS`(explicitly_keep_under`-O2`/`-O3`)∨`-fhardened`;
  MSVC_STL:`/D_MSVC_STL_HARDENING=1`(traps_via_`__fastfail()`)+`/D_MSVC_STL_DESTRUCTOR_TOMBSTONES=1`(UAF_mitigation);
  warnings:GCC/Clang=`-Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wnon-virtual-dtor`;MSVC=`/W4 /permissive-`
}

§CFG:CMake_Modules{
  CMake4.5_import_std:GA_for_C++20+_w/_`CXX_SCAN_FOR_MODULES`_ON+Ninja_generator(no_legacy_UUID_experimental_flags);custom_stdlib_path=`CMAKE_CXX_STDLIB_MODULES_JSON`;
  rule:¬mix_`#include <stl>`∧`import std;`_in_same_TU(ODR/macro_risk);isolate_build_dirs_per_compiler(`${sourceDir}/build/${presetName}`);
```cmake
cmake_minimum_required(VERSION 4.5)
project(app LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
add_executable(app)
target_sources(app PRIVATE main.cpp PRIVATE FILE_SET cxx_modules TYPE CXX_MODULES FILES math.ixx)
```
```json
{
  "version": 6,
  "cmakeMinimumRequired": { "major": 4, "minor": 5, "patch": 0 },
  "configurePresets": [
    {
      "name": "base", "hidden": true, "generator": "Ninja",
      "binaryDir": "${sourceDir}/build/${presetName}",
      "cacheVariables": {
        "CMAKE_CXX_STANDARD": "23", "CMAKE_CXX_STANDARD_REQUIRED": "ON",
        "CMAKE_CXX_EXTENSIONS": "OFF", "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"
      }
    },
    {
      "name": "dev-vcpkg", "inherits": "base",
      "cacheVariables": { "CMAKE_TOOLCHAIN_FILE": "$env{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" }
    }
  ],
  "buildPresets": [{ "name": "dev-vcpkg", "configurePreset": "dev-vcpkg" }]
}
```
}

§CFG:Deps{
  vcpkg_manifest(source_driven/MS_friendly):commit_`vcpkg.json`(deps+`"builtin-baseline"`_pinned_commit)+`$env{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake`_in_preset;
  Conan2(enterprise/binary_cache):`conanfile.py`(`generators="CMakeDeps","CMakeToolchain"`, `cmake_layout(self)`, profile_`compiler.cppstd=23`);cmd:`conan install . --output-folder=build --build=missing`
}

§CFG:StaticAnalysis_IDE{
  clangd:enable_`CMAKE_EXPORT_COMPILE_COMMANDS=ON`+symlink/point_`compile_commands.json`@repo_root;`.clangd`:`CompileFlags:{Add:[-Wall,-Wextra,-Wpedantic]}`+`Diagnostics:{ClangTidy:{Add:[bugprone-*,modernize-*,performance-*]}}`;
  clang_tidy:`.clang-tidy`(`Checks: -*,bugprone-*,cppcoreguidelines-*,modernize-*,performance-*,readability-*`);wire_via_CI_preset:`-DCMAKE_CXX_CLANG_TIDY="clang-tidy;--config-file=${sourceDir}/.clang-tidy"`;
  clang_format:commit_`.clang-format`+enforce_in_CI(`--dry-run --Werror`)
}

§ANTI{
  raw_cmake_CLI_flags⇒CMakePresets.json;
  cmake_min_below_3_5⇒3.28+_or_4.5+(CMake4_removed_<3.5);
  mix_import_std_and_#include_same_TU⇒one_style_per_TU;
  prod_no_STL_hardening⇒FAST/_GLIBCXX_ASSERTIONS/_MSVC_STL_HARDENING=1;
  expected_for_contract_bugs⇒assert/hardening/C++26_contracts;
  raw_std_thread⇒std::jthread+std::stop_token;
  raw_ptr_plus_len⇒std::span;
  unpinned_deps_or_Conan1⇒vcpkg_builtin_baseline|Conan2_profiles
}
