---
name: llm-evaluation-observability
description: "Provides workflows to benchmark LLMs with lm-evaluation-harness, accelerate inference with vLLM, track training progress, compare models, and add Langfuse tracing for observability. Use when running lm-eval, vLLM evals, Langfuse traces, model benchmarking, LLM regression tests, agent evaluation, eval harness tasks, OpenAI-compatible endpoints, prompt tests, latency metrics, token usage, or debugging eval failures and pitfalls."
---

# LLM Evaluation and Observability

Use this skill to benchmark language models, monitor training progress, compare model families, and add end‑to‑end observability with Langfuse. It also covers reliable testing of LLM agents.

## When to use
- You need academic‑grade benchmark scores (MMLU, GSM8K, HumanEval, etc.).
- You want to track model quality over training steps.
- You must compare several models on the same task suite.
- You run LLM‑driven agents in production and need regression testing and tracing.
- You want to record cost, latency, and user feedback for every LLM call.

---

## Setup and Installation
```bash
# Core evaluation tools
pip install lm-eval vllm

# Observability stack
pip install langfuse openai
```

Create a Langfuse account and obtain `public_key` and `secret_key`.

---

## 1. Standard Benchmark Evaluation (lm‑eval)
1. Choose a benchmark suite.
2. Configure the model.
3. Run the evaluation.
4. Analyse the JSON output.

**Command example**
```bash
lm_eval \
  --model hf \
  --model_args pretrained=meta-llama/Llama-2-7b-hf,dtype=bfloat16 \
  --tasks mmlu,gsm8k,hellaswag,truthfulqa,arc_challenge \
  --num_fewshot 5 \
  --batch_size auto \
  --output_path results/llama2-7b.json \
  --log_samples
```

The result file contains per‑task metrics such as `acc` for MMLU or `exact_match` for GSM8K.

---

## 2. Fast Evaluation with vLLM
vLLM speeds up inference 5‑10×.
```bash
pip install vllm

lm_eval \
  --model vllm \
  --model_args pretrained=meta-llama/Llama-2-7b-hf,tensor_parallel_size=2,dtype=auto \
  --tasks mmlu \
  --batch_size auto
```
Use `--num_fewshot 0` for a quick sanity check.

---

## 3. Periodic Training Progress Tracking
Create a small shell script (inline) and call it from your training loop.
```bash
# eval_checkpoint.sh
CHECKPOINT=$1
STEP=$2

lm_eval \
  --model hf \
  --model_args pretrained=$CHECKPOINT \
  --tasks gsm8k,hellaswag \
  --num_fewshot 0 \
  --batch_size 16 \
  --output_path results/step-${STEP}.json
```
In Python:
```python
if step % eval_interval == 0:
    ckpt = f"checkpoints/step-{step}"
    os.system(f"./eval_checkpoint.sh {ckpt} {step}")
```
Plot learning curves with Matplotlib:
```python
import json, glob, matplotlib.pyplot as plt
steps, scores = [], []
for f in sorted(glob.glob('results/step-*.json')):
    data = json.load(open(f))
    steps.append(int(f.split('-')[1].split('.')[0]))
    scores.append(data['results']['mmlu']['acc'])
plt.plot(steps, scores)
plt.xlabel('Training step')
plt.ylabel('MMLU accuracy')
plt.show()
```
---

## 4. Model Comparison Workflow
1. List model identifiers in `models.txt`.
2. Run a batch evaluation loop.
3. Summarise results in a markdown table.

```bash
# eval_all_models.sh
TASKS="mmlu,gsm8k,hellaswag,truthfulqa"
while read MODEL; do
  NAME=$(echo $MODEL | tr '/' '-')
  lm_eval \
    --model hf \
    --model_args pretrained=$MODEL,dtype=bfloat16 \
    --tasks $TASKS \
    --num_fewshot 5 \
    --batch_size auto \
    --output_path results/${NAME}.json
done < models.txt
```
Python summariser (short version):
```python
import json, pandas as pd, glob
rows = []
for f in glob.glob('results/*.json'):
    data = json.load(open(f))
    name = f.split('/')[-1].replace('.json','').replace('-','/')
    row = {'Model': name}
    for t in ['mmlu','gsm8k','hellaswag','truthfulqa']:
        m = data['results'][t]
        row[t.upper()] = f"{m.get('acc', m.get('exact_match',0)):.3f}"
    rows.append(row)
print(pd.DataFrame(rows).to_markdown(index=False))
```
---

