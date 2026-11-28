@REF:branching-and-prs
§STRAT{
  GitHub_Flow:`main`+`feat/*|fix/*`→PR→`main`;`main`_always_deployable;branch_from_`main`;merge_post_approval+green_CI;deploy_on_merge;
  Trunk_Based:`main`+1-2d_max;short_branch→PR(+merge_queue)→`main`;incomplete_behind_feature_flags;CI_pass;deploy_many×/day;
  GitFlow:`main`(prod)+`develop`(int)+`feature/*|release/*|hotfix/*`;`feature/*`:develop→develop;`release/*`:develop→main+develop;`hotfix/*`:main→main+develop;only_for_scheduled∨regulated_releases;
  Stacked_PRs:split_large_work_into_chained_branches(`main←feat/a←feat/b←feat/c`);enable_`rebase.updateRefs=true`;rebase_top_branch_updates_entire_stack(¬monolithic_PR)
}
§PROTECT{
  Rulesets≻legacy_branch_protection:enforce_via_GitHub_Rulesets(`gh ruleset list`):require_PR+approvals,status_checks,linear_history(optional),signed_commits,block_force-push+deletion,restrict_release_tags(`v*`);
  Merge_Queue:high-velocity_repos⇒require_merge_queue_in_ruleset;CI_tests_PR_against_latest_target+queued_PRs_sequentially_before_merge;queue_via_`gh pr merge <n> --auto`
}
§BRANCH{feat/user-authentication|feat/JIRA-123-payment-integration|fix/login-redirect-loop|fix/456-null-pointer-exception|hotfix/critical-security-patch|release/1.2.0|chore/upgrade-deps|poc/graphql-migration}
§PR{
  title:`<type>(<scope>): <description>`(e.g.`fix(api): resolve race condition in order processing`);
  body_sections:[What|Why|How|Testing([Unit,Integration,Manual])|Screenshots(UI_before/after)|Checklist([Self-review,Docs_updated,No_new_warnings,Tests_pass_locally,Related_issues_linked])|`Closes #123`];
  stacked_PRs:set_base_branch_to_parent_PR;state_stack_order_in_body;retarget_child_to_`main`_after_parent_merges
}
§CHK{
  author:self_review;CI_green(tests,lint,typecheck);Δlines<500;1_feat_or_fix;desc_explains_why;no_stray_debug_or_secrets;
  reviewer:solves_problem;edge_cases;readability;tests;security;clean_history(squash_if_messy);ref→[code-review](../../code-review/SKILL.md)
}
§CONFLICT{
  cfg:`merge.conflictStyle=zdiff3`(shows_base+strips_identical_edges)∧`rerere.enabled=true`∧`rerere.autoupdate=true`(auto-reapplies_repeat_resolutions);
  resolve:`git merge feat/user-auth --no-commit --no-ff`→`git status`→edit_strip_`<<<<<<< ||||||| ======= >>>>>>>`|`git mergetool`|`git restore --ours|--theirs path/file`→`git add --resolved`(Git_2.56+;fallback:`git add path/file`)→`git commit`(or_`git rebase --continue`);
  prevent:small_short_branches;`git fetch origin && git rebase --update-refs origin/main`_often;coord_shared_files;feature_flags(¬long_branches);merge_PRs_fast
}
§FORK{`git remote add upstream https://github.com/original/repo.git`(#once);`git fetch upstream && git switch main && git merge --ff-only upstream/main && git push origin main`(or_`gh repo sync`)}
§ANTI{long-lived_feature_branches|monolithic_PR>500_lines|legacy_branch_protection_without_rulesets|direct_push_to_main|commit_unresolved_conflict_markers}
§REL{[git-workflow](../SKILL.md);[code-review](../../code-review/SKILL.md);[git-commands.md](git-commands.md);[github-ops.md](github-ops.md)}
