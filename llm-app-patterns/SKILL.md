---
name: llm-app-patterns
description: "Patterns for building LLM applications, including RAG pipelines, agent architectures (ReAct, function calling, plan-and-execute, multi-agent), prompt engineering with versioning and chaining, prompt/response/CAG caching, LLMOps observability, and production hardening. Use when designing AI applications, implementing RAG with LangChain or LlamaIndex, building agents, setting up LLM monitoring, optimizing LLM costs, reducing hallucinations, or generating structured JSON, XML, and code with Guidance, Outlines, or Instructor."
---

# LLM Application Patterns

Production-ready patterns for building LLM applications. Covers RAG pipelines, agent architectures, prompt engineering, caching strategies, LLMOps observability, and production hardening.

## When to Use

Use this skill when:
- Designing LLM-powered applications
- Implementing RAG (Retrieval-Augmented Generation)
- Building AI agents with tools
- Setting up LLMOps monitoring and evaluation
- Optimizing LLM costs through caching
- Hardening LLM features for production

## 1. RAG Pipeline Architecture

RAG grounds LLM responses in your data through three stages: ingest documents, retrieve relevant context, generate response.

### 1.1 Document Ingestion

Chunking strategy affects retrieval quality:

- **Fixed-size**: Simple, 512 tokens with 50 token overlap. May break semantic context.
- **Semantic**: Split on paragraphs or sections. Preserves meaning.
- **Recursive**: Try separators in order: `["\n\n", "\n", ". ", " "]`. Good default.
- **Document-aware**: Respect headers, lists, tables. Best for structured docs.

Recommended configuration:
```python
CHUNK_CONFIG = {
    "chunk_size": 512,
    "chunk_overlap": 50,
    "separators": ["\n\n", "\n", ". ", " "]
}
```

### 1.2 Embedding & Storage

Vector database selection:

| Database | Use Case | Scale | Key Features |
|---|---|---|---|
| Pinecone | Production, managed | Billions | Hybrid search, metadata filtering |
| Weaviate | Self-hosted, multi-modal | Millions | GraphQL API, modules |
| ChromaDB | Development, prototyping | Thousands | Simple API, in-memory option |
| pgvector | Existing Postgres | Millions | SQL integration, ACID compliance |

Embedding model selection:

| Model | Dimensions | Cost | Quality |
|---|---|---|---|
| openai/text-embedding-3-small | 1536 | $0.02/1M tokens | Good for most use cases |
| openai/text-embedding-3-large | 3072 | $0.13/1M tokens | Best for complex queries |
| local/bge-large | 1024 | Free (compute) | Comparable to OpenAI small |

### 1.3 Retrieval Strategies

**Semantic search**: Embed query, search vector DB, return top-k.

**Hybrid search** (semantic + keyword): Combine vector similarity with BM25 using Reciprocal Rank Fusion. Parameter `alpha` controls balance (1.0 = pure semantic, 0.0 = pure keyword, 0.5 = balanced).

**Multi-query retrieval**: Generate 3 query variations via LLM, search each, deduplicate results. Improves recall.

**Contextual compression**: Retrieve top-10, then use LLM to extract only relevant passages. Reduces context size and noise.

### 1.4 Generation with Context

Use strict prompt template that forces grounding:
```python
RAG_PROMPT_TEMPLATE = """
Answer the user's question based ONLY on the following context.
If the context doesn't contain enough information, say "I don't have enough information to answer that."

Context:
{context}

Question: {question}

Answer:"""
```

Return answer with source citations for verification.

## 2. Agent Architectures

### 2.1 ReAct Pattern (Reasoning + Acting)

Loop: Thought → Action → Observation → repeat → Final Answer.

```python
class ReActAgent:
    def __init__(self, tools: list, llm, max_iterations: int = 10):
        self.tools = {t.name: t for t in tools}
        self.llm = llm
        self.max_iterations = max_iterations

    def run(self, question: str) -> str:
        prompt = REACT_PROMPT.format(tools_description=self._format_tools(), question=question)
        for _ in range(self.max_iterations):
            response = self.llm.generate(prompt)
            if "Final Answer:" in response:
                return self._extract_final_answer(response)
            action = self._parse_action(response)
            observation = self._execute_tool(action)
            prompt += f"\nObservation: {observation}\n"
        return "Max iterations reached"
```

