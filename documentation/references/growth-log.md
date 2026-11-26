@REF:growth-log
§R{goal:extract pattern(cause+transferable rule+signal),¬diary;tool-agnostic(MD,Notion,Obsidian,txt);use∈{complex task(multi-file Δ,feature,arch Δ),failure/mistake/"harder than expected",periodic review,delivery gate};gate:skip trivial(typos,1-line,no-debug cfg);write⇔(debug∨redo∨rollback∨non-obvious decision)}
§D{
  rules:{
    1_failures>wins:2h bug>3 1st-try wins;ex:Chrome 128+ `SameSite=Lax` drops cross-origin auth⇒`SameSite=None; Secure`(signal:auth fails post-upgrade|cross-origin);ex:CSV empty rows counted⇒`df.dropna(how='all', inplace=True)` pre-count;
    2_merge_dups(Bole):search cause keywords first;same cause+new symptom⇒merge(add ex:missed index+ratings→post-task capture gap);new cause⇒new entry;
    3_transferable:answer `"Next time I face similar situation, what do I do differently?"`;steps:[1:1-sent event,2:"why?"×3-5→cause,3:generalize(¬"Chrome 128 bug"→"browser default Δ breaks behavior"),4:`"Next time I see [signal], I will [action]."`,5:observable signal]
  };
  sizing:1 entry/cause;4-8 sent;time∈[30s,2m](>2m⇒narrating,<30s⇒shallow);
  types:{Failure(broke/debug/rework):Root cause|`"Config inheritance is not behavior inheritance across sessions"`;Methodology(repeatable):Context+pattern|`"Slides to open-book study guide: three-layer structure"`;Pattern_discovery(insight):Pattern|`"PR description: describe the gap, not the feature"`;Capability_change(skill Δ):Context(before→after)|`"Git: from clone and push to an independent PR with 12 commits"`};
  storage:`growth-log/YYYY-MM-DD.md`∨Notion/Obsidian(1 convention;searchability>fmt);
  gate_note:Stop hook checking learning Δ needs method(enforcement∧¬method⇒empty timestamps;method∧¬enforcement⇒forgotten captures)
}
§CFG{tpl:`## [Title: pattern,¬event]`|`### Context`(goal+fail|surprise)|`### Root Cause / Core Insight`(mechanism,¬symptom)|`### The Pattern (transferable)`(`Next time [situation], I will [action].`+`Signal to recognize: [observable]`)|`### Related`(`[entry-name](../path/to/related-entry.md)`)}
§CHK{title=pattern(¬event);`"Next time I will..."`;specific signal;dup search first;cause≠symptom;related linked;4-8 sent}
§ANTI{event title(`"Fixed bug in payment module"`);copy commit msg(commit=what,log=why);entry/commit;no transferable sent;dup pattern under diff titles}
