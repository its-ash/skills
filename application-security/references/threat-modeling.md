# Threat Modeling

Produce an actionable AppSec threat model that is specific to a repository or project path. Anchor every architectural claim to repository evidence. Keep assumptions explicit. Prioritize realistic attacker goals and concrete impacts over generic checklists.

## When to use

- The user explicitly asks to threat model a codebase or path.
- The user asks to enumerate threats or abuse paths.
- The user asks for AppSec threat modeling.
- Do not use this skill for general architecture summaries, code review, or non-security design work.

## Inputs to collect or infer

- Repository root path and any in-scope paths.
- Intended usage, deployment model, internet exposure, and authentication expectations.
- Any existing repository summary or architecture specification.
- If no summary exists, derive the system model from repository files and state the evidence used.
- Do not claim components, flows, or controls without evidence.

## Workflow

### 1. Scope and extract the system model

- Identify primary components, data stores, and external integrations.
- Identify how the system runs: server, CLI, library, worker, or other runtime.
- Identify entrypoints.
- Separate runtime behavior from CI, build, development tooling, tests, and examples.
- Map in-scope locations to components.
- Exclude out-of-scope items explicitly.

### 2. Derive boundaries, assets, and entry points

- Enumerate trust boundaries as concrete edges between components.
- For each boundary, note protocol, authentication, encryption, validation, and rate limiting.
- List assets that drive risk: data, credentials, models, configuration, compute resources, and audit logs.
- Identify entry points: endpoints, upload surfaces, parsers, decoders, job triggers, admin tooling, and logging or error sinks.

### 3. Calibrate assets and attacker capabilities

- List assets that drive risk: credentials, PII, integrity-critical state, availability-critical components, and build artifacts.
- Describe realistic attacker capabilities based on exposure and intended usage.
- Explicitly note non-capabilities to avoid inflated severity.

### 4. Enumerate threats as abuse paths

- Prefer attacker goals that map to assets and boundaries: exfiltration, privilege escalation, integrity compromise, and denial of service.
- Classify each threat and tie it to impacted assets.
- Keep the number of threats small but high quality.

### 5. Prioritize with explicit reasoning

- Use qualitative likelihood and impact: low, medium, or high.
- Provide short justifications for likelihood and impact.
- Set overall priority as critical, high, medium, or low using likelihood multiplied by impact, adjusted for existing controls.
- State which assumptions most influence the ranking.

### 6. Validate context and assumptions with the user

- Summarize key assumptions that materially affect threat ranking or scope.
- Ask one to three targeted questions to resolve missing context.
- Useful questions cover service owner and environment, scale and users, deployment model, authentication and authorization, internet exposure, data sensitivity, and multi-tenancy.
- Pause and wait for user feedback before producing the final report.
- If the user declines or cannot answer, state which assumptions remain and how they influence priority.

### 7. Recommend mitigations and focus paths

- Distinguish existing mitigations, with evidence, from recommended mitigations.
- Tie mitigations to concrete locations: component, boundary, or entry point.
- Tie mitigations to control types: authorization checks, input validation, schema enforcement, sandboxing, rate limits, secrets isolation, and audit logging.
- Prefer specific implementation hints over generic advice.
- Base recommendations on validated user context.
- If assumptions remain unresolved, mark recommendations as conditional.

### 8. Run a quality check before finalizing

- Confirm all discovered entrypoints are covered.
- Confirm each trust boundary is represented in threats.
- Confirm runtime behavior is separated from CI and development tooling.
- Confirm user clarifications, or explicit non-responses, are reflected.
- Confirm assumptions and open questions are explicit.
- Write the final Markdown to a file named `<repo-or-dir-name>-threat-model.md`.
- Use the basename of the repository root, or the in-scope directory when modeling a subpath.

## Risk prioritization guidance

- High: pre-authentication remote code execution, authentication bypass, cross-tenant access, sensitive data exfiltration, key or token theft, model or configuration integrity compromise, sandbox escape.
- Medium: targeted denial of service against critical components, partial data exposure, rate-limit bypass with measurable impact, log or metrics poisoning that affects detection.
- Low: low-sensitivity information leaks, noisy denial of service with easy mitigation, issues requiring unlikely preconditions.

## Output format

Use this structure for the final Markdown file:

```markdown
# <Name> Threat Model

## Scope

## System model

## Trust boundaries

## Assets

## Entry points

## Attacker capabilities

## Threats and abuse paths

### T1: <short threat name>
- Category:
- Attacker goal:
- Preconditions:
- Path:
- Impacted assets:
- Likelihood:
- Impact:
- Priority:
- Existing mitigations:
- Recommended mitigations:

## Mitigations

## Assumptions and open questions
```

## Pitfalls to avoid

- Producing a generic checklist instead of a repository-grounded model.
- Claiming components, flows, or controls without evidence.
- Mixing runtime behavior with CI, build, or development tooling.
- Inflating severity by ignoring realistic attacker capabilities.
- Leaving unresolved assumptions unmarked.
- Giving generic mitigation advice instead of concrete control locations.

## Checklist

- [ ] All discovered entrypoints are covered.
- [ ] Each trust boundary is represented in at least one threat.
- [ ] Runtime behavior is separated from CI and development tooling.
- [ ] User clarifications or explicit non-responses are reflected.
- [ ] Assumptions and open questions are explicit.
- [ ] Recommendations are conditional where assumptions remain unresolved.
- [ ] Final file is named `<repo-or-dir-name>-threat-model.md`.
