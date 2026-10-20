---
name: llm-advanced-techniques
description: "Compresses and adapts large language models with knowledge distillation, reverse KL MiniLLM, context-window extension via RoPE scaling, YaRN, position interpolation, and ALiBi, plus merging fine-tuned checkpoints. Use when distilling teacher models, shrinking LLMs, extending context length, handling long documents, combining LoRA or fine-tuned weights, configuring transformers, and debugging OOM or positional encoding errors."
---

# Advanced LLM Techniques

Apply three high‑impact methods to improve large language models: **knowledge distillation** for size reduction, **long‑context extensions** for handling very long inputs, and **model merging** for blending capabilities of multiple fine‑tuned models.

## When to Use This Skill
- Deploy a smaller model that retains most of a large teacher’s performance.
- Process documents longer than the original context window (32k‑128k tokens).
- Create a single model that combines expertise (e.g., math, code, chat) without additional training.
- Reduce inference cost while preserving quality.

---

## Knowledge Distillation
Compress a large teacher model into a smaller student model while preserving capability.

### Workflow
1. **Load teacher and student** models with `torch_dtype=torch.float16` and appropriate device maps.
2. **Prepare data** (real task data + optional teacher‑generated synthetic data).
3. **Define loss** that mixes hard cross‑entropy with soft KL‑divergence. Use temperature `T` (2‑5) and weight `α` (0.5‑0.9).
4. **Train** the student. Optionally use reverse KL (MiniLLM) for generative tasks.
5. **Evaluate** student against teacher on representative prompts.

### Core Code
```python
import torch, torch.nn.functional as F
from transformers import AutoModelForCausalLM, AutoTokenizer

teacher = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-70b-hf", torch_dtype=torch.float16, device_map="auto"
)
student = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-7b-hf", torch_dtype=torch.float16, device_map="cuda:0"
)
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-2-70b-hf")

T = 2.0          # temperature
α = 0.7          # soft‑loss weight

def distill_loss(s_logits, t_logits, labels):
    hard = F.cross_entropy(s_logits.view(-1, s_logits.size(-1)), labels.view(-1))
    soft_t = F.softmax(t_logits / T, dim=-1)
    soft_s = F.log_softmax(s_logits / T, dim=-1)
    soft = F.kl_div(soft_s, soft_t, reduction='batchmean') * (T ** 2)
    return α * soft + (1 - α) * hard
```

### MiniLLM (Reverse KL) for Generation
```python
def reverse_kl(s_logits, t_logits, T=1.0):
    p = F.softmax(t_logits / T, dim=-1)
    log_q = F.log_softmax(s_logits / T, dim=-1)
    return -(p * log_q).sum(dim=-1).mean() * (T ** 2)
```
Use `reverse_kl` instead of the standard KL when the student must cover many modes (e.g., creative text generation).

### Best‑Practice Rules
- **Temperature**: 2‑5 for most tasks; higher values increase teacher signal.
- **Alpha**: 0.5‑0.9; larger α emphasizes teacher knowledge.
- **Model size ratio**: 5×‑15× reduction works well (e.g., 70B→7B, 13B→1B). Avoid >30× gaps.
- **Data mix**: 70 % teacher‑generated synthetic responses, 30 % real labeled data.
- **Two‑stage training**: distill first, then fine‑tune on the target task.

### Pitfalls
- Using a temperature of 1 makes the soft target too sharp; the student learns little.
- Over‑weighting one model (α ≈ 0.95) can cause over‑fitting to teacher noise.
- Skipping fine‑tuning after distillation reduces downstream performance.

---

## Long‑Context Extension
Enable transformers to attend to sequences far beyond their original limits (32k‑128k tokens).

### Core Techniques
| Method | Max Context | Training Needed | Typical Use |
|--------|-------------|----------------|-------------|
| **RoPE** (rotary) | 8k‑32k | Full pre‑training or fine‑tune | New models |
| **YaRN** | 32k‑128k | Minimal fine‑tune (≈10× fewer steps) | Extending existing RoPE models |
| **ALiBi** | Unlimited | Pre‑train from scratch | Low‑memory training |
| **Position Interpolation** | 32k+ | ~1k fine‑tune steps | Quick extension |