Best for: Multi-step tasks requiring reasoning between tool calls.

### 2.2 Function Calling Pattern

Use native function calling with JSON schemas. More reliable than parsing free-form output.

```python
TOOLS = [
    {
        "name": "search_web",
        "description": "Search the web for current information",
        "parameters": {
            "type": "object",
            "properties": {"query": {"type": "string"}},
            "required": ["query"]
        }
    }
]

class FunctionCallingAgent:
    def run(self, question: str) -> str:
        messages = [{"role": "user", "content": question}]
        while True:
            response = self.llm.chat(messages=messages, tools=TOOLS, tool_choice="auto")
            if response.tool_calls:
                for tc in response.tool_calls:
                    result = self._execute_tool(tc.name, tc.arguments)
                    messages.append({"role": "tool", "tool_call_id": tc.id, "content": str(result)})
            else:
                return response.content
```

Best for: Structured tools, lower latency, simpler implementation.

### 2.3 Plan-and-Execute Pattern

Separate planning from execution. Create plan, execute steps, replan if needed.

```python
class PlanAndExecuteAgent:
    def run(self, task: str) -> str:
        plan = self.planner.create_plan(task)  # Returns list of steps
        results = []
        for step in plan:
            result = self.executor.execute(step, context=results)
            results.append(result)
            if self._needs_replan(task, results):
                plan = self.planner.replan(task, completed=results, remaining=plan[len(results):])
        return self.synthesizer.summarize(task, results)
```

Best for: Complex tasks requiring upfront strategy.

### 2.4 Multi-Agent Collaboration

Specialized agents (researcher, analyst, writer, critic) coordinated by a planner.

```python
class AgentTeam:
    def __init__(self):
        self.agents = {
            "researcher": ResearchAgent(),
            "analyst": AnalystAgent(),
            "writer": WriterAgent(),
            "critic": CriticAgent()
        }
        self.coordinator = CoordinatorAgent()

    def solve(self, task: str) -> str:
        assignments = self.coordinator.decompose(task)
        results = {}
        for a in assignments:
            results[a.id] = self.agents[a.agent].execute(a.subtask, context=results)
        critique = self.agents["critic"].review(results)
        if critique.needs_revision:
            return self.solve_with_feedback(task, results, critique)
        return self.coordinator.synthesize(results)
```

Best for: Research-heavy tasks, quality-critical outputs.

## 3. Prompt Engineering Patterns

### 3.1 Prompt Templates with Validation

```python
class PromptTemplate:
    def __init__(self, template: str, variables: list[str]):
        self.template = template
        self.variables = variables

    def format(self, **kwargs) -> str:
        missing = set(self.variables) - set(kwargs.keys())
        if missing:
            raise ValueError(f"Missing variables: {missing}")
        return self.template.format(**kwargs)

    def with_examples(self, examples: list[dict]) -> str:
        example_text = "\n\n".join([f"Input: {ex['input']}\nOutput: {ex['output']}" for ex in examples])
        return f"{example_text}\n\n{self.template}"
```

Always validate required variables. Use few-shot examples for complex tasks.

### 3.2 Prompt Versioning & A/B Testing

```python
class PromptRegistry:
    def __init__(self, db):
        self.db = db

    def register(self, name: str, template: str, version: str):
        self.db.save({"name": name, "template": template, "version": version,
                      "created_at": datetime.now(), "metrics": {}})

    def get(self, name: str, version: str = "latest") -> str:
        return self.db.get(name, version)

    def ab_test(self, name: str, user_id: str) -> str:
        variants = self.db.get_all_versions(name)
        bucket = hash(user_id) % len(variants)
        return variants[bucket]

    def record_outcome(self, prompt_id: str, outcome: dict):
        self.db.update_metrics(prompt_id, outcome)
```

Store prompts in version control. Track metrics per version. Route users to variants deterministically.

### 3.3 Prompt Chaining

Chain prompts where each step output feeds the next.

