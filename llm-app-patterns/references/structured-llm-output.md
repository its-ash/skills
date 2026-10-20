# Structured LLM Output

Generate or extract data that **always conforms to a schema** (JSON, XML, code, CSV, etc.) without post‑processing retries. This skill covers three mature Python libraries—**Guidance**, **Outlines**, and **Instructor**—and shows when to pick each, how to configure them, and common patterns.

---

## When to Use
- You need **guaranteed‑valid output** (no JSON parsing errors).  
- You want **format validation** (email, date, phone) during generation.  
- You prefer **type‑safe Python objects** (Pydantic models).  
- You are working with **local models** (Transformers, llama.cpp, vLLM) **or** hosted APIs (OpenAI, Anthropic).  
- You need **low latency** or **streaming** of partial results.

---

## Core Concepts

### 1. Guidance – Constrained Generation with Regex & Grammars
- **Installation**
  ```bash
  pip install guidance
  pip install guidance[transformers]   # HuggingFace models
  pip install guidance[llama_cpp]    # llama.cpp models
  ```
- **Key primitives**
  - `gen(name, regex=..., max_tokens=..., stop=...)` – generate text that matches a regular expression.
  - `select(choices, name=...)` – force output to one of a fixed list.
  - Context managers `system()`, `user()`, `assistant()` – write chat‑style prompts in natural Python flow.
  - Token healing – automatically fixes spacing at the prompt‑generation boundary.
- **Simple JSON example**
  ```python
  from guidance import models, gen, system, user, assistant

  lm = models.Anthropic("claude-sonnet-4-5-20250929")

  with system():
      lm += "You generate valid JSON."
  with user():
      lm += "Create a person with name, age, and email."
  with assistant():
      lm += "{"""name": """ + gen("name", regex=r'"[A-Za-z ]+"', max_tokens=30) + ",\n"""age": """ + gen("age", regex=r"[0-9]+", max_tokens=3) + ",\n"""email": """ + gen("email", regex=r'"[\w.%+-]+@[\w.-]+\.[A-Za-z]{2,}"', max_tokens=50) + "}""

  print(lm["name"], lm["age"], lm["email"])  # All fields are guaranteed to match the regexes
  ```
- **Grammar‑based generation** – embed a full context‑free grammar inside a `gen` call to produce nested structures (e.g., full JSON objects, programming language syntax).
- **Reusable functions** – decorate a Python function with `@guidance` to encapsulate a pattern and call it repeatedly.

### 2. Outlines – Zero‑Overhead Structured Generation with Pydantic
- **Installation**
  ```bash
  pip install outlines
  pip install outlines[transformers]   # HuggingFace models
  pip install outlines[llama-cpp-python]   # llama.cpp
  pip install outlines[vllm]   # high‑throughput vLLM
  ```
- **How it works**
  1. Convert a schema (JSON, Pydantic model, or regex) to a **context‑free grammar**.
  2. Compile the grammar to a **finite‑state machine (FSM)**.
  3. At each token step the FSM **filters out invalid logits**, guaranteeing the output follows the schema.
  4. When the FSM reaches a deterministic path it **fast‑forwards** through tokens, giving near‑zero overhead.
- **Pydantic‑driven JSON generation**
  ```python
  from pydantic import BaseModel, Field
  import outlines

  class User(BaseModel):
      name: str = Field(min_length=1, max_length=100)
      age: int = Field(ge=0, le=120)
      email: str = Field(pattern=r"^[\w.%+-]+@[\w.-]+\.[A-Za-z]{2,}$")

  model = outlines.models.transformers("microsoft/Phi-3-mini-4k-instruct", device="cuda")
  generate_user = outlines.generate.json(model, User)

  user = generate_user("Create a user named Alice, 28 years old, alice@example.com")
  print(user.name, user.age, user.email)  # Instance of User, validated automatically
  ```
- **Other generators**
  - `outlines.generate.choice(model, ["pos", "neg", "neu"])` – single‑choice classification.
  - `outlines.generate.regex(model, r"\d{3}-\d{3}-\d{4}")` – generate a phone number.
  - `outlines.generate.integer(model)` / `float(model)` – guarantee numeric type.
