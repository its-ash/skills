---
description: "Enforce React TDD (RTL + Vitest/Jest, behavior/a11y-first) and verify coverage targets."
---
@CMD:react-test
§WHEN{new_component/hook ∨ untested_component ∨ bug_repro_first ∨ forms/state_machines/a11y_UI ∨ RTL_workflow}
§DETECT{
  `test -f vitest.config.ts -o -f vitest.config.js -o -f vite.config.ts` ⇒ Vitest_4(default_new);
  `grep -l '"jest"' package.json` ⇒ Jest(legacy_only)
}
§FLOW{
  1:signature:scaffold_component+`Props`+exports(`throw new Error("not implemented")`);
  2:RED:write_behavior_tests_first(RTL_role-first, `userEvent`, MSW_network, fake_timers_if_debounced, focus/a11y);
  3:verify_FAIL:run_tests→confirm_expected_failure;
  4:GREEN:implement_minimal_code→pass;
  5:verify_PASS:run_tests→green;
  6:REFACTOR:improve_while_green; repeat ∀behavior;
  7:coverage:run_with_`--coverage`→meet_§GATE
}
§PAT{
  queries:`getByRole`,`getByLabelText`,`getByText`(behavior¬impl);
  events:`const user = userEvent.setup()` (`{ advanceTimers: vi.advanceTimersByTime }` w/ `vi.useFakeTimers()`→`vi.advanceTimersByTime(ms)`→`vi.useRealTimers()`);
  msw:`beforeAll(()=>server.listen({onUnhandledRequest:"error"}))` ∧ `afterEach(()=>server.resetHandlers())` ∧ `afterAll(()=>server.close())` ∧ `server.use(http.post(...))`;
  hooks:`const { result } = renderHook(()=>useHook()); act(()=>result.current.fn());`;
  a11y:`import { axe } from "vitest-axe"; expect(await axe(container)).toHaveNoViolations();`
}
§BAN{
  ¬`container.querySelector(...)`;
  ¬assert_render_count;
  ¬`vi.mock("react", ...)`;
  ¬mock_child_components_by_default(only_if_heavy_side_effects);
  ¬ignore_`act()`_warnings;
  ¬rendered_component_snapshots(use_Playwright_visual_diff)
}
§GATE{
  coverage_CI_thresholds(`vitest.config.ts`∨`jest.config.js`):
  pure_utils≥90% | custom_hooks≥85% | presentational≥80% | container≥70% | pages⇒E2E_separate
}
§CMDS{
  vitest:`vitest` | `vitest run` | `vitest run --coverage` | `vitest run path/to/file.test.tsx` | `CI=true vitest run --coverage`;
  jest_legacy:`jest --watch` | `jest --coverage` | `jest path/to/file.test.tsx`
}
§REL{
  cmds:/react-build(fix_build_first), /react-review(post-impl);
  skills:`unit-testing-patterns/references/react-testing.md`,`unit-testing-patterns/references/test-driven-development.md`,`unit-testing-patterns/references/playwright.md`,`web-quality-audit/references/web-accessibility.md`;
  agents:react-reviewer,tdd-guide,e2e-runner
}