```python
class PromptChain:
    def __init__(self, steps: list[dict]):
        self.steps = steps

    def run(self, initial_input: str) -> dict:
        context = {"input": initial_input}
        results = []
        for step in self.steps:
            prompt = step["prompt"].format(**context)
            output = llm.generate(prompt)
            if step.get("parser"):
                output = step["parser"](output)
            context[step["output_key"]] = output
            results.append({"step": step["name"], "output": output})
        return {"final_output": context[self.steps[-1]["output_key"]], "intermediate_results": results}
```

Example chain: Research → Analyze → Summarize.

### 3.4 Structured Output with Validation

Use function calling or JSON mode with schema validation. Never parse unstructured text.

```python
# Define output schema
OUTPUT_SCHEMA = {
    "type": "object",
    "properties": {
        "answer": {"type": "string"},
        "confidence": {"type": "number", "minimum": 0, "maximum": 1},
        "citations": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["answer", "confidence", "citations"]
}
```

Validate every LLM response against schema before using.

## 4. Caching Strategies

### 4.1 Response Caching

Cache deterministic outputs (temperature=0) with Redis.

```python
import hashlib

class LLMCache:
    def __init__(self, redis_client, ttl_seconds=3600):
        self.redis = redis_client
        self.ttl = ttl_seconds

    def _cache_key(self, prompt: str, model: str, **kwargs) -> str:
        content = f"{model}:{prompt}:{json.dumps(kwargs, sort_keys=True)}"
        return hashlib.sha256(content.encode()).hexdigest()

    def get_or_generate(self, prompt: str, model: str, **kwargs) -> str:
        key = self._cache_key(prompt, model, **kwargs)
        cached = self.redis.get(key)
        if cached:
            return cached.decode()
        response = llm.generate(prompt, model=model, **kwargs)
        if kwargs.get("temperature", 1.0) == 0:
            self.redis.setex(key, self.ttl, response)
        return response
```

Only cache when temperature=0. Include all generation parameters in cache key.

### 4.2 Anthropic Prompt Caching

Cache repeated prompt prefixes (system prompts, few-shot examples, document context) using Claude's native prompt caching. Reduces latency and cost for repeated context.

Structure prompts with static prefix first, dynamic suffix last:
```
[SYSTEM PROMPT - cached]
[FEW-SHOT EXAMPLES - cached]
[DOCUMENT CONTEXT - cached]
[USER QUERY - dynamic]
```

### 4.3 Cache Augmented Generation (CAG)

Pre-load entire document corpus into prompt context instead of RAG retrieval. Works when total context fits in window. Eliminates retrieval latency and infrastructure.

Use when: Document set < 100K tokens, queries need full context, latency critical.

### 4.4 Cache Invalidation

- Time-based TTL (default 1 hour)
- Event-based: Invalidate on document updates
- Semantic: Invalidate when embedding drift detected
- Manual: Admin purge for critical corrections

## 5. LLMOps & Observability

### 5.1 Metrics to Track

| Category | Metrics |
|---|---|
| Performance | latency_p50, latency_p99, tokens_per_second |
| Quality | user_satisfaction, task_completion, hallucination_rate |
| Cost | cost_per_request, tokens_per_request, cache_hit_rate |
| Reliability | error_rate, timeout_rate, retry_rate |

### 5.2 Logging & Tracing

Log requests and responses with structured JSON:

```python
import logging
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

class LLMLogger:
    def log_request(self, request_id: str, data: dict):
        log_entry = {
            "request_id": request_id,
            "timestamp": datetime.now().isoformat(),
            "model": data["model"],
            "prompt": data["prompt"][:500],
            "prompt_tokens": data["prompt_tokens"],
            "temperature": data.get("temperature", 1.0),
            "user_id": data.get("user_id"),
        }
        logging.info(f"LLM_REQUEST: {json.dumps(log_entry)}")

    def log_response(self, request_id: str, data: dict):
        log_entry = {
            "request_id": request_id,
            "completion_tokens": data["completion_tokens"],
            "total_tokens": data["total_tokens"],
            "latency_ms": data["latency_ms"],
            "finish_reason": data["finish_reason"],
            "cost_usd": self._calculate_cost(data),
        }
        logging.info(f"LLM_RESPONSE: {json.dumps(log_entry)}")

@tracer.start_as_current_span("llm_call")
def call_llm(prompt: str) -> str:
    span = trace.get_current_span()
    span.set_attribute("prompt.length", len(prompt))
    response = llm.generate(prompt)
    span.set_attribute("response.length", len(response))
    span.set_attribute("tokens.total", response.usage.total_tokens)
    return response.content
```