- **Backend flexibility** – works with Transformers, llama.cpp, vLLM, and limited OpenAI support.

### 3. Instructor – Pydantic Validation + Automatic Retry + Streaming
- **Installation**
  ```bash
  pip install instructor
  pip install "instructor[anthropic]"   # Claude
  pip install "instructor[openai]"      # OpenAI
  ```
- **Response model** – pass a Pydantic class to the client; Instructor parses the LLM output into that class.
- **Automatic retry** – if validation fails, Instructor sends the error back to the model and retries (default 3 attempts).
- **Streaming** – `create_partial` yields partial objects as tokens arrive; `create_iterable` streams list items.
- **Example with Claude**
  ```python
  import instructor
  from anthropic import Anthropic
  from pydantic import BaseModel, EmailStr, Field

  class User(BaseModel):
      name: str = Field(description="Full name")
      age: int = Field(ge=0, le=120)
      email: EmailStr

  client = instructor.from_anthropic(Anthropic())

  user = client.messages.create(
      model="claude-sonnet-4-5-20250929",
      max_tokens=1024,
      messages=[{"role": "user", "content": "John Doe, 30, john@example.com"}],
      response_model=User,
      max_retries=3,
  )
  print(user)
  ```
- **Streaming example**
  ```python
  from instructor import Partial

  class Story(BaseModel):
      title: str
      content: str
      tags: list[str]

  for part in client.messages.create_partial(
      model="claude-sonnet-4-5-20250929",
      max_tokens=1024,
      messages=[{"role": "user", "content": "Write a short sci‑fi story"}],
      response_model=Story,
  ):
      print("Title:", part.title)
      print("Content so far:", part.content[:100])
  ```
- **Provider‑agnostic** – works with Anthropic, OpenAI, and local OpenAI‑compatible servers (e.g., Ollama).

---

## Common Patterns Across Libraries

### Pattern A – Guaranteed JSON Generation
| Library | Code Sketch |
|--------|------------|
| **Guidance** | Use `gen(..., grammar=...)` or embed a JSON grammar string. |
| **Outlines** | Define a Pydantic model and call `outlines.generate.json`. |
| **Instructor** | Pass the same Pydantic model as `response_model`; Instructor validates and retries. |

### Pattern B – Classification with Fixed Choices
```python
# Guidance
lm += "Sentiment: " + select(["positive", "negative", "neutral"], name="sentiment")

# Outlines
sentiment = outlines.generate.choice(model, ["positive", "negative", "neutral"])("Sentiment of: ...")

# Instructor
class Sent(BaseModel):
    sentiment: Literal["positive", "negative", "neutral"]
review = client.messages.create(..., response_model=Sent)
```
All three guarantee the output is one of the allowed values.

### Pattern C – Multi‑Entity Extraction
```python
# Outlines example (nested Pydantic)
class Entity(BaseModel):
    name: str
    type: Literal["PERSON", "ORG", "LOC"]
class Doc(BaseModel):
    entities: list[Entity]

extract = outlines.generate.json(model, Doc)
result = extract("Extract entities from: Tim Cook met Satya at Microsoft.")
```
Similar logic can be reproduced with Guidance (grammar) or Instructor (response model).

### Pattern D – ReAct‑style Agent (Tool Use)
```python
# Guidance – stateful function
@guidance(stateless=False)
def react(lm, question, tools, max_rounds=5):
    lm += f"Question: {question}\n"
    for i in range(max_rounds):
        lm += "Thought: " + gen(f"thought_{i}", stop="\n") + "\n"
        lm += "Action: " + select(list(tools), name="action")
        if lm["action"] == "answer":
            lm += "\nAnswer: " + gen("answer", max_tokens=100)
            break
        lm += "\nAction Input: " + gen("input", stop="\n")
        observation = tools[lm["action"]](lm["input"])
        lm += f"\nObservation: {observation}\n"
    return lm
```
Outlines and Instructor can implement the same loop manually; the key is the **structured selection** (`select` or `choice`) and **validated observations**.

---