## 5. Observability with Langfuse
### 5.1 Basic Tracing Setup
```python
from langfuse import Langfuse
langfuse = Langfuse(public_key='pk-...', secret_key='sk-...', host='https://cloud.langfuse.com')

trace = langfuse.trace(
    name='chat-completion',
    user_id='user-123',
    session_id='session-456',
    metadata={'feature':'customer-support'},
    tags=['production']
)

generation = trace.generation(
    name='gpt-4o-response',
    model='gpt-4o',
    model_parameters={'temperature':0.7},
    input={'messages':[{'role':'user','content':'Hello'}]}
)

import openai
response = openai.chat.completions.create(
    model='gpt-4o',
    messages=[{'role':'user','content':'Hello'}]
)

generation.end(
    output=response.choices[0].message.content,
    usage={'input':response.usage.prompt_tokens,'output':response.usage.completion_tokens}
)

trace.score(name='user-feedback', value=1, comment='Helpful')
langfuse.flush()  # Important in serverless environments
```
### 5.2 OpenAI Drop‑in Wrapper
```python
from langfuse.openai import openai  # replaces official client
response = openai.chat.completions.create(
    model='gpt-4o',
    messages=[{'role':'user','content':'Tell a joke'}],
    name='joke-generation',
    user_id='user-789',
    session_id='sess-001',
    tags=['test']
)
```
All calls are automatically traced, including streaming and async variants.
### 5.3 LangChain Integration
```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langfuse.callback import CallbackHandler

handler = CallbackHandler(public_key='pk-...', secret_key='sk-...', host='https://cloud.langfuse.com', user_id='u1', session_id='s1')

llm = ChatOpenAI(model='gpt-4o')
prompt = ChatPromptTemplate.from_messages([
    ('system','You are a helpful assistant.'),
    ('user','{input}')
])
chain = prompt | llm

result = chain.invoke({'input':'What is the capital of France?'}, config={'callbacks':[handler]})
```
The same handler works for agents, retrievers, and other LangChain components.
---

## 6. Agent Evaluation Patterns
| Pattern | Goal | Typical Steps |
|---|---|---|
| **Statistical Test Evaluation** | Measure variability | Run the same prompt 20‑30 times, store outputs, compute mean & std of the metric. |
| **Behavioral Contract Testing** | Enforce invariants | Define rules such as "response must contain a date in ISO format". Assert each run satisfies the rule. |
| **Adversarial Testing** | Find failure modes | Perturb the user message (typos, ambiguous phrasing). Verify the agent still respects the contract. |

### Example: Contract Test in Python
```python
import re, json

def check_iso_date(text):
    return bool(re.search(r'\d{4}-\d{2}-\d{2}', text))

outputs = []
for _ in range(25):
    resp = call_agent('Give me tomorrow’s date')
    outputs.append(resp)

assert all(check_iso_date(o) for o in outputs), 'Contract violation detected'
```
---

## 7. Anti‑Patterns & Pitfalls
### Evaluation Speed
- **Problem**: Full MMLU takes hours.
- **Fix**: Use `vllm`, set `--num_fewshot 0`, or evaluate only a subset (`--tasks mmlu_stem`).
### Out‑of‑Memory
- Reduce `--batch_size` or use `--batch_size 1`.
- Enable 8‑bit quantization: `load_in_8bit=True`.
- Use `device_map=auto` with offload folder.
### Result Mismatch
- Verify `--num_fewshot` matches the paper (usually 5).
- Use the exact task name (`mmlu`, not `mmlu_direct`).
- Ensure tokenizer matches the model.
### HumanEval Execution
- Install execution helper: `pip install human-eval`.
- Add flag `--allow_code_execution`.
### Langfuse Tracing
- **Never** omit `langfuse.flush()` in serverless functions.
- **Never** trace every internal function; limit spans to LLM calls and key business logic.
- **Never** skip `user_id` or `session_id`; they are required for debugging.
### Agent Testing
- Avoid single‑run tests; run each scenario multiple times.
- Do not test only the happy path; include edge cases.
- Do not compare raw strings; use semantic similarity or contract checks.
---

## Checklist
- [ ] Install `lm-eval`, `vllm`, `langfuse`, `openai`.
- [ ] Choose benchmark suite (core, code, or custom).
- [ ] Configure model arguments (dtype, quantization, device).
- [ ] Run evaluation with `lm_eval` (use `vllm` for speed if needed).
- [ ] Store results in a JSON file.
- [ ] Set up Langfuse client with keys and host.
- [ ] Wrap each LLM call in a Langfuse trace/generation.
- [ ] Add user_id, session_id, and meaningful metadata.
- [ ] Flush Langfuse client before process exit.
- [ ] For training loops, schedule periodic eval scripts.
- [ ] Plot learning curves to monitor progress.
- [ ] If evaluating agents, implement statistical, contract, and adversarial tests.
- [ ] Review anti‑patterns: OOM, slow runs, missing flush, single‑run tests.
- [ ] Document any custom tasks or prompts for future reproducibility.

## Related skills

Load these when the task spans more than this skill.

- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`langchain-langgraph`](../langchain-langgraph/SKILL.md) — Build LLM applications with LangChain (agents, chains, RAG, memory, vector stores) and stateful multi-actor wo…
- [`llm-app-patterns`](../llm-app-patterns/SKILL.md) — Production-ready patterns for building LLM applications. Covers RAG pipelines, agent architectures (ReAct, fun…
- [`ml-engineering`](../ml-engineering/SKILL.md) — Guidance, best practices, and checklists for building production-grade machine-learning systems. Use for model…
- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`llm-advanced-techniques`](../llm-advanced-techniques/SKILL.md) — Advanced LLM Techniques for compressing models with knowledge distillation, extending transformer context wind…
- [`llamaindex`](../llamaindex/SKILL.md) — LlamaIndex skill for building RAG applications with document ingestion, indexing, and querying. Use when creat…
