# LLM Cost Optimization

Control LLM API cost and keep quality: route models by task complexity, track budget, retry only transient errors, and arrange prompts for high cache reuse.

## When to use

- You build an application that calls LLM APIs (Claude, OpenAI, Gemini, or similar).
- You process batches of items with different complexity.
- You must stay within a budget for API spend.
- You want a higher prompt cache hit rate, lower input cost, or lower latency.
- Do not use this file only to improve the quality of one prompt.

## 1. Model routing by task complexity

Select cheaper models for simple tasks. Keep expensive models for complex tasks.

```python
MODEL_LARGE = "claude-sonnet-5"
MODEL_SMALL = "claude-haiku-4-5-20251001"

_LARGE_TEXT_THRESHOLD = 10_000  # chars
_LARGE_ITEM_THRESHOLD = 30      # items

def select_model(
    text_length: int,
    item_count: int,
    force_model: str | None = None,
) -> str:
    """Select model based on task complexity."""
    if force_model is not None:
        return force_model
    if text_length >= _LARGE_TEXT_THRESHOLD or item_count >= _LARGE_ITEM_THRESHOLD:
        return MODEL_LARGE
    return MODEL_SMALL
```

## 2. Immutable cost tracking

Track cumulative spend with frozen dataclasses. Each API call returns a new tracker. Do not mutate state.

```python
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class CostRecord:
    model: str
    input_tokens: int
    output_tokens: int
    cost_usd: float

@dataclass(frozen=True, slots=True)
class CostTracker:
    budget_limit: float = 1.00
    records: tuple[CostRecord, ...] = ()

    def add(self, record: CostRecord) -> "CostTracker":
        return CostTracker(budget_limit=self.budget_limit, records=(*self.records, record))

    @property
    def total_cost(self) -> float:
        return sum(r.cost_usd for r in self.records)

    @property
    def over_budget(self) -> bool:
        return self.total_cost > self.budget_limit
```

## 3. Narrow retry logic

Retry only on transient errors. Fail fast on authentication or bad request errors.

```python
import time
from anthropic import APIConnectionError, InternalServerError, RateLimitError

_RETRYABLE_ERRORS = (APIConnectionError, RateLimitError, InternalServerError)
_MAX_RETRIES = 3

def call_with_retry(func, *, max_retries: int = _MAX_RETRIES):
    for attempt in range(max_retries):
        try:
            return func()
        except _RETRYABLE_ERRORS:
            if attempt == max_retries - 1:
                raise
            time.sleep(2 ** attempt)
```

## 4. Composition

```python
def process(text: str, config: Config, tracker: CostTracker) -> tuple[Result, CostTracker]:
    model = select_model(len(text), estimated_items, config.force_model)
    if tracker.over_budget:
        raise BudgetExceededError(tracker.total_cost, tracker.budget_limit)
    response = call_with_retry(lambda: client.messages.create(
        model=model,
        messages=build_cached_messages(system_prompt, text),
    ))
    record = CostRecord(model=model, input_tokens=..., output_tokens=..., cost_usd=...)
    return parse_result(response), tracker.add(record)
```

Prices change often. Get current input, output, cache write, and cache read rates from the provider pricing page before you set thresholds or budgets.

## 5. Prompt caching

Savings depend on model, platform, cache eligibility, writes, retention, reuse, and output volume. First identify the exact provider endpoint, model, service tier, and caching mode. Read its current documentation for rates, minimum prefix length, and retention. Caching does not reduce context-window use.

### Keep a stable prefix

Keep reusable instructions, tool schemas, and examples stable. Put changing questions, timestamps, and retrieved results after that content. Respect the provider serialization order: Claude uses tools, then system, then messages. A match needs identical content, including tool schemas and relevant request settings. A changed prefix stops reuse from that point.

```text
Reusable prefix: approved tools, instructions, stable examples/reference
Changing suffix: current question, fresh retrieval results, request metadata
```

```python
messages = [{
    "role": "user",
    "content": [
        {"type": "text", "text": system_prompt, "cache_control": {"type": "ephemeral"}},
        {"type": "text", "text": user_input},
    ],
}]
```

Do not pad prompts or add context only to reach an eligibility threshold, unless cost and quality data justify it.

### Keep user and workspace boundaries

Authorize content access before cache lookup or reuse. Scope application-managed cache handles and accounting keys to the approved user, workspace, provider account, model, and content revision. A cache key is a routing and accounting hint. It is not an authorization gate or a sandbox. Invalidate application references when permissions or content change. Do not log private prompt contents.

### Provider counters

| Provider | Requirements to verify | Counters to record |
| --- | --- | --- |
| OpenAI | Model-specific automatic/explicit modes, minimum length, retention, write/read prices | Responses `usage.input_tokens_details.cached_tokens` and, when present, `cache_write_tokens`; Chat Completions `prompt_tokens_details.cached_tokens` |
| Claude | Supported platform, model minimum, `cache_control` support, TTL; cache writes can cost more than ordinary input | `input_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`, `output_tokens` |
| Gemini | Model minimum and API; explicit cache objects need GenerateContent | Interactions `usage.total_cached_tokens`; GenerateContent `usage_metadata` counters plus explicit-cache token count and retained duration |

Docs: [OpenAI prompt caching](https://developers.openai.com/api/docs/guides/prompt-caching), [Claude prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching), [Gemini caching](https://ai.google.dev/gemini-api/docs/caching).

Claude `input_tokens` counts ordinary input separately from cache reads and writes. A short prefix can give zero cache counters even when you mark it for caching.

### Cost comparison

Normalize usage into categories that do not overlap. Include warmup, miss, expiry, refresh, and retry requests.

```javascript
function compareCacheCost(usage, rates) {
  const counts = ['uncached', 'written', 'read', 'output', 'storageTokenHours'];
  const prices = ['input', 'write', 'read', 'output', 'storage'];
  for (const [values, keys] of [[usage, counts], [rates, prices]]) {
    for (const key of keys) {
      if (!Number.isFinite(values[key]) || values[key] < 0) {
        throw new Error(`${key} must be a finite nonnegative number`);
      }
    }
  }
  const outputCost = usage.output * rates.output / 1e6;
  const storageCost = usage.storageTokenHours * rates.storage / 1e6;
  const baseline = (usage.uncached + usage.written + usage.read) * rates.input / 1e6 + outputCost;
  const actual = (usage.uncached * rates.input + usage.written * rates.write
    + usage.read * rates.read) / 1e6 + outputCost + storageCost;
  return { baseline, actual, savings: baseline - actual, outputCost, storageCost };
}
```

Example (hypothetical rates): ten calls, each with a 10,000-token stable prefix, 2,000-token suffix, and 2,000 output tokens; one write and nine reads. Baseline is $0.6600. With caching it is $0.4245. The output cost ($0.3000) does not change. Never apply a cache discount to output tokens or to the total bill. For a one-off call, the write premium makes the call cost more.

### Verification

1. Record eligible prefix size and model/platform requirements from current docs.
2. If provider traffic is authorized, compare matched requests: cached tokens, all input categories, output, storage, latency, and realized cost. Record misses too.
3. Report token hit rate (cached reads / total input tokens) and request hit rate separately. State denominators and the sample period.
4. If you did not measure traffic, label hit rate and savings as unmeasured.

## Best practices

- Start with the cheapest model. Route to expensive models only when complexity thresholds are met.
- Set explicit budget limits before batch runs. Fail early.
- Log model selection decisions and tune thresholds with real data.
- Keep model names in constants or config.
- Do not retry authentication or validation errors.
