@REF:gan-style-harness
# GAN-Style Adversarial Harness (Generator–Evaluator loop; Anthropic 2026-03-24)

§PREMISE{
  self_eval_bias:agents_praise_own_mediocre_output⇒separate_ruthless_Evaluator_beats_self_critique;
  loop:Planner(spec)→[Generator(build)⇄Evaluator(live_test+score)]*N
}

§D{
  use⇒1line_prompt→full_app ∨ high_craft_UI ∨ full_stack_working_features ∨ ¬AI_slop ∨ budget∈[$50,$200];
  ¬use⇒1file_fix(`claude -p`) ∨ budget<$10 ∨ simple_refactor(de-sloppify) ∨ pre_specced_w/_tests(TDD)
}

§ARCH{
  Planner(default=sonnet,env=`GAN_PLANNER_MODEL`):1line_prompt→ambitious_16feature_multi_sprint_`spec.md`(stories,tech_reqs,visual_dir,eval_criteria);
  Generator(default=sonnet,env=`GAN_GENERATOR_MODEL`):sprint|continuous_mode;negotiates_sprint_contract_w/_Evaluator_pre_code;stack(React,FastAPI|Express,DB,CSS);git_per_iter;reads_`feedback-*.md`;
  Evaluator(default=sonnet,env=`GAN_EVALUATOR_MODEL`):QA_on_live_app_via_Playwright_MCP(`mcp__playwright__*`:click,forms,API);ruthlessly_strict(¬praise_mediocre);outputs_`feedback-NNN.md`(weighted_score_alone_on_last_line)
}

§RUBRIC{
  scale:1..10;weighted_score=Σ(score*weight);pass≥7.0(`GAN_PASS_THRESHOLD`);max_iter=15(typ:5..15);
  Design_Quality(0.3):1-3=generic_AI_slop|4-6=competent_unremarkable|7-8=distinctive_cohesive|9-10=pro_designer;
  Originality(0.2):1-3=default_colors_stock_no_personality|4-6=some_custom_mostly_std|7-8=clear_creative_vision|9-10=novel_delightful;
  Craft(0.3):1-3=broken_layouts_missing_states_no_anim|4-6=rough_inconsistent_spacing|7-8=polished_smooth_responsive|9-10=pixel_perfect_micro_interactions;
  Functionality(0.2):1-3=core_broken_missing|4-6=happy_path_ok_edge_fail|7-8=all_work_good_err_handle|9-10=bulletproof_all_edges
}

§CMD{
```bash
#!/bin/bash
set -euo pipefail
MAX="${GAN_MAX_ITERATIONS:-15}"
PASS="${GAN_PASS_THRESHOLD:-7.0}"
claude -p --model "${GAN_PLANNER_MODEL:-sonnet}" "You are a Product Planner. Expand this brief into a full product spec with evaluation criteria: '$1'. Write the spec to spec.md"
for i in $(seq -f '%03g' 1 "$MAX"); do
  claude -p --model "${GAN_GENERATOR_MODEL:-sonnet}" "You are a Generator. Read spec.md and the latest feedback-*.md if present. Implement or improve the app. Start the dev server on port ${GAN_DEV_SERVER_PORT:-3000}."
  claude -p --model "${GAN_EVALUATOR_MODEL:-sonnet}" --allowedTools "Read,Bash,mcp__playwright__*" "You are a strict Evaluator. Test the live app at http://localhost:${GAN_DEV_SERVER_PORT:-3000}. Score against the rubric in spec.md. Write feedback to feedback-$i.md. Put the weighted score alone on the last line."
  score="$(tail -n 1 "feedback-$i.md")"
  awk -v s="$score" -v p="$PASS" 'BEGIN { exit !(s >= p) }' && { echo "Passed at iteration $i with $score"; exit 0; }
done
echo "No pass after $MAX iterations. Escalate to a human." >&2
exit 1
```
  manual_prompts:Planner(`PLANNER_PROMPT.md`→`spec.md`),Generator(`spec.md`+`feedback-NNN.md`→Sprint/dev:3000),Evaluator(`--allowedTools "Read,Bash,mcp__playwright__*"`+`EVALUATOR_PROMPT.md`→`feedback-NNN.md`)
}

§EVOL{
  principle:each_harness_component_encodes_model_limitation⇒re-test_&_strip_as_models_improve;
  Stage1(Sonnet-class):full_sprint_decomp∧context_resets_between_sprints(¬context_anxiety)∧≥2agents(Initializer+Coding)∧heavy_scaffolding;
  Stage2(Opus_4.5-class):3agents(Planner+Generator+Evaluator)∧sprint_contracts_pre_phase∧10sprint_decomp∧resets_useful_¬critical;
  Stage3(Opus_4.6-class):1_planning_pass∧continuous_gen∧1_end_pass_eval∧¬sprint_structure∧auto_compaction
}

§CFG{
  env:{`GAN_MAX_ITERATIONS=15`,`GAN_PASS_THRESHOLD=7.0`,`GAN_PLANNER_MODEL=sonnet`,`GAN_GENERATOR_MODEL=sonnet`,`GAN_EVALUATOR_MODEL=sonnet`,`GAN_EVAL_CRITERIA=design,originality,craft,functionality`,`GAN_DEV_SERVER_PORT=3000`,`GAN_DEV_SERVER_CMD="npm run dev"`,`GAN_PROJECT_DIR=.`,`GAN_SKIP_PLANNER=false`,`GAN_EVAL_MODE=playwright`};
  modes:{`playwright`:Browser_MCP+live_interaction→full_stack_UI;`screenshot`:screenshot+visual→static/design_only;`code-only`:tests+lint+build→APIs/libs/CLIs}
}

§ANTI{
  1:lenient_evaluator(passes_iter1)⇒tighten_rubric+explicit_AI_pattern_penalties;
  2:generator_ignores_feedback⇒pass_via_`feedback-NNN.md`_file(¬inline)∧read_at_iter_start;
  3:infinite_loop⇒set_`GAN_MAX_ITERATIONS`∧stop+human_escalate_on_3iter_score_plateau;
  4:superficial_eval⇒Playwright_must_interact(click,forms,error_states),¬screenshot_only;
  5:evaluator_praises_own_fixes⇒Evaluator_critiques_only(¬suggest+self_eval);Generator_fixes;
  6:context_exhaustion⇒Claude_Agent_SDK_auto_compaction∨reset_context_between_phases
}

§BENCH{
  Anthropic_results:{Solo:20min,$9,barely_functional,core_broken,AI_slop | GAN:4-6h(12-18x),$125-200(14-22x),prod_ready,all_working,distinctive_polished};
  tradeoff:~20x_time_&_cost⇒qualitative_leap
}

§REFS{
  [Anthropic: Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps);
  [Epsilla: The GAN-Style Agent Loop](https://www.epsilla.com/blogs/anthropic-harness-engineering-multi-agent-gan-architecture);
  [Martin Fowler: Harness Engineering](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html);
  [OpenAI: Harness Engineering](https://openai.com/index/harness-engineering/)
}
