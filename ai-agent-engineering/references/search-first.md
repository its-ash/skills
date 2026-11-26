@REF:search-first
§CORE{research(packages,MCP,skills,docs)_before_coding→adopt|extend|compose|build}
§WHEN{new_feature_w/_likely_OSS,add_dep/integration,"add X",before_new_util/helper/abstraction,skill_create/fork/find,current_lib/API_behavior}
§FLOW{
  0_Preflight(relevant_channels_only;report_skipped_honestly):{
    repo:rg --files|targeted_rg(miss⇒state_visible_only);
    pkg_reg:npm --version|python -m pip --version|proj_pm(miss⇒web/docs,¬claim_reg_cov);
    gh_cli:gh auth status(miss⇒public_web|local_git);
    mcp_docs:tool_list|local_MCP_cfg(miss⇒official_docs/web);
    skills_dir:ls ~/.claude/skills ~/.codex/skills(miss⇒state_no_local_catalog)
  };
  1_Need:define_func+lang/fw_constraints;
  2_ParallelSearch:{npm/PyPI,MCP/Skills,GitHub/Web};
  3_Eval:{functionality,maint,community,docs,license,deps};
  4_Decide:{
    exact+maintained+MIT/Apache⇒Adopt(direct_use);
    partial+good_base⇒Extend(thin_wrapper);
    multi_weak⇒Compose(2-3_small_pkgs);
    none⇒Build(research_informed)
  };
  5_Impl:install_pkg|cfg_MCP|minimal_custom_code
}
§MODES{
  quick_inline:0.rg_repo→1.npm/PyPI→2.MCP(~/.claude/settings.json)→3.skills(~/.claude/skills/)→4.GitHub_OSS;
  full_agent:`Agent(subagent_type="general-purpose",prompt="Research: [DESC]\nLang:[LANG]\nConstraints:[ANY]\nSearch: npm/PyPI,MCP,Claude skills,GitHub\nReturn: structured comparison + rec")`[legacy:`Task(...)`]
}
§SHORTCUTS{
  dev:{lint:(eslint,ruff,textlint,markdownlint),fmt:(prettier,black,gofmt),test:(jest,pytest,go test),pre_commit:(husky,lint-staged,pre-commit)};
  ai_llm:{claude_sdk:Context7,prompts:MCP,docs:(unstructured,pdfplumber,mammoth)};
  data_api:{http:(httpx[Py],ky/undici[Node]),val:(zod[TS],pydantic[Py]),db:MCP_first};
  content:{md:(remark,unified,markdown-it),img:(sharp,imagemin)}
}
§INT{
  planning:research_before_arch_review;
  arch:stack/integration/ref_decisions;
  iter_retrieval([iterative-retrieval.md](iterative-retrieval.md)):C1_broad→C2_eval_top→C3_compat_check;
  ex:{dead_link⇒textlint-rule-no-dead-link(9/10,ADOPT);http_retry⇒got/httpx(ADOPT);cfg_schema⇒ajv-cli(8/10,ADOPT+EXTEND)}
}
§ANTI{jump_to_code,ignore_MCP,silent_skip(report_"nothing found"_when_channel_down),over_customize(lose_lib_value),dep_bloat(huge_pkg_for_1_small_feat)}
§SKILL_SCOUT{
  gate:run_before_new_skill(unless_user_explicitly_skips);
  1_intent:{task,triggers,domain/tools,3-5_kw+synonyms};
  2_local:`find ~/.claude/skills -maxdepth 2 -name SKILL.md 2>/dev/null | grep -iE "kw|syn"` ∧ `find ~/.claude/plugins/marketplaces -path '*/skills/*/SKILL.md' 2>/dev/null | grep -iE "kw|syn"` ∧ `grep -RilE "kw|syn" ~/.claude/skills ~/.claude/plugins/marketplaces 2>/dev/null`;
  3_remote(≤3_web_queries):`gh search repos "claude code skill kw" --limit 10 --sort stars` ∧ `gh search code "name: kw" --filename SKILL.md --limit 10`;
  4_vet:read_SKILL.md;audit(shell_cmds,file_writes,net_calls,creds,pkg_installs,maint);copy_to_fresh_local_branch+review_diff;¬edit_marketplace_in_place;
  5_rank(≤10):exact_name>desc>local>maintained_GH>web_only(untrusted);
  6_options:Use_existing|Fork/extend|Create_fresh(only_if_chosen∨no_close_match)
}
§DOCS_CONTEXT7{
  when:current_lib/fw/API_behavior(React,Next.js,Prisma,Supabase,...);fallback:official_docs|web_search;
  1:`resolve-library-id(libraryName,query)`→`/org/project`∨`/org/project/version`;
  2_select:exact_name>benchmark_score>High/Med_reputation>version_specific_ID_if_named;
  3:`query-docs(libraryId,query)`→answer_w/_code_examples+cite_version;
  rules:{≤3_calls(resolve/query)_per_Q(unclear⇒state_uncertainty),prefer_official_over_fork,strip_secrets(API_keys,passwords,tokens)_from_queries};
  ex:`resolve-library-id(libraryName="Prisma",query="How do I query with relations?")`→`/prisma/prisma`→`query-docs`(include/select)
}
