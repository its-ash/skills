@REF:iterative-retrieval
# Iterative Retrieval Pattern (progressive subagent context refinement)

§D{
  problem:subagents_lack_known_file_paths/patterns/repo_terminology;send_all⇒context_overflow;send_none⇒missing_info;guess⇒wrong;
  use⇒subagent_unknown_context ∨ multi_agent_progressive_context ∨ "context too large"/"missing context"_errs ∨ code_RAG ∨ token_opt
}

§LOOP{
  phases:DISPATCH→EVALUATE→REFINE→LOOP(maxCycles=3,then_proceed);
  1_DISPATCH:broad_initial_query{patterns,keywords,excludes:[`*.test.ts`,`*.spec.ts`]}→`retrieveFiles(query)`;
  2_EVALUATE:`files.map(f=>({path,relevance,reason,missingContext}))`;
    scores:{High:0.8-1.0(direct_impl),Med:0.5-0.7(related_patterns/types),Low:0.2-0.4(tangential),None:0-0.2(irrelevant⇒exclude)};
  3_REFINE:{patterns:+extractPatterns(eval),keywords:+extractKeywords(eval),excludes:+eval.filter(e=>e.relevance<0.2).map(e=>e.path),focusAreas:unique(eval.flatMap(e=>e.missingContext))};
  4_LOOP:stop_early⇔`highRelevance=eval.filter(e=>e.relevance>=0.7)`∧`highRelevance.length>=3 && !hasCriticalGaps(eval)`;else_`mergeContext(bestContext,highRelevance)`∧continue
}

§PAT{
```js
async function iterativeRetrieve(task, maxCycles = 3) {
  let query = createInitialQuery(task), bestContext = [];
  for (let cycle = 0; cycle < maxCycles; cycle++) {
    const evalRes = evaluateRelevance(await retrieveFiles(query), task);
    const highRel = evalRes.filter(e => e.relevance >= 0.7);
    if (highRel.length >= 3 && !hasCriticalGaps(evalRes)) return highRel;
    query = refineQuery(evalRes, query);
    bestContext = mergeContext(bestContext, highRel);
  }
  return bestContext;
}
```
}

§EX{
  bug_fix("Fix auth token expiry bug"):C1(DISPATCH:"token","auth","expiry"@`src/**`→EVAL:`auth.ts`(0.9),`tokens.ts`(0.8),`user.ts`(0.3)→REFINE:+"refresh","jwt",excl `user.ts`)→C2(EVAL:`session-manager.ts`(0.95),`jwt-utils.ts`(0.85)→done:4_files);
  feature("Add rate limiting to API"):C1(DISPATCH:"rate","limit","api"@`routes/**`→EVAL:0_match,repo_uses_"throttle"→REFINE:+"throttle","middleware")→C2(EVAL:`throttle.ts`(0.9),`middleware/index.ts`(0.7)→REFINE:need_router)→C3(DISPATCH:"router","express"→EVAL:`router-setup.ts`(0.8)→done:3_files)
}

§PROMPT{
  directive:"1.Broad_keyword_search 2.Score_relevance(0-1) 3.Identify_missingContext 4.Refine+repeat(max_3_cycles) 5.Return_files(relevance>=0.7)"
}

§R{
  1:start_broad→narrow_progressively(¬over_specify_C1);
  2:learn_codebase_terminology_in_C1;
  3:track_explicit_`missingContext`_to_drive_refinement;
  4:stop_at_sufficient(≥3_high_rel_files_beats_10_mediocre);
  5:exclude_<0.2_confidently
}