### 5.3 Evaluation Framework

```python
class LLMEvaluator:
    def evaluate_response(self, question: str, response: str, ground_truth: str = None) -> dict:
        scores = {}
        scores["relevance"] = self._score_relevance(question, response)
        scores["coherence"] = self._score_coherence(response)
        scores["groundedness"] = self._score_groundedness(response)
        if ground_truth:
            scores["accuracy"] = self._score_accuracy(response, ground_truth)
        scores["safety"] = self._score_safety(response)
        return scores

    def run_benchmark(self, test_cases: list[dict]) -> dict:
        results = []
        for case in test_cases:
            response = llm.generate(case["prompt"])
            scores = self.evaluate_response(case["prompt"], response, case.get("expected"))
            results.append(scores)
        return self._aggregate_scores(results)
```

Run evaluations on every prompt change. Track regression.

## 6. Production Patterns

### 6.1 Rate Limiting & Retry

```python
import time
from tenacity import retry, wait_exponential, stop_after_attempt

class RateLimiter:
    def __init__(self, requests_per_minute: int):
        self.rpm = requests_per_minute
        self.timestamps = []

    def acquire(self):
        now = time.time()
        self.timestamps = [t for t in self.timestamps if now - t < 60]
        if len(self.timestamps) >= self.rpm:
            sleep_time = 60 - (now - self.timestamps[0])
            time.sleep(sleep_time)
        self.timestamps.append(time.time())

@retry(wait=wait_exponential(multiplier=1, min=4, max=60), stop=stop_after_attempt(5))
def call_llm_with_retry(prompt: str) -> str:
    try:
        return llm.generate(prompt)
    except RateLimitError:
        raise
    except APIError as e:
        if e.status_code >= 500:
            raise
        raise
```

### 6.2 Fallback Strategy

```python
class LLMWithFallback:
    def __init__(self, primary: str, fallbacks: list[str]):
        self.primary = primary
        self.fallbacks = fallbacks

    def generate(self, prompt: str, **kwargs) -> str:
        for model in [self.primary] + self.fallbacks:
            try:
                return llm.generate(prompt, model=model, **kwargs)
            except (RateLimitError, APIError) as e:
                logging.warning(f"Model {model} failed: {e}")
                continue
        raise AllModelsFailedError("All models exhausted")
```

### 6.3 Streaming Responses

Stream tokens to reduce perceived latency. Show progress for long generations.

```python
async def stream_response(prompt: str):
    async for chunk in llm.stream(prompt):
        yield chunk
```

### 6.4 Async Patterns

Never make LLM calls in synchronous request handlers. Use background jobs or async endpoints.

```python
# FastAPI example
@app.post("/generate")
async def generate(request: GenerateRequest):
    task_id = await queue.enqueue(llm_task, request.prompt)
    return {"task_id": task_id}

@app.get("/result/{task_id}")
async def get_result(task_id: str):
    return await queue.get_result(task_id)
```

## 7. Anti-Patterns & Sharp Edges

| Issue | Severity | Solution |
|---|---|---|
| Trusting LLM output without validation | Critical | Always validate output against schema |
| User input directly in prompts without sanitization | Critical | Escape input, use template variables |
| Stuffing too much into context window | High | Calculate tokens before sending; use RAG or CAG |
| Waiting for complete response before showing anything | High | Stream responses |
| Not monitoring LLM API costs | High | Track per-request cost, set budgets |
| App breaks when LLM API fails | High | Implement fallback models, circuit breakers |
| Not validating facts from LLM responses | Critical | Verify factual claims against sources |
| Caching with high temperature | High | Only cache deterministic (temp=0) outputs |
| No cache invalidation | High | Implement TTL + event-based invalidation |
| Caching everything | Medium | Cache only repeated, expensive prompts |
| Prompt caching fails due to prefix changes | Medium | Structure prompts with static prefix first |
| Demo-ware (works in demo, fails in prod) | Critical | Test with real data, load, edge cases |
| Unstructured output parsing | High | Use function calling / JSON mode |

