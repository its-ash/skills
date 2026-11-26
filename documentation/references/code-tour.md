@REF:code-tour

§R{
  out:.tours/<persona>-<focus>.tour(CodeTour JSON only;¬modify source);
  purpose:persona-targeted narrative walkthrough(what looking at→why matters→next path);
  use∈{code/onboarding/arch/PR/RCA/security tour,"explain X"+reusable artifact,engineer/reviewer ramp-up,guided sequence>summary};
  ¬use:{one-off chat⇒answer directly;prose docs⇒edit repo docs([documentation](../SKILL.md));impl/refactor⇒implement;broad onboarding ¬tour⇒[codebase-onboarding.md](codebase-onboarding.md)}
}

§D{
  workflow:[
    1_discover:{read(README,pkg/app entrypoints,dir tree,configs,PR changed files);¬write steps before understanding code shape},
    2_persona:{
      "onboarding"|"new joiner"⇒new-joiner(9-13 steps);
      "quick tour"|"vibe check"⇒vibecoder(5-8 steps);
      "architecture"⇒architect(14-18 steps);
      "tour this PR"⇒pr-reviewer(7-11 steps);
      "why did this break"⇒rca-investigator(7-11 steps);
      "security review"⇒security-reviewer(7-11 steps);
      "explain how this feature works"⇒feature-explainer(7-11 steps);
      "debug this path"⇒bug-fixer(7-11 steps)
    },
    3_verify_anchors:{∀file exists;∀line∈range;exact selection block;volatile file⇒pattern anchor;¬guess lines},
    4_write:.tours/<persona>-<focus>.tour(deterministic,readable),
    5_validate:{∀path exists;∀line|selection valid;step[0]∈(file∨dir);ref has ∀referenced file;coherent story(¬file inventory)}
  ];
  ref_rule:{
    semantics:ref≠checked-out branch⇒CodeTour reads from git rev `ref`(¬disk);missing file@`ref`⇒`"The editor could not be opened because the file was not found"`(comments still render);
    pr_tour⇒PR branch(NEVER base e.g.`develop`;PR adds new files absent on base);
    onboarding|arch⇒reader branch(often `main`)∨omit `ref`;
    unsure⇒omit `ref`(reads disk);
    verify:∀step.file exists@chosen `ref`
  };
  SMIG:{Situation:what reader sees;Mechanism:how works;Implication:why matters for persona;Gotcha:what smart reader misses};
  arc:1_orientation→2_module_map→3_core_exec_path→4_edge_case|gotcha→5_closing(what reader can now do,¬recap)
}

§CFG{
  root:`$schema:"https://aka.ms/codetour-schema"`,title,description,ref?,steps:[];
  steps:{
    content(sparingly,usually closing;NEVER step[0]):`{"title","description"}`;
    directory(module orient):`{"directory","title","description"}`;
    file_line(default):`{"file","line","title","description"}`;
    selection(focus block):`{"file","selection":{"start":{"line":15,"character":0},"end":{"line":34,"character":0}},"title","description"}`;
    pattern(drift-safe):`{"file","pattern","title"}`;
    uri(PR|issue|doc):`{"uri","title"}`
  }
}

§ANTI{
  flat file list⇒story w/ step dependency;
  generic desc⇒concrete code path|pattern;
  guessed anchors⇒verify file+line first;
  excess steps on quick tour⇒cut aggressively;
  step[0] content-only⇒anchor to real file|dir;
  persona mismatch⇒write for actual reader;
  PR tour w/ base `ref`⇒use PR branch
}

§CHK{
  step_count∝(repo_size,persona_depth);
  directory=orientation∧file=substance;
  PR_tour⇒changed files first;
  monorepo⇒scope to relevant pkgs;
  closing=reader capability,¬recap
}

§REL{
  [codebase-onboarding.md](codebase-onboarding.md):full onboarding guide;
  [code-review](../../code-review/SKILL.md):PR review;
  https://github.com/microsoft/codetour
}