### Quick RoPE Scaling (HuggingFace)
```python
from transformers import AutoConfig, AutoModelForCausalLM

config = AutoConfig.from_pretrained("mistralai/Mistral-7B-v0.1")
config.rope_scaling = {"type": "linear", "factor": 4.0}  # 8k → 32k tokens
model = AutoModelForCausalLM.from_config(config)
```
For YaRN, set `type: "yarn"` and provide `original_max_position_embeddings` and `factor`.

### YaRN Configuration Example
```yaml
rope_scaling:
  type: yarn
  factor: 16.0          # 2048 → 32768 tokens
  original_max_position_embeddings: 2048
  attention_factor: 1.0
```
Apply the config, then fine‑tune on a dataset of long documents (e.g., PG‑19) for a few hundred steps.

### Position Interpolation (Linear Scaling)
```python
model.config.rope_scaling = {"type": "linear", "factor": 16.0}
# Fine‑tune briefly on 32k‑token sequences
```
**Important**: Always run a short fine‑tune after scaling; otherwise the model degrades.

### ALiBi (no positional embeddings)
```python
def create_alibi_bias(seq_len, num_heads):
    import math, torch
    def get_slopes(n):
        def pow2(x): return 2 ** x
        def get_slopes_pow2(m):
            start = pow2(-(2 ** -(math.log2(m) - 3)))
            ratio = start
            return [start * (ratio ** i) for i in range(m)]
        if math.log2(n).is_integer():
            return get_slopes_pow2(n)
        p = 2 ** math.floor(math.log2(n))
        slopes = get_slopes_pow2(p)
        extra = get_slopes_pow2(2 * p)
        slopes.extend(extra[0::2][: n - p])
        return slopes
    slopes = torch.tensor(get_slopes(num_heads)).unsqueeze(-1).unsqueeze(-1)
    rel = torch.arange(seq_len).unsqueeze(0) - torch.arange(seq_len).unsqueeze(1)
    return slopes * rel
```
Add the bias to attention scores before softmax.

### Best‑Practice Rules
- **Scaling factor**: 2.0 (conservative), 4.0 (balanced), 8.0‑16.0 (aggressive, needs more fine‑tune steps).
- **Fine‑tune data**: Use long documents matching target length; short data provides no benefit.
- **Incremental scaling**: Extend 8k→16k, fine‑tune, then 16k→32k, etc., for stability.
- **Memory**: Use FlashAttention (`attn_implementation="flash_attention_2"`) and gradient checkpointing for large windows.

### Pitfalls
- Applying linear scaling without any fine‑tuning leads to poor generation quality.
- Using an aggressive factor (≥8×) without sufficient long‑context data causes instability.
- Mixing ALiBi with RoPE in the same model is unsupported.

---

## Model Merging
Blend multiple fine‑tuned checkpoints into a single model without additional training.

### Supported Merge Methods (mergekit)
| Method | Ideal Scenario |
|--------|----------------|
| **Linear** (Model Soup) | 2+ similar models, quick average |
| **SLERP** | Exactly two models, smooth interpolation |
| **Task Arithmetic** | Combine distinct task‑specific fine‑tunes |
| **TIES** | Many models, resolve sign conflicts |
| **DARE** | Reduce redundancy, keep top‑k deltas |

### Example Linear Merge (YAML)
```yaml
merge_method: linear
models:
  - model: mistralai/Mistral-7B-v0.1
    parameters:
      weight: 0.4
  - model: teknium/OpenHermes-2.5-Mistral-7B
    parameters:
      weight: 0.3
  - model: WizardLM/WizardMath-7B-V1.1
    parameters:
      weight: 0.3
dtype: bfloat16
```
Run:
```bash
mergekit-yaml config.yml ./merged-model --cuda
```

### SLERP Merge for Two Models
```yaml
merge_method: slerp
slices:
  - sources:
      - model: mistralai/Mistral-7B-v0.1
        layer_range: [0, 32]
      - model: teknium/OpenHermes-2.5-Mistral-7B
        layer_range: [0, 32]
parameters:
  t: 0.5   # 0 = first model, 1 = second model
dtype: bfloat16
```
SLERP preserves weight magnitude and yields smoother behavior than linear averaging.

