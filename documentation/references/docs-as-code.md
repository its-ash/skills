@REF:docs-as-code
§R{
  dual_audience:modern_docs_serve(humans∧AI_coding_agents)⇒plain_text_MD/MDX_in_Git∧clean_structure∧low_token_overhead;
  primary_battle:maintenance∧drift_prevention≻initial_authoring;
  structure(Diataxis):separate_4_quadrants(Tutorials,How-to,Reference,Explanation)∧¬mix_intent_in_1_page;
  co_locate:keep_docs_in_same_repo/PR_as_code⇒code_Δ_updates_docs_atomically;
  CI_gates:lint_syntax(markdownlint-cli2)∧lint_prose(Vale)∧check_links(lychee)∧verify_code_refs(doc_drift);
  AI_entry:publish_`/llms.txt`(B2A_agent_index)+`/llms-full.txt`+per_page_`.md`⊕HTTP_`Accept: text/markdown`(RFC7763)⊕MCP_docs;
  llms_txt_reality:B2A_for_coding_agents(Claude_Code,Cursor,Copilot,Windsurf,Aider) ¬consumer_Google_Search/SEO_ranking_signal
}
§D{
  diataxis_quadrants:{
    Tutorials:learning_oriented|safe_step_by_step_first_success|¬api_reference_dumps;
    How-to:goal_oriented|practical_recipe_for_real_task|¬beginner_handholding;
    Reference:info_oriented|exact_API/CLI/config_machinery(auto_gen_from_OpenAPI/code_where_possible)|¬opinionated_narrative;
    Explanation:understanding_oriented|architecture,tradeoffs,concepts,ADRs|¬step_by_step_procedures
  };
  ci_guardrails:{
    syntax:`markdownlint-cli2`(CommonMark/MD_structure,headings,lists,run_pre-commit+CI);
    prose:`Vale`(markup_aware;Google/Microsoft/custom_style_guides;catches_passive_voice,jargon,term_drift;ignores_code_blocks+frontmatter);
    links:`lychee`(fast_Rust_async_checker;validates_internal_paths,anchors,external_URLs;`--exclude-all-private`);
    doc_drift:verify_referenced_file_paths,CLI_flags,code_symbols_against_repo_tree(AST/path_checkers_e.g.`repowise doc-drift`_or_custom_CI_script)⇒fail_PR_on_stale_refs
  };
  ai_ready_publishing:{
    llms_txt:{
      loc:`https://<domain>/llms.txt`(clean_Markdown);
      schema:H1_project_name→`>`concise_summary→`##`categorized_links(`- [Title](URL): brief_desc`)→`## Optional`(skippable_under_tight_ctx_budget);
      companions:`/llms-full.txt`(single_concatenated_corpus_for_large_ctx)∧per_page_`.md`(e.g.`page.md`|`page.html.md`)
    };
    content_negotiation:{
      proto:RFC7763_HTTP_`Accept: text/markdown`⇒return_clean_MD+`Vary: Accept`(cache_correctness);
      edge_and_platforms:Cloudflare_Markdown_for_Agents(emits_`x-markdown-tokens`,`Content-Signal`),Mintlify,Fumadocs,Docusaurus,GitBook,ReadMe;
      just_in_time:expose_MCP_docs_server_for_large_corpora_so_agents_query_targeted_sections¬ingest_whole_site
    }
  }
}
§CFG{
  gh_actions_docs_ci:```yaml
name: Docs CI
on: { pull_request: { paths: ['docs/**', '*.md', '.tours/**'] } }
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: DavidAnson/markdownlint-cli2-action@v1
      - uses: errata-ai/vale-action@v2
      - uses: lycheeverse/lychee-action@v2
        with: { args: "--exclude-all-private 'docs/**/*.md' '*.md'" }
```;
  llms_txt_min:```markdown
# Project Name

> One-sentence summary of what the project does.

## Guides
- [Quickstart](https://example.com/docs/quickstart.md): Setup and first run.
- [API Reference](https://example.com/docs/api.md): Endpoints, auth, and errors.

## Optional
- [Contributing](https://example.com/docs/contributing.md): Local dev and PR rules.
```
}
§CMD{
  local_lint:`markdownlint-cli2 "docs/**/*.md" "*.md" && vale docs/ && lychee --offline docs/`;
  verify_md_neg:`curl -sI -H "Accept: text/markdown" https://<docs-url> | grep -iE "content-type|vary|x-markdown-tokens"`
}
§CHK{
  every_doc_maps_to_1_Diataxis_quadrant∧1_living-docs_role;
  PR_CI_blocks_broken_links(lychee)∧broken_MD(markdownlint-cli2)∧term_drift(Vale);
  API/CLI_refs_auto_synced_or_drift_checked_in_CI;
  public_dev_docs_expose_`llms.txt`+clean_`.md`∨`Accept: text/markdown`+`Vary: Accept`
}
§ANTI{
  mixing_tutorial_steps+API_reference+rationale_on_1_page;
  treating_`llms.txt`_as_SEO_replacement_or_expecting_Google_Search_ranking_from_it;
  shipping_HTML_only_JS_heavy_docs_sans_Markdown_routes_for_dev_tools;
  running_link_checks_without_symbol/file-path_drift_validation;
  forgetting_`Vary: Accept`_when_negotiating_`text/markdown`(poisons_CDN_cache)
}
§REL{
  [../SKILL.md](../SKILL.md):docs_governance_router;
  [living-docs-governance.md](living-docs-governance.md):repo_4_roles_and_harness_rules;
  [../../ai-agent-engineering/SKILL.md](../../ai-agent-engineering/SKILL.md):MCP_servers_and_context_budgets
}
