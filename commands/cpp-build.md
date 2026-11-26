---
description: "Fix C++ build/CMake/linker errors incrementally via cpp-build-resolver agent with minimal diffs."
---
@CMD:cpp-build
§META{agent:cpp-build-resolver,skill:`cpp/SKILL.md`,rel:{`/cpp-test`,`/cpp-review`}}
§USE{`cmake --build build`_fail,linker_err(`undefined reference`|`multiple definition`),template_fail,include/dep_err,post_pull_break}
§FLOW{
  1:diag:```bash
cmake -B build -S .
cmake --build build 2>&1 | head -100
clang-tidy src/*.cpp -- -std=c++23
cppcheck --enable=all src/
```(static_if_avail);
  2:parse→group(file)→sort(1:compile→2:linker→3:warnings(`-Wall -Wextra`));
  3:fix_loop(1_at_a_time,minimal_Δ,¬refactor)→verify_each(`cmake --build build`);
  4:verify_tests:`ctest --test-dir build --output-on-failure`
}
§MAP{
  `undeclared identifier`⇒add `#include`⊕fix_typo;
  `no matching function`⇒fix_arg_types⊕add_overload;
  `undefined reference`⇒link_lib⊕add_impl;
  `multiple definition`⇒use `inline`⊕move_to `.cpp`;
  `incomplete type`⇒replace_fwd_decl_w/`#include`;
  `no member named X`⇒fix_member_name⊕`#include`;
  `cannot convert X to Y`⇒add_cast;
  `CMake Error`⇒fix `CMakeLists.txt`
}
§GATE{
  STOP∧report⇔(same_err>3_attempts)∨(new_errors>0)∨(needs_arch_Δ)∨(missing_ext_deps)
}
§OUT{
  summary:{build_errors_fixed,linker_errors_fixed,files_modified,remaining_issues,`Build Status: PASS: SUCCESS`⊕FAIL}
}