### Task Arithmetic (Base + Skill Vectors)
```yaml
merge_method: task_arithmetic
base_model: mistralai/Mistral-7B-v0.1
models:
  - model: WizardLM/WizardMath-7B-V1.1
    parameters:
      weight: 0.5   # math skill
  - model: teknium/OpenHermes-2.5-Mistral-7B
    parameters:
      weight: 0.3   # chat skill
  - model: ajibawa-2023/Code-Mistral-7B
    parameters:
      weight: 0.2   # coding skill
dtype: bfloat16
```
The base model provides generic language ability; weighted task vectors add specialized knowledge.

### TIES Merge (Sparse Fusion)
```yaml
merge_method: ties
base_model: mistralai/Mistral-7B-v0.1
models:
  - model: WizardLM/WizardMath-7B-V1.1
    parameters:
      density: 0.5
      weight: 1.0
  - model: teknium/OpenHermes-2.5-Mistral-7B
    parameters:
      density: 0.5
      weight: 1.0
parameters:
  normalize: true

dtype: bfloat16
```
`density` controls how many delta parameters are kept; start at 0.8 and lower if memory is tight.

### Best‑Practice Rules
- **Architectural compatibility**: All models must share the same transformer architecture (e.g., all Mistral‑7B). Mixing LLaMA with Mistral is unsupported.
- **Weight sum**: For linear merges, ensure weights sum to 1.0. For task arithmetic, weights can exceed 1.
- **Method choice**:
  - 2 models → SLERP.
  - 3+ similar models → Linear.
  - Distinct tasks → Task Arithmetic or TIES.
  - Want to prune redundant parameters → DARE.
- **Density tuning**: Begin with 0.8, decrease to 0.5 if memory is limited; monitor validation loss.
- **Evaluation**: Always benchmark merged model on each target task before deployment.

### Pitfalls
- Merging models of different size or tokenizers leads to shape mismatches.
- Over‑weighting a single model (≥0.9) suppresses other skills.
- Skipping post‑merge evaluation can hide catastrophic forgetting.

---

## Checklist
- [ ] **Distillation**: select teacher, student, temperature (2‑5), α (0.5‑0.9). Prepare mixed real + synthetic data.
- [ ] **Long‑Context**: choose scaling method (RoPE/YARN/ALiBi/Interpolation). Set scaling factor, add config, fine‑tune on long documents.
- [ ] **Merging**: verify all models share architecture. Pick merge method (linear, SLERP, task arithmetic, TIES). Write YAML config with proper weights/densities.
- [ ] **Training / Fine‑tuning**: enable gradient checkpointing, use FlashAttention if available, set appropriate batch size.
- [ ] **Evaluation**: run representative prompts for each target capability (e.g., math, code, chat, long‑doc generation). Compare against baseline.
- [ ] **Deployment**: export merged or distilled model, optionally quantize (GGUF, GPTQ), push to hub, and test inference with the intended context length.

## Related skills

Load these when the task spans more than this skill.

- [`ml-engineering`](../ml-engineering/SKILL.md) — Guidance, best practices, and checklists for building production-grade machine-learning systems. Use for model…
- [`llm-app-patterns`](../llm-app-patterns/SKILL.md) — Production-ready patterns for building LLM applications. Covers RAG pipelines, agent architectures (ReAct, fun…
- [`llm-evaluation-observability`](../llm-evaluation-observability/SKILL.md) — Provides a complete workflow to benchmark LLMs with lm-evaluation-harness, accelerate runs with vLLM, track tr…
- [`dspy`](../dspy/SKILL.md) — Build complex AI systems with declarative programming using DSPy (Stanford NLP). Covers signatures, modules (P…
- [`langchain-langgraph`](../langchain-langgraph/SKILL.md) — Build LLM applications with LangChain (agents, chains, RAG, memory, vector stores) and stateful multi-actor wo…
- [`claude-api`](../claude-api/SKILL.md) — Provides concise guidance for building, debugging, and optimizing Claude API applications using the Anthropic…
