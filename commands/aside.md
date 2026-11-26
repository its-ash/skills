---
description: "Answer side question mid-task without modifying files or losing task context; auto-resume after."
---
@CMD:aside($ARGUMENTS)
§FLOW{
  1:freeze⇒note{active_task(file/feature/problem),step_in_progress,next_step}∧¬modify_files;
  2:answer⇒lead_w_answer→concise∧complete;if(about_open_code)⇒use_live_ctx⊕read_only(read_file)→cite(file:line);if(chain_asides)⇒answer_seq∧keep_state;
  3:resume⇒continue(active_task,exact_pause_pt)∧¬ask_perm(unless §GATE)
}
§R{
  read_only:¬touch∧¬edit∧¬create∧¬delete;
  ¬new_task:pause_only⇒always_resume(unless_redirect);
  ¬save_to_session_files(unless_relevant_to_outcome);
  focused:unblock_fast∧¬lecture
}
§GATE{
  $ARGUMENTS≡∅⇒emit(empty_tpl)∧WAIT;
  reveals_task_issue⇒emit(warn_tpl)∧WAIT(address_now⊕proceed);
  task_redirect(e.g.swap_tech)⇒emit(redirect_tpl)∧WAIT(a|b)∧¬assume;
  ambiguous/vague⇒ask(1_shortest_clarifying_Q)∧¬multi_Q;
  needs_long_answer⇒give_essentials+offer("That's the short version. Want a deeper explanation after we finish [current task]?");
  implies_code_Δ⇒emit(fix_tpl)∧¬edit_during_aside;
  active_task≡∅⇒std_tpl(back_to="no active task to resume")
}
§OUT{
  std:```
ASIDE: [<restate_q>]

[<answer>]

— Back to task: [<1-line_task|"no active task to resume">]
```
  empty:```
ASIDE: no question provided

What would you like to know? (ask your question and I'll answer without losing the current task context)

— Back to task: [<1-line_task>]
```
  warn:```
ASIDE: [<answer>]

WARNING: Note: This answer suggests [<issue>] with the current approach. Want to address this before continuing, or proceed as planned?
```
  redirect:```
ASIDE: That sounds like a direction change, not just a side question.
Do you want to:
  (a) Answer this as information only and keep the current plan
  (b) Pause the current task and change approach
```
  fix:```
ASIDE: [<answer>]

 Worth fixing: [<change_needed>]. I'll flag this after the current task unless you want to address it now.
```
}
