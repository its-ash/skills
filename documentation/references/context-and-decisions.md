@REF:context-and-decisions
§R{goal:1 scoped glossary(biz meanings)≠decisions(ADRs);¬empty shell if ∅ stable content;use∈{repeated term explanations,lang ambiguity→drift|boundary bugs,overloaded term(>1 meaning),domain entry∧¬exists,durable decision→ADR};¬use:settled vocab in routine fix⇒∅ modeling|new doc}
§D{
  artifact:{
    1_reuse:existing glossary|domain-model|map context([documentation](../SKILL.md));map lists separate contexts⇒follow links;unclear owner⇒ask;
    2_scope:context-bound(diff contexts⇒diff meanings);¬glossary/dir;¬1 glossary∀contexts;
    3_gate:propose `CONTEXT.md` iff ¬exists∧term resolved;explicit user approval BEFORE write(`update docs`≠new-artifact approval;edit mapped glossary⇒∅ new approval);
    keep:{terms+defs,concept rels,confirmed ambiguities+meaning,unresolved(pending owner)};drop:{impl,status,schedules,full reqs,rationale,history,generic dev words(timeouts,utilities)};
    evidence:∀term→code|contracts|biz evidence;unconfirmed⇒`needs confirmation`,¬guess
  };
  refine(active,¬rewrite-on-read):{
    contradictions:whole-order vs line cancel⇒explain Δ∧ask;¬silent redefine;
    overloaded:"account"(org|login|billing)⇒distinct terms;record rejected syns iff same concept;
    scenarios:ask concrete cases(1 customer>1 login?,partial cancel→invoice?) as Qs,¬invented rules;
    evidence_chk:inspect code/tests/contracts/records;code=behavior,¬owner intent⇒flag mismatch,¬decide;
    capture:authorized edit⇒update glossary(1-2 sent/def+src+avoided syns);¬alter code/contracts/decisions solely for term;read-only⇒show wording,¬write
  };
  adr_handoff:{
    ¬2nd ADR dir|numbering|lifecycle|tpl;trigger:hard-to-reverse∧confusing w/o context∧real tradeoff(routine|reversible|short exp⇒∅);
    target:[software-architecture/references/architecture-decision-records.md](../../software-architecture/references/architecture-decision-records.md);keep repo ADR path/fmt/gates(∅⇒ADR wf picks min path);
    link from `CONTEXT.md`|map|spec|issue(¬copy body);ADR accepted|superseded|deprecated⇒log history(living-docs)
  };
  sched:tasks|status|blockers|schedules⇒tracker(GitHub Issues|Linear);`.scratch/` iff ∅ tracker∧adopted;NEVER in `CONTEXT.md`|ADRs|status|history
}
§CFG{tpl(`CONTEXT.md`,omit empty):`# CONTEXT.md — Domain Language`|`{1-2 sent scope}`|`## Core Terms`:`Term|Def(1-2 sent)|Avoid(syns)|Evidence`|`## Concept Relationships`:`A&B:1:N|transition|containment|constraint`|`## Resolved Ambiguities`:`old→adopted;deprecate old`|`## Needs Confirmation`:`item:wait owner;¬impl Δ`}
§ANTI{tasks/schedules/reqs/impl in `CONTEXT.md`;empty shell∨2nd ADR sys;unconfirmed=fact∨copy ADR body;distinct concepts=syns∨1 glossary∀contexts;glossary edit=code Δ auth∨code=biz rule proof}
§REL{Matt Pocock(MIT):https://github.com/mattpocock/skills/tree/c55ee46073ed923f86ce59a5eb3b6d895095d1b7/skills/engineering/domain-modeling}
