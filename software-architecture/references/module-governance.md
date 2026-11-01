# Module Governance

Connect module-level working rules (local agent instructions, domain-context links, interface ownership) to existing domain language, contracts, and
decisions. This is an orchestration workflow, not a second DDD methodology or an
automatic documentation generator.

## When to use

- The user asks to implement a new business module, without needing to name this workflow.
- The user asks to document an existing module or maintain a confirmed responsibility change.
- An authorized module change needs local instructions and canonical knowledge pointers.

Do not start setup for an ordinary bug, styling change, internal refactor with
unchanged boundaries, or a new directory/UI component that simply inherits
parent conventions. For design discussion or an audit alone, inspect and report
without creating files. Intent-based selection is not a background hook and
does not grant permission for unrelated code, commits, pushes, or business choices.

## How It Works

### 1. Discover the boundary before creating documents

Read applicable project and ancestor harness instructions, the existing map,
requirements, relevant code, and contracts. Identify the module's responsibilities,
non-responsibilities, state ownership, and actual consumers. Directory names alone
do not establish a bounded context. Surface material ambiguities instead of
inventing business rules.

For an existing boundary change, do a read-only change-impact analysis first
(see [code-review/references/change-impact.md](../../code-review/references/change-impact.md)):
list the affected consumers and the evidence for each one. Do not run an
unrelated development workflow.

### 2. Separate project-wide rules from local rules

The project-level instruction source owns global constraints, module navigation,
and cross-module collaboration. A local `AGENTS.md` owns only additional module
constraints: responsibilities, state ownership, public-interface pointers, and
verification entry points. Local rules cannot waive project-wide constraints.

Reuse an established `CLAUDE.md` or other active harness surface instead of
forcing a rename or maintaining two copies. If parent instructions already
cover the module and no local rule is missing, link that source and do not create
a redundant local file. Follow an existing explicit local-entrypoint requirement.
Do not claim that a harness automatically loads every nested instruction file.

### 3. Reuse the existing knowledge owners

| Information | Existing owner |
|---|---|
| Stable terminology and concept relationships | [context-and-decisions](../../documentation/references/context-and-decisions.md), using the existing glossary or context role |
| Hard-to-reverse decisions and rationale | [architecture-decision-records.md](architecture-decision-records.md) |
| Cross-boundary machine-checkable interfaces | [contract-first](../../backend-development/references/contract-first.md) |
| Documentation navigation and lifecycle | [documentation](../../documentation/SKILL.md) (living docs governance) |
| Affected consumers and boundary-change evidence | [change-impact](../../code-review/references/change-impact.md) and [module-regression.md](module-regression.md) |

Load the applicable reference when its work is needed; do not duplicate its method
here. Keep terminology in the relevant existing `CONTEXT.md` or equivalent,
not in AGENTS. Frontend and backend in the same business context can share that
glossary; UI-specific working rules may be local without creating a glossary per
page. Reuse existing contracts and ADRs by reference, not by copying their bodies.

### 4. Maintain only the authorized records

Within the user's requested module work, update the smallest missing local rules
and confirmed context entries. Use the living docs governance rules in [documentation](../../documentation/SKILL.md) for affected navigation
and lifecycle updates, retaining its approval requirement for new top-level
artifacts. Do not create empty files to meet a two-file quota. When implementation
does not yet exist, label the boundary as confirmed design with code unverified;
do not declare documentation/code consistency from prose alone.

### 5. Verify both meaning and links

Compare each claimed owner, interface, and constraint with code, canonical
contracts, and executable evidence. Report contradictions for owner resolution;
do not rewrite the rules merely to match an accidental implementation.

Resolve relative links from **each referencing document's directory**, not the
terminal working directory. Use the repository's own link checker if it has one
(for example `lychee` or `markdown-link-check`); otherwise check each relative
link by hand against the file system.

Confirm that the check covered the changed local instructions, context, and
navigation; check its results and exit code. Fix broken references and rerun,
without creating empty targets. If a target was not checked, report it as
unverified. A passing business test does not prove links are
correct, and an existing same-named file may still be the wrong knowledge owner.

## Examples

- **“Implement an inventory module.”** Inspect existing boundaries; add local
  rules only for genuinely new constraints; reuse the domain glossary and API
  contract; link them from existing navigation; verify code and source-relative links.
- **“Should payments become a separate module?”** Explain boundary options and
  evidence without writing files or treating the discussion as implementation approval.
- **“Fix the inventory badge color.”** Read applicable instructions and fix the
  requested UI behavior; do not generate AGENTS, CONTEXT, or ADR documents.
- **“Audit module documentation.”** Use a read-only link check and semantic
  review; a missing local file is not by itself permission to create one.

## Anti-Patterns

- A mandatory AGENTS/CONTEXT pair for every directory or frontend page.
- Duplicating global constraints, glossary definitions, contracts, or ADR rationale.
- Treating documentation checks as proof of completed business implementation.
- Installing hooks or asserting automatic nested-file loading without real harness wiring.

## Delivery

Report canonical record paths, their project/module scope, actual changes,
verification evidence, and unresolved ownership questions. Module governance
delivers working rules and knowledge entry points, not a complete DDD conversion.