## Best Practices
1. **Prefer regex or `select` for simple formats** – cheaper than full grammar compilation.
2. **Use Pydantic models for any non‑trivial schema** – gives type safety, IDE completion, and automatic validation.
3. **Add field descriptions** – improves LLM understanding and reduces hallucinations.
4. **Avoid over‑constraining** – extremely narrow regexes (e.g., `^(John|Jane)$`) cause generation failures or high latency.
5. **Leverage token healing (Guidance) or FSM fast‑forward (Outlines)** – they remove spacing bugs and speed up deterministic paths.
6. **Provide clear context** – prepend a short instruction like “Generate valid JSON for a user profile.”
7. **Handle optional data** – mark fields as `Optional` in Pydantic; the model will accept missing values.
8. **Set reasonable `max_tokens`** – too low truncates output; too high wastes compute.
9. **When using Instructor, set `max_retries`** – default is 3; increase only if the prompt is ambiguous.
10. **Test the schema offline** – run a quick `json.dumps` of a dummy instance to ensure the model can serialize it.

---

## Pitfalls & How to Avoid Them
| Pitfall | Symptom | Fix |
|---------|----------|-----|
| Regex too strict | Model repeatedly fails or returns empty string. | Relax the pattern or add a fallback `select` with an “unknown” option. |
| Missing `stop` sequence | Generation spills into next field. | Add `stop="\n"` or another unique delimiter. |
| Large nested schemas with Outlines | FSM compilation takes seconds on first call. | Compile once and reuse the generator; cache the generator object. |
| Instructor validation error loops | API call takes long, logs many retries. | Provide richer field descriptions and examples in the prompt. |
| Token healing disabled (Guidance) | Double spaces or broken punctuation. | Keep default; do not manually split prompts at token boundaries. |
| Using OpenAI with Outlines for complex grammars | Some features (e.g., FSM) are not supported. | Prefer local Transformers or vLLM for full capability. |

---

## Checklist
- [ ] Choose a library:
  - **Guidance** for regex/grammar constraints and chat‑style flow.
  - **Outlines** for fastest zero‑overhead generation with Pydantic models.
  - **Instructor** for automatic validation, retry, and streaming.
- [ ] Install the required package and backend (Transformers, llama.cpp, vLLM, or API).
- [ ] Define a **schema** (regex, grammar, or Pydantic model).
- [ ] Add **field descriptions** and any `Field` constraints (min/max, pattern).
- [ ] Write a concise system/user prompt that tells the model to output the schema.
- [ ] Use `gen`, `select`, or the appropriate generator (`outlines.generate.json`, `client.messages.create`).
- [ ] Set `max_tokens` and `stop` to bound each field.
- [ ] Test with a few examples; adjust constraints if generation stalls.
- [ ] For production, cache the generator/function and reuse the model instance.
- [ ] Monitor latency and memory; switch to a more efficient backend if needed.

---

## Comparison Table
| Feature | Guidance | Outlines | Instructor |
|---------|----------|----------|------------|
| Regex / Grammar constraints | ✅ (regex → grammar) | ✅ (regex → FSM) | ❌ (relies on Pydantic) |
| Pydantic model support | ❌ | ✅ (native) | ✅ (native) |
| Token healing | ✅ (default) | ❌ (not needed) | ❌ |
| Automatic retry on validation error | ❌ | ❌ | ✅ |
| Streaming partial results | ❌ | ❌ | ✅ |
| Local model support | ✅ (Transformers, llama.cpp) | ✅ (Transformers, llama.cpp, vLLM) | ✅ (via OpenAI‑compatible servers) |
| Zero‑overhead generation speed | ⚠️ (grammar compilation) | ✅ (FSM fast‑forward) | ⚠️ (validation after generation) |
| Learning curve | Low | Low | Low |

---

## Quick Reference Commands
```bash
# Guidance
pip install guidance[transformers]
# Outlines
pip install outlines[transformers] outlines[vllm]
# Instructor
pip install instructor[anthropic]
```
```python
# Load a model (replace with your preferred backend)
from guidance import models as g_models
lm = g_models.Transformers("microsoft/Phi-4-mini-instruct", device="cuda")

import outlines
model = outlines.models.transformers("microsoft/Phi-4-mini-instruct", device="cuda")

import instructor
from anthropic import Anthropic
client = instructor.from_anthropic(Anthropic())
```
---

**End of skill**
