@REF:branching-and-prs
§STRAT{
  GitHub_Flow:`main`+`feature/*|fix/*`→PR→`main`;`main`_always_deployable;branch_from_`main`;merge_post_approval+green_CI;deploy_on_merge;
  Trunk_Based:`main`+1-2d_max;commit→`main`∨short_branch;incomplete_behind_flags;CI_pass;deploy_many×/day;
  GitFlow:`main`(prod)+`develop`(int)+`feature/*|release/*|hotfix/*`;`feature/*`:develop→develop;`release/*`:develop→main+develop;`hotfix/*`:main→main+develop
}
§BRANCH{feature/user-authentication|feature/JIRA-123-payment-integration|fix/login-redirect-loop|fix/456-null-pointer-exception|hotfix/critical-security-patch|release/1.2.0|experiment/new-caching-strategy|poc/graphql-migration}
§PR{
  title:`<type>(<scope>): <description>`(e.g.`fix(api): resolve race condition in order processing`);
  body_sections:[What|Why|How|Testing([Unit,Integration,Manual])|Screenshots(UI_before/after)|Checklist([Self-review,Docs_updated,No_new_warnings,Tests_pass_locally,Related_issues_linked])|`Closes #123`]
}
§REV{
  author:self_review;CI_green(tests,lint,typecheck);Δlines<500;1_feat_or_fix;desc_explains_Δ;
  reviewer:solves_problem;edge_cases;readability;tests;security;clean_history(squash_if_needed);ref→[code-review](../../code-review/SKILL.md)
}
§CONFLICT{
  resolve:`git merge feature/user-auth --no-commit --no-ff`→`git status`→strip_`<<<<<<< ======= >>>>>>>`|`git mergetool`|`git checkout --ours|--theirs path/file`→`git add path/file && git commit`;
  prevent:small_short_branches;`git fetch origin && git rebase origin/main`_often;coord_shared_files;feature_flags(¬long_branches);merge_PRs_fast
}
§FORK{`git remote add upstream https://github.com/original/repo.git`(#once);`git fetch upstream && git checkout main && git merge upstream/main && git push origin main`}
