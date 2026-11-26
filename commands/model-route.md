---
description: "Recommend model tier by complexity, risk, budget."
---
@CMD:model-route
§ARGS{$ARGUMENTS:[task-description]? [--budget low|med|high]?}
§R{
  haiku(Haiku 5.5):det∧low_risk∧mechanical
  sonnet(Sonnet 5.5):def(impl|refactor)
  opus(Opus 5.5)⊕fable(Fable 5.1):arch|deep_review|ambiguous|long_auto|multi_agent
}
§OUT{model,confidence,fit_rationale,fallback}
