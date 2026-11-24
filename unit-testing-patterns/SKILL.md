---
name: unit-testing-patterns
description: "AUTO_INVOKE(silent)⇔prompt∈{unit-test,TDD,red-green-refactor,Jest,pytest,Vitest,Playwright,RTL,React-Testing-Library,MSW,axe,factory,fixture,overrides,mock,patch,autospec,AsyncMock,jest.clearAllMocks,it.each,pytest.mark.parametrize,pytest-asyncio,waitFor,findBy,queryBy,SQLite-fixture,flaky-test,describe,POM,TESTS.md,browser-qa,a11y,regression-test,coverage}|SUB:{test-driven-development,playwright,react-testing,ai-regression-testing,test-collaboration,browser-qa}"
---
@SKL:unit-testing-patterns
§R{
  TDD⇒write(failing_test)→run∧observe_fail→write(minimal_code_to_pass)→run(all_tests)→refactor(while_green);
  1_observable_behavior_per_test;
  test_data⇒factories(Jest)∨factory_fixtures(pytest)w/(defaults+overrides)∧override_only_needed_fields;
  mock_only_external_boundaries(network,email,analytics,clock)∧keep_core_logic_real;
  patch@import_location_used_by_CUT∧`autospec=True`(enforce_real_signatures);
  clear_mocks_between_tests⇒(`jest.clearAllMocks()`∈`beforeEach`∨pytest-mock_resets_`mocker`_per_test);
  assert_on(outputs,UI)∧¬mock_calls(unless_call≡contract);
  ∀(promise∨coroutine)⇒`await`(missing_`await`⇒false_pass);
  test_name⇒present_tense_spec(e.g.`creates user with valid data`);
  group⇒nested_`describe`(Rendering,User_interactions)∨`Test<Unit>`class;
  ∀Δ⇒run(full_suite)∧coverage_Δ≥0
}
§D{
  many_cases∧same_logic⇒`it.each`⊕`@pytest.mark.parametrize`¬copy_pasted_tests;
  async_fn⇒`async`_test+`await`+`pytest-asyncio`+`AsyncMock`(awaited_deps)¬fire_and_forget;
  element_appears_later⇒`await waitFor(...)`⊕`findBy*`¬fixed_sleeps;
  element_absent⇒`queryBy*`→`toBeNull()`¬`getBy*`_in_try_catch;
  DB_in_unit_test⇒in_memory_SQLite_fixture+`yield`¬shared_dev_DB;
  flaky_test⇒find(shared_state,timing,order)∧fix_root_cause(../systematic-debugging/SKILL.md)¬retries_to_hide;
  React_components_hooks_MSW_axe⇒references/react-testing.md¬snapshot_only_tests;
  full_user_flow_in_browser⇒references/playwright.md¬unit_tests_w_heavy_DOM_mocks;
  AI_written_code⇒references/ai-regression-testing.md¬trust_without_regression_test
}
§REF{
  factories,mocks,structure,Testing_Library_queries,parametrize,async,DB_fixture,run_cmds→references/jest-pytest-patterns.md;
  strict_TDD_cycle(features,fixes,refactors)→references/test-driven-development.md;
  Playwright_E2E(config,POM,auth_state,fixtures,flaky_fixes,artifacts,visual_regression,CI_sharding)→references/playwright.md;
  RTL,Vitest_Jest,MSW,axe,RTL_vs_Playwright_CT_vs_E2E→references/react-testing.md;
  regression_tests_AI_code,sandbox_prod_parity→references/ai-regression-testing.md;
  test_inventory,gap_analysis,TESTS.md_TEST-ID_registry,evidence_review→references/test-collaboration.md;
  post_deploy_browser_QA(smoke,interaction,visual,a11y,SHIP_verdict)→references/browser-qa.md
}
§REL{
  ../python/SKILL.md:pytest_deep_dive_via_python-testing;
  ../typescript/SKILL.md:TS_types,config;
  ../typescript/references/javascript.md:core_JS(closures,event_loop);
  ../systematic-debugging/SKILL.md:root_cause(failing∨flaky_tests);
  ../clean-code/SKILL.md:naming,structure_in_tests
}
