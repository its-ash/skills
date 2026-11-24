---
name: git-workflow
description: "AUTO_INVOKE(silent)⇔prompt∈{git,GitHub,branch,GitHubFlow,trunk-based,GitFlow,ConventionalCommits,commit,merge,rebase,PR,conflict,SemVer,release,tag,changelog,.gitignore,hooks,gh_CLI,issue_triage,Dependabot,Jira,mcp-atlassian,Linear,open-source,fork,revert,reset,squash,--force-with-lease}|SUB:{github-ops,conventional-commit-review,issue-review,jira-integration,opensource-pipeline,project-flow-ops}"
---
@SKL:git-workflow
§R{
  ¬commit_direct(main)⇒branch+PR;
  branch_life≤days(¬weeks)∧often(rebase→origin/main);
  PR_scope≡1_feature∨1_fix∧Δlines<500;
  commit_fmt:<type>(<scope>): <subject>∧imperative∧¬period∧len≤50∧body⇒why(¬what);
  breaking_change⇒!∨BREAKING_CHANGE:_footer;
  shared∨protected∨merged_branch⇒¬rebase∧¬force-push;
  after_rebase(own_branch)⇒git_push(--force-with-lease)∧¬(--force);
  undo(public_history)⇒git_revert∧¬git_reset;
  ¬commit∈{secrets,.env,node_modules/,dist/,generated_files}⇒add(.gitignore);
  release_tag⇒git_tag(-a vX.Y.Z)(annotated_SemVer);
  pre_review⇒CI_green(tests,lint,typecheck)∧self_review;
}
§D{
  continuous_deploy∧any_team_size(SaaS,startups)⇒GitHub_Flow¬GitFlow_overhead;
  devs≥5_experienced∧deploy_many_per_day⇒trunk-based+feature_flags¬long-lived_branches;
  devs≥10∧(scheduled∨regulated_releases)⇒GitFlow(develop,release/*,hotfix/*)¬trunk_without_flags;
  update(local∨solo_branch←main)⇒git_rebase(origin/main)¬noisy_merge_commits;
  branch_pushed∧used_by_others⇒git_merge¬rebase(rewrites_history);
  feature_branch→main⇒merge_via_PR(squash_if_messy)¬direct_push;
  bad_commit_pushed⇒git_revert(<sha>)¬git_push(--force origin main);
  bad_commit_local_only⇒git_reset(--soft HEAD~1)¬(--hard_if_changes_needed);
  conflict_in_1_file⇒(edit_markers∨--ours∨--theirs)→git_add¬commit_with_markers;
  Δ≡breaking_change⇒SemVer_MAJOR¬MINOR_or_PATCH;
  Δ≡backward_compat_feature⇒SemVer_MINOR¬MAJOR;
  Δ≡backward_compat_fix⇒SemVer_PATCH¬MINOR;
}
§REF{
  strategy_details,branch_names,PR_template,review_checklist,conflict_steps,fork_sync→references/branching-and-prs.md;
  commit_type_table,.gitmessage,tags,changelog→references/commits-and-releases.md;
  cmd_cheat_sheet,undo_table,branch_cleanup,stash,config,aliases,.gitignore,hooks→references/git-commands.md;
  gh_CLI,issue_triage,labels,PR_status,failed_CI,releases,Dependabot,secret-scanning→references/github-ops.md;
  draft∨review_commit_msg(staged_diff,repo_history)→references/conventional-commit-review.md;
  triage_1_GitHub_issue,verify,duplicates,score,draft_reply→references/issue-review.md;
  Jira_tickets(mcp-atlassian∨REST),acceptance_criteria→references/jira-integration.md;
  private→public_project,fork,sanitize,package,publish→references/opensource-pipeline.md;
  backlog_control,merge,rebuild,close,park_PRs,Linear_tracking→references/project-flow-ops.md;
}
§REL{
  ../code-review/SKILL.md:review_changes_pre_merge;
  ../devops-iac/references/github-actions.md:CI/CD_GitHubActions;
  ../devops-iac/SKILL.md:pipelines,GitOps,deployment;
  ../secure-coding/SKILL.md:secrets,security_checks;
}