## 8. Architecture Decision Matrix

| Pattern | Use When | Complexity | Cost |
|---|---|---|---|
| Simple RAG | FAQ, docs search | Low | Low |
| Hybrid RAG | Mixed semantic/keyword queries | Medium | Medium |
| ReAct Agent | Multi-step reasoning tasks | Medium | Medium |
| Function Calling | Structured tools, low latency | Low | Low |
| Plan-and-Execute | Complex tasks needing strategy | High | High |
| Multi-Agent | Research, quality-critical | Very High | Very High |
| Response Caching | Repeated identical queries | Low | Low |
| Prompt Caching | Repeated prefixes (system, examples) | Low | Low |
| CAG | Small corpus, full context needed | Low | Medium |

## 9. Cost Optimization Checklist

- [ ] Use smallest model that meets quality bar
- [ ] Enable prompt caching for repeated prefixes
- [ ] Cache deterministic responses (temperature=0)
- [ ] Use hybrid search to reduce retrieved tokens
- [ ] Compress context before generation
- [ ] Set max_tokens limits on all calls
- [ ] Track cost per request and per feature
- [ ] Implement fallback to cheaper models
- [ ] Batch non-urgent requests
- [ ] Use local embeddings for retrieval

## 10. Safety Checklist

- [ ] Validate all structured outputs against schema
- [ ] Sanitize user input before prompt insertion
- [ ] Implement content moderation on input and output
- [ ] Log all requests for audit trail
- [ ] Set up anomaly detection on latency, errors, costs
- [ ] Define escalation path for harmful outputs
- [ ] Test adversarial inputs regularly
- [ ] Document known failure modes

---

## References

- Dify Platform: https://github.com/langgenius/dify
- LangChain Docs: https://python.langchain.com/
- LlamaIndex: https://www.llamaindex.ai/
- Anthropic Cookbook: https://github.com/anthropics/anthropic-cookbook
- OpenTelemetry: https://opentelemetry.io/

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/prompt-engineering.md](references/prompt-engineering.md) | A concise guide to designing, testing, and optimizing prompts for LLMs. Use it when you need system prompt structure, few‑shot or chain‑of‑thought patterns, reusable templates, or a checklist to avoid common pitfalls. |
| [references/rag-engineering.md](references/rag-engineering.md) | Design and implement Retrieval‑Augmented Generation (RAG) pipelines. Use when you need to turn raw documents into searchable embeddings, retrieve relevant chunks, and feed them to an LLM with minimal hallucination. |
| [references/structured-llm-output.md](references/structured-llm-output.md) | Generate or extract guaranteed‑valid JSON, XML, code, or other structured data from LLMs using Guidance (regex/grammar constraints), Outlines (Pydantic‑driven zero‑overhead generation), or Instructor (automatic validation and retry). Use when you need reliable formats, type safety, or streaming results. |

## Related skills

Load these when the task spans more than this skill.

- [`ai-agent-architecture`](../ai-agent-architecture/SKILL.md) — Design and build reliable autonomous AI agents. Includes agent loops (ReAct, Plan-Execute), tool/function call…
- [`langchain-langgraph`](../langchain-langgraph/SKILL.md) — Build LLM applications with LangChain (agents, chains, RAG, memory, vector stores) and stateful multi-actor wo…
- [`llamaindex`](../llamaindex/SKILL.md) — LlamaIndex skill for building RAG applications with document ingestion, indexing, and querying. Use when creat…
- [`llm-evaluation-observability`](../llm-evaluation-observability/SKILL.md) — Provides a complete workflow to benchmark LLMs with lm-evaluation-harness, accelerate runs with vLLM, track tr…
- [`llm-advanced-techniques`](../llm-advanced-techniques/SKILL.md) — Advanced LLM Techniques for compressing models with knowledge distillation, extending transformer context wind…
- [`crewai`](../crewai/SKILL.md) — CrewAI skill guides you to design, configure, and run role‑based multi‑agent teams in Python. Use it for build…
- [`indie-product-building`](../indie-product-building/SKILL.md) — A step‑by‑step guide for indie creators to turn a validated problem into a profitable product—whether an AI‑wr…
