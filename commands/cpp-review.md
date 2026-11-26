---
description: "Review C++ code for memory safety, modern C++ idioms, concurrency, and security via cpp-reviewer agent."
---
@CMD:cpp-review
§META{agent:cpp-reviewer,skills:{`cpp/SKILL.md`,`cpp/references/cpp-testing.md`},flow_rel:`/cpp-test`→`/cpp-build`→`/cpp-review`→`/code-review`(non-C++)}
§FLOW{
  1:identify_Δ(`git diff`:`.cpp`,`.hpp`,`.cc`,`.h`);
  2:analyze:```bash
clang-tidy --checks='*,-llvmlibc-*' src/*.cpp -- -std=c++23
cppcheck --enable=all --suppress=missingIncludeSystem src/
cmake -B build -DCMAKE_CXX_FLAGS="-Wall -Wextra -Wpedantic -fsanitize=address,undefined" && cmake --build build
```
  3:scan(mem_safety,concurrency,C++20/23_idioms,security);
  4:report_by_severity
}
§CHK{
  CRIT(MustFix):{raw `new`/`delete` w/o_RAII,buf_overflow/UAF,unsynced_data_race,cmd_inj(`system()`),uninit_read,null_deref};
  HIGH(ShouldFix):{Rule_of_5_violation,missing `std::lock_guard`/`std::scoped_lock`,detached_threads_w/o_lifetime,C_casts(use `static_cast`/`dynamic_cast`),missing `const`};
  MED(Consider):{unnecessary_copies(use `const&`),missing `reserve()`,header `using namespace std;`,missing `[[nodiscard]]`,overcomplex_TMP}
}
§GATE{
  0_CRIT∧0_HIGH⇒`PASS: Approve`;
  only_MED⇒`WARNING: Warning`(merge_w_caution);
  CRIT∨HIGH⇒`FAIL: Block`
}
§OUT{
  report:{`Files Reviewed`,`Static Analysis Results`(clang-tidy,cppcheck),`Issues Found`(`[<SEV>] <Title>`,File:`path:line`,Issue,Fix+snippet),`Summary`(CRIT/HIGH/MED counts),`Recommendation`}
}
