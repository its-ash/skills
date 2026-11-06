---
description: Recommend the best model tier for the current task based on complexity, risk, and budget.
---

# Model Route Command

Recommend the best model tier for the current task by complexity and budget.

## Usage

`/model-route [task-description] [--budget low|med|high]`

## Routing Heuristic

- `haiku` (Haiku 5.5): deterministic, low-risk mechanical changes
- `sonnet` (Sonnet 5.5): default for implementation and refactors
- `opus` (Opus 5.5) or `fable` (Fable 5.1): architecture, deep review, ambiguous requirements, long autonomous or multi-agent runs

## Required Output

- recommended model
- confidence level
- why this model fits
- fallback model if first attempt fails

## Arguments

$ARGUMENTS:
- `[task-description]` optional free-text
- `--budget low|med|high` optional
