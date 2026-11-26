---
description: "Execute implementation plan sequentially with per-change validation and reporting"
argument-hint: <path/to/plan.md>
---

@CMD:prp-implement
§R: golden_rule: validate_after_every_Δ ∧ fix_before_next ∧ ¬accumulate_broken_state
§FLOW:
  0_DETECT:
    PM: `bun.lock`⇒`bun`(`bun run`)|`pnpm-lock.yaml`⇒`pnpm`(`pnpm run`)|`yarn.lock`⇒`yarn`(`yarn`)|`package-lock.json`⇒`npm`(`npm run`)|`pyproject.toml`(`requirements.txt`=legacy)⇒`uv`(`uv run`)|`Cargo.toml`⇒`cargo`(`cargo`)|`go.mod`⇒`go`(`go`)
    scripts: `cat package.json | grep -A 20 '"scripts"'`(or_equiv)→note(type-check,lint,test,build)
  1_LOAD:
    `cat "$ARGUMENTS"`→extract(Summary,Patterns to Mirror,Files to Change,Step-by-Step Tasks,Validation Commands,Acceptance Criteria)
    ¬exists∨invalid⇒STOP:"Error: Plan file not found or invalid. Run /prp-plan <feature-description> first."
    CHECKPOINT: plan_loaded∧sections_id∧tasks_extracted
  2_PREPARE:
    `git branch --show-current`; `git status --porcelain`
    branch: feature⇒keep|main∧clean⇒`git switch -c feat/{plan-name}`|main∧dirty⇒STOP(ask_user_stash_or_commit)|worktree⇒use_worktree
    sync: `git pull --rebase origin $(git branch --show-current) 2>/dev/null || true`
    CHECKPOINT: branch_ok∧tree_ready∧remote_synced
  3_EXECUTE(∀task∈Step-by-Step Tasks,seq):
    1:read `MIRROR` ref_file 2:impl(mirror_pattern,apply `GOTCHA`,use `IMPORTS`) 3:validate(∀file_Δ):`[type-check cmd]`;fail⇒fix_now 4:log:`[done] Task N: [task name] — complete`
    deviations: log(WHAT+WHY)∧continue(→report)
    CHECKPOINT: tasks_done∧deviations_logged
  4_VALIDATE(fix_before_next_level):
    L1_Static: `[type-check]`(0_err)→`[lint]`+`[lint-fix]`(rem⇒fix_manual)
    L2_Unit: ≥1_test/new_fn(Testing Strategy+plan edge cases)→`[test]`; fail⇒fix_impl(¬test unless test_wrong)
    L3_Build: `[build]`(0_err)
    L4_Integration(if_app): `[dev_srv]&SERVER_PID=$!`; poll `curl -sf http://localhost:PORT/health >/dev/null 2>&1` 30x1s; ¬ready⇒`kill "$SERVER_PID" 2>/dev/null||true`∧exit 1; `[int_test]; TEST_EXIT=$?; kill "$SERVER_PID" 2>/dev/null||true; wait "$SERVER_PID" 2>/dev/null||true; exit "$TEST_EXIT"`
    L5_EdgeCases: verify Testing Strategy checklist
    CHECKPOINT: all_5_levels_pass∧0_err
  5_REPORT:
    `mkdir -p .claude/PRPs/reports`
    write `.claude/PRPs/reports/{plan-name}-report.md`:
      `# Implementation Report: [Feature Name]`/`## Summary`/`## Assessment vs Reality`(Complexity,Confidence,Files Changed:Predicted vs Actual)/`## Tasks Completed`(#,Task,Status:`[done] Complete`,Notes:`Deviated — [reason]`)/`## Validation Results`(Static Analysis,Unit Tests(+N),Build,Integration|N/A,Edge Cases)/`## Files Changed`(File,Action:`CREATED|UPDATED`,Lines:`+N/-M`)/`## Deviations from Plan`(WHAT+WHY|"None")/`## Issues Encountered`(problem+fix|"None")/`## Tests Written`(Test File,Tests,Coverage)/`## Next Steps`(`- [ ] /code-review`,`- [ ] /prp-pr`)
    if_PRD_phase: status `in-progress`→`complete`∧add report_path_ref
    archive: `mkdir -p .claude/PRPs/plans/completed && mv "$ARGUMENTS" .claude/PRPs/plans/completed/`
    CHECKPOINT: report_created∧prd_updated∧plan_archived
§FAIL_HANDLERS:
  type_check: read_err→fix_src→rerun→clean | tests: impl_vs_test→fix_root(impl)→rerun→green
  lint: autofix→manual_rem→rerun→clean | build: check_err(type/import)→fix_file→rerun→pass
  integration: check_srv→verify_route→check_req_fmt→fix→rerun
§GATE(success): TASKS_COMPLETE∧TYPES_PASS∧LINT_PASS∧TESTS_PASS∧BUILD_PASS∧REPORT_CREATED∧PLAN_ARCHIVED
§OUT(6_OUTPUT):
  ## Implementation Complete
  Plan: [path]→completed/ | Branch: [branch] | Status: [done] All tasks complete
  Validation: Type Check[done], Lint[done], Tests[done](N written), Build[done], Integration[done|N/A]
  Files: [N] created, [M] updated | Deviations: [summary|"None — implemented exactly as planned"]
  Artifacts: `.claude/PRPs/reports/{name}-report.md`, `.claude/PRPs/plans/completed/{name}.plan.md`
  PRD Progress(if_app): Phase_N→Status
  Next: `/code-review` | `/prp-commit` | `/prp-pr` | `/prp-plan <next-phase>`
